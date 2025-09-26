import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatefulWidget {
  final String? label;
  final String? hint;
  final bool obscureText;
  final bool requiredField; // nova flag
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(bool)? onFocusChange;

  const Input({
    super.key,
    this.label,
    this.hint,
    this.obscureText = false,
    this.requiredField = true, // padrão é obrigatório
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onFocusChange,
    this.inputFormatters,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (widget.onFocusChange != null) {
        widget.onFocusChange!(_focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: widget.inputFormatters,
      validator: (value) {
        _errorText = _validate(value);
        return _errorText;
      },
      onChanged: (value) {
        if (_errorText != null) {
          setState(() {
            _errorText = null;
          });
        }
        if (widget.onChanged != null) widget.onChanged!(value);
      },
      focusNode: _focusNode,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: _errorText,
      ),
    );
  }
}
