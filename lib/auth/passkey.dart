part of 'login.dart';

class PasskeySetup extends StatefulWidget {
  const PasskeySetup({super.key, required this.isSignUp, required this.username});
  final bool isSignUp;
  final String username;

  @override
  _PasskeySetupState createState() => _PasskeySetupState();
}

class _PasskeySetupState extends State<PasskeySetup> {
  bool _isLoading = false;
  String statusMessage = "";


  Future<void> handlePasskeyAction() async {
  checkIfPasskeysWorks();
    setState(() {
      _isLoading = true;
      statusMessage = "Processing...";
    });

    try {
      if (widget.isSignUp) {
        await startPasskeyRegistration(widget.username);
        statusMessage = "Passkey registered successfully!";
      } else {
        await loginWithPasskey("username");
        statusMessage = "Login successful with Passkey!";
      }
    } catch (e) {
      statusMessage = "Error: ${e.toString()}";
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  statusMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            SquircleButton(
              textColor: Colors.white,
              gradient: const LinearGradient(colors: [
                Color.fromRGBO(46, 140, 109, 1),
                Color.fromRGBO(121, 191, 172, 1),
              ]),
              onTap: _isLoading ? (){} : handlePasskeyAction,
              title: widget.isSignUp ? "Register Passkey" : "Login with Passkey",
            ),
          ],
        ),
      ),
    );
  }
}
