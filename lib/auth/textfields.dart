part of 'login.dart';

class AuthInputs extends StatefulWidget {
  const AuthInputs(
      {super.key,
      required this.usernameController,
      required this.emailController,
      required this.passwordController});

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<AuthInputs> createState() => _AuthInputsState();
}

class _AuthInputsState extends State<AuthInputs> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Visibility(
        visible: true,
        child: Column(
          children: [
            AuthInput(
                controller: widget.usernameController,
                icon: const Icon(Icons.person_search_rounded),
                obscureText: false,
                hintText: 'Display name'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Color.fromRGBO(75, 204, 178, 1),
                height: 1,
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
      AuthInput(
        controller: widget.emailController,
        icon: Icon(Icons.mail_rounded),
        obscureText: false,
        hintText: 'johndoe@company.field.in',
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Divider(
          color: Color.fromRGBO(75, 204, 178, 1),
          height: 1,
          thickness: 1,
        ),
      ),
      AuthInput(
        controller: widget.passwordController,
        icon: const Icon(Icons.lock_rounded),
        obscureText: true,
        hintText: 'Password',
      ),
    ]);
  }
}
