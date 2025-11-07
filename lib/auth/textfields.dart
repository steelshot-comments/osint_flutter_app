part of 'auth_screen.dart';

class AuthInputs extends StatefulWidget {
  const AuthInputs(
      {super.key,
      required this.usernameController,
      this.emailController,
      required this.passwordController});

  // mark usernameController as nullable
  final TextEditingController usernameController;
  final TextEditingController? emailController;
  final TextEditingController passwordController;

  @override
  State<AuthInputs> createState() => _AuthInputsState();
}

class _AuthInputsState extends State<AuthInputs> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // show email field only if emailController is not null
      // fix null check operator used on a null value
      if (widget.emailController != null)
        AuthInput(
            controller: widget.emailController!,
            icon: const Icon(Icons.mail_rounded),
            obscureText: false,
            hintText: 'johndoe@company.field.in',),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Divider(
            color: Color.fromRGBO(75, 204, 178, 1),
            height: 1,
            thickness: 1,
          ),
        ),
      AuthInput(
        controller: widget.usernameController,
        icon: Icon(Icons.person_search_rounded),
        obscureText: false,
        hintText: 'Display name',
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
