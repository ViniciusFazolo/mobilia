import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputDate extends StatefulWidget {
  final String? label;
  final String? hint;
  final bool requiredField;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const InputDate({
    super.key,
    this.label,
    this.hint,
    this.requiredField = true,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<InputDate> createState() => _InputDateState();
}

class _InputDateState extends State<InputDate> {
  String? _errorText;
  final DateFormat _formatter = DateFormat(
    'dd/MM/yyyy',
  ); // 2 dígitos para dia/mês

  String? _validate(String? value) {
    final validator = widget.validator;
    if (validator != null) {
      return validator(value);
    }
    if (widget.requiredField && (value == null || value.isEmpty)) {
      return "Campo obrigatório";
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale("pt", "BR"),
    );
    if (picked != null) {
      final formatted = _formatter.format(picked);
      widget.controller?.text = formatted;
      if (widget.onChanged != null) {
        widget.onChanged!(formatted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true, // impede digitação
      validator: (value) {
        _errorText = _validate(value);
        return _errorText;
      },
      onTap: _pickDate, // abre o calendário
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? "dd/mm/yyyy",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: _errorText,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }
}
