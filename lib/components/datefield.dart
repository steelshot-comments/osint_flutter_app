import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class DateInputField extends StatelessWidget {
  final MaskedTextController _dateController =
      MaskedTextController(mask: '00/00/0000');

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: 'Enter Date (dd/mm/yyyy)'),
    );
  }
}
