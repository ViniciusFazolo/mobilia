import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final onlyDigitsWithDecimal = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));
final onlyDigits = FilteringTextInputFormatter.digitsOnly;

final cpfMask = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: { "#": RegExp(r'[0-9]') },
);

final telefoneMask = MaskTextInputFormatter(
  mask: '(##) #####-####',
  filter: { "#": RegExp(r'[0-9]') },
);