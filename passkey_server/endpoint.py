from fastapi import FastAPI, Depends, HTTPException
from jose import jwt
from datetime import datetime, timedelta
from sqlalchemy import create_engine, Column, String, Boolean
from sqlalchemy.orm import sessionmaker, DeclarativeBase, Session
import pyotp
from fido2.server import Fido2Server
from fido2.webauthn import PublicKeyCredentialRpEntity
from passlib.context import CryptContext
import secrets
import os
from dotenv import load_dotenv
from pydantic import BaseModel
import base64

# Load environment variables
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
SECRET_KEY = os.getenv("SECRET_KEY")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))

# Database setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# WebAuthn Setup
RP = PublicKeyCredentialRpEntity("osintapp.com", "OSINT App")
fido_server = Fido2Server(RP)

# Temporary storage for passkey registration state
passkey_states = {}

# Refresh token storage
refresh_tokens_db = {}

app = FastAPI()

# Database model
class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"
    username = Column(String, primary_key=True, index=True)
    hashed_password = Column(String)
    totp_secret = Column(String, nullable=True)
    webauthn_public_key = Column(String, nullable=True)
    use_totp = Column(Boolean, default=False)
    use_passkey = Column(Boolean, default=False)

# Initialize database
Base.metadata.create_all(bind=engine)

# Dependency for DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Helper functions
def get_user_from_db(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def create_user(db: Session, username: str, password: str):
    hashed_password = pwd_context.hash(password)
    db_user = User(username=username, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def generate_totp_secret():
    return pyotp.random_base32()

def verify_totp(secret, user_code):
    totp = pyotp.TOTP(secret)
    return totp.verify(user_code)

# Request Models
class RegisterRequest(BaseModel):
    username: str
    password: str

class LoginRequest(BaseModel):
    username: str
    password: str
    totp_code: str = None
    passkey_cred: dict = None

# Registration endpoint
@app.post("/register")
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    user = get_user_from_db(db, request.username)
    if user:
        raise HTTPException(status_code=400, detail="Username already taken")
    
    new_user = create_user(db, request.username, request.password)
    return {"message": "User registered successfully", "username": new_user.username}

# WebAuthn Passkey Registration
class RegisterPasskeyRequest(BaseModel):
    username: str

@app.post("/register_passkey")
async def register_passkey(data: RegisterPasskeyRequest, db: Session = Depends(get_db)):
    print(f"✅ Received username: {data.username}")
    username = data.username
    user = get_user_from_db(db, username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    options, state = fido_server.register_begin(
        user={"id": username.encode(), "name": username}
    )

    passkey_states[username] = state  # Store the state temporarily

    
    # Convert the challenge to Base64 **only for the response**
    encoded_challenge = base64.b64encode(options.public_key.challenge).decode("utf-8")

    # Manually convert `options` to a dictionary
    options_dict = {
        "publicKey": {
            "rp": {"name": options.public_key.rp.name, "id": options.public_key.rp.id},
            "user": {
                "name": options.public_key.user.name,
                "id": base64.b64encode(options.public_key.user.id).decode("utf-8"),  # Encode user ID as Base64
                "displayName": options.public_key.user.display_name,
            },
            "challenge": encoded_challenge,  # Encoded for response
            "pubKeyCredParams": [
                {"type": param.type.value, "alg": param.alg}
                for param in options.public_key.pub_key_cred_params
            ],
            "timeout": options.public_key.timeout,
            "excludeCredentials": options.public_key.exclude_credentials,
            "authenticatorSelection": options.public_key.authenticator_selection,
            "attestation": options.public_key.attestation,
            "extensions": options.public_key.extensions,
        }
    }

    # print({"options": options, "state": state})
    return {"options": options_dict, "state": state}

@app.post("/verify_passkey")
def verify_passkey(username: str, credential: dict, db: Session = Depends(get_db)):
    user = get_user_from_db(db, username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    state = passkey_states.get(username)  # Retrieve stored state
    if not state:
        raise HTTPException(status_code=400, detail="Passkey registration state not found")

    auth_data = fido_server.register_complete(state, credential)
    user.webauthn_public_key = auth_data.credential_data.public_key
    user.use_passkey = True
    db.commit()

    del passkey_states[username]  # Remove state after registration

    return {"message": "Passkey registered successfully"}

# Generate challenge for passkey authentication
@app.get("/get_challenge")
async def get_challenge():
    challenge = secrets.token_urlsafe(32)  # Generate a secure random challenge
    return {"challenge": challenge}

# Login with Password, TOTP, or Passkey
@app.post("/login")
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = get_user_from_db(db, request.username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not verify_password(request.password, user.hashed_papasswordssword):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    if user.use_totp:
        if not request.totp_code or not verify_totp(user.totp_secret, request.totp_code):
            raise HTTPException(status_code=401, detail="Invalid TOTP code")

    if user.use_passkey:
        try:
            fido_server.authenticate_complete([user.webauthn_public_key], request.passkey_cred)
        except:
            raise HTTPException(status_code=401, detail="Invalid Passkey")

    access_token = jwt.encode(
        {"sub": request.username, "exp": datetime.now() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)},
        SECRET_KEY,
        algorithm="HS256",
    )

    refresh_token = secrets.token_urlsafe(32)
    refresh_tokens_db[refresh_token] = {"username": request.username, "exp": datetime.now() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)}

    return {"access_token": access_token, "token_type": "bearer", "refresh_token": refresh_token}

# Refresh token endpoint
@app.post("/refresh")
def refresh_token(refresh_token: str):
    token_data = refresh_tokens_db.get(refresh_token)

    if not token_data:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    if token_data["exp"] < datetime.now():
        del refresh_tokens_db[refresh_token]  # Remove expired token
        raise HTTPException(status_code=401, detail="Refresh token expired")

    new_access_token = jwt.encode(
        {"sub": token_data["username"], "exp": datetime.now() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)},
        SECRET_KEY,
        algorithm="HS256",
    )

    return {"access_token": new_access_token, "token_type": "bearer"}
