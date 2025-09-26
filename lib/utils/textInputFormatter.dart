import 'package:flutter/services.dart';

final onlyDigitsWithDecimal = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));
final onlyDigits = FilteringTextInputFormatter.digitsOnly;