part of 'auth_screen.dart';

Future<void> startPasskeyRegistration(String username) async {
  final response = await http.post(
    Uri.parse("http://192.168.0.114:8000/register_passkey"),
    body: utf8.encode(jsonEncode({"username": username})),
    headers: {"Content-Type": "application/json; charset=utf-8"},
  );

  debugPrint("Response status: ${response.statusCode}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Decode the base64 challenge
    final challenge = base64Decode(data["options"]["publicKey"]["challenge"]);

    await registerPasskey(username, challenge.toString());
  } else {
    debugPrint("Failed to start passkey registration: ${response.body}");
  }
}

Future<void> registerPasskey(String username, String challenge) async {
  final passkeys = PasskeysAndroid();

  final request = RegisterRequestType(
    relyingParty: RelyingPartyType(name: 'OSINTApp', id: 'osintapp.com'),
    user: UserType(displayName: username, name: username, id: username),
    challenge: challenge,
    authSelectionType: AuthenticatorSelectionType(
      requireResidentKey: true,
      residentKey: 'preferred',
      userVerification: 'preferred',
    ),
    excludeCredentials: [],
  );

  final credential = await passkeys.register(request);

  if (credential != null) {
    final response = await http.post(
      Uri.parse(
          "http://192.168.0.114:8000/verify_passkey"), // ✅ Correct endpoint
      body: jsonEncode({
        "username": username,
        "credential": {
          "id": credential.id,
          "rawId": credential.rawId,
          "type": credential.runtimeType,
          "response": {
            "attestationObject": credential.attestationObject,
            "clientDataJSON": credential.clientDataJSON,
          }
        }, // ✅ Send entire credential object
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      debugPrint("Passkey registered successfully!");
    } else {
      debugPrint("Passkey registration failed: ${response.body}");
    }
  } else {
    debugPrint("Passkey registration failed.");
  }
}

Future<String> fetchChallenge() async {
  final response =
      await http.get(Uri.parse("http://192.168.0.114:8000/get_challenge"));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["challenge"];
  } else {
    throw Exception("Failed to fetch challenge");
  }
}

Future<void> loginWithPasskey(String username) async {
  final passkeys = PasskeysAndroid();
  final challenge = await fetchChallenge();

  final request = AuthenticateRequestType(
    relyingPartyId: "osintapp.com",
    challenge: challenge,
    mediation: MediationType.Required,
    preferImmediatelyAvailableCredentials: true,
  );

  final credential = await passkeys.authenticate(request);

  if (credential != null) {
    final response = await http.post(
      Uri.parse("http://192.168.0.114:8000/login_with_passkey"),
      body: jsonEncode({
        "username": username,
        "passkey_id": credential.id,
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      debugPrint("Login successful with Passkey!");
    } else {
      debugPrint("Passkey login failed: ${response.body}");
    }
  } else {
    debugPrint("Passkey authentication failed.");
  }
}

void checkIfPasskeysWorks() async {
  final passkeys = PasskeysAndroid();
  final supported = await passkeys.canAuthenticate();

  if (!supported) {
    debugPrint("Passkeys not supported on this device.");
    return;
  }
}
