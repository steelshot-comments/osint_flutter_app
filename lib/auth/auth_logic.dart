part of 'auth_screen.dart';
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<void> login(String username, String password, BuildContext context, {String? totpCode}) async {
  // String? totpCode = isTotpEnabled ? totpController.text : null;
  Dio dio = Dio();
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  final response = await dio.post(
    "$AUTH_API_URL/login",
    data: {
      "username": username,
      "password": password,
    },
    options: Options(
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
    )
  );

  if (response.statusCode == 200) {
    debugPrint("hello");
    final data = response.data as Map<String, dynamic>;
    final access_token = data["access_token"];
    final refresh_token = data["refresh_token"];

    // Save login state securely
    await secureStorage.write(key: "access_token", value: access_token);
    await secureStorage.write(key: "refresh_token", value: refresh_token);
    await secureStorage.write(key: "username", value: username);

    debugPrint("Login successful!");
    Navigator.pushReplacementNamed(context, "/home");
  } else {
    debugPrint("Login failed: ${response.data}");
  }
}

Future<void> logout(BuildContext context) async {
  debugPrint("logging out");
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  await secureStorage.delete(key: "username");
  await secureStorage.delete(key: "access_token");
  await secureStorage.delete(key: "refresh_token");

  debugPrint("Logged out successfully!");

  Navigator.pushReplacementNamed(context, "/login");
}


Future<void> signUp(
    String username, String password, String email, BuildContext context) async {
  try {
    final response = await Dio().post(
      "$AUTH_API_URL/register",
      data: {
        "username": username,
        "password": password,
        "email": email
      },
      options: Options(
        headers: {"Content-Type": "application/json", "Accept": "application/json"}
      ),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PasskeySetup(
                  isSignUp: true,
                  username: username,
                )),
      );
      // await signIn(username, password, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: response.data)
      );
      print("Signup failed: ${response.data}");
    }
  } catch (e) {
    debugPrint("Error: $e");
  }
}

Future<String?> refreshAccessToken() async {
  final refreshToken = await secureStorage.read(key: "refresh_token");

  if (refreshToken == null) {
    debugPrint("No refresh token found!");
    return null;
  }

  final response = await Dio().post(
    "$AUTH_API_URL/refresh",
    data: {"refresh_token": refreshToken},
    options: Options(headers: {"Content-Type": "application/json"}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.data);
    final newAccessToken = data["access_token"];

    // Update the stored access token
    await secureStorage.write(key: "access_token", value: newAccessToken);

    debugPrint("Access token refreshed!");
    return newAccessToken;
  } else {
    debugPrint("Failed to refresh access token: ${response.data}");
    return null;
  }
}