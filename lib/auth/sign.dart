part of 'login.dart';
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<void> signIn(String username, String password, BuildContext context, {String? totpCode}) async {
  // String username = usernameController.text;
  // String password = passwordController.text;
  // String? totpCode = isTotpEnabled ? totpController.text : null;

  final response = await http.post(
    Uri.parse("http://192.168.0.114:8000/login"),
    body: jsonEncode({
      "username": username,
      "password": password,
    }),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final access_token = data["access_token"]; // Assuming API returns a token
    final refresh_token = data["refresh_token"]; // Assuming API returns a token

    // ✅ Save login state securely
    await secureStorage.write(key: "access_token", value: access_token);
    await secureStorage.write(key: "refresh_token", value: refresh_token);
    await secureStorage.write(key: "username", value: username);

    debugPrint("Login successful!");
    Navigator.pushReplacementNamed(context, "/home");
  } else {
    print("Login failed: ${response.body}");
  }
}

Future<void> logout(BuildContext context) async {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  await secureStorage.delete(key: "auth_token");
  await secureStorage.delete(key: "username");

  debugPrint("Logged out successfully!");

  Navigator.pushReplacementNamed(context, "/login");
}


Future<void> signUp(
    String username, String password, BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse("http://192.168.0.114:8000/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => PasskeySetup(
      //             isSignUp: true,
      //             username: username,
      //           )),
      // );
      await signIn(username, password, context);
    } else {
      print("Signup failed: ${response.body}");
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

  final response = await http.post(
    Uri.parse("http://192.168.0.114:8000/refresh"),
    body: jsonEncode({"refresh_token": refreshToken}),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final newAccessToken = data["access_token"];

    // ✅ Update the stored access token
    await secureStorage.write(key: "access_token", value: newAccessToken);

    debugPrint("Access token refreshed!");
    return newAccessToken;
  } else {
    debugPrint("Failed to refresh access token: ${response.body}");
    return null;
  }
}
