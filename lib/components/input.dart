import 'package:flutter/material.dart';

class AuthInput extends StatelessWidget {
  const AuthInput(
      {super.key,
      required this.controller,
      this.icon,
      this.obscureText,
      this.onChanged,
      this.hintText,
      this.validator});

  final TextEditingController controller;
  final Icon? icon;
  final bool? obscureText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: TextFormField(
        cursorColor: const Color.fromRGBO(75, 204, 178, 1),
        autovalidateMode: AutovalidateMode.always,
        validator: validator,
        controller: controller,
        obscureText: obscureText!,
        obscuringCharacter: '*',
        decoration: InputDecoration(
            prefixIcon: icon,
            prefixIconColor: Colors.grey[800],
            prefixIconConstraints: const BoxConstraints(minWidth: 35),
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[700])),
      ),
    );
  }
}
