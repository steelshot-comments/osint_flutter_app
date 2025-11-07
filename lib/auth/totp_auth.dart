part of 'auth_screen.dart';

String generateOtp(String secret) {
  return OTP.generateTOTPCodeString(
      secret, DateTime.now().millisecondsSinceEpoch);
}

Future<void> loginWithTotp(
    String username, String password, String otpCode, BuildContext context) async {
  final response = await Dio().post(
    'http://your-api-url/login',
    data: {
      'username': username,
      'password': password,
      'totp_code': otpCode,
    },
  );

  if (response.statusCode == 200) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreen(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill in all fields")),
    );
  }
}
