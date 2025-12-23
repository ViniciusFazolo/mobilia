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

/// Aplica a máscara de CPF a um texto contendo apenas dígitos
String applyCpfMask(String digits) {
  if (digits.length > 11) digits = digits.substring(0, 11);
  if (digits.isEmpty) return '';
  
  if (digits.length <= 3) {
    return digits;
  } else if (digits.length <= 6) {
    return '${digits.substring(0, 3)}.${digits.substring(3)}';
  } else if (digits.length <= 9) {
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6)}';
  } else {
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }
}

/// Aplica a máscara de telefone a um texto contendo apenas dígitos
String applyTelefoneMask(String digits) {
  if (digits.length > 11) digits = digits.substring(0, 11);
  if (digits.isEmpty) return '';
  
  if (digits.length <= 2) {
    return '($digits';
  } else if (digits.length <= 7) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
  } else {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
  }
}