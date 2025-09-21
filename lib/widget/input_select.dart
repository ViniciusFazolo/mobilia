import 'package:flutter/material.dart';

class InputSelect<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const InputSelect({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  State<InputSelect<T>> createState() => _InputSelectState<T>();
}

class _InputSelectState<T> extends State<InputSelect<T>> {
  T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant InputSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        _currentValue = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: _currentValue,
      items: widget.items,
      onChanged: (val) {
        setState(() => _currentValue = val);
        if (widget.onChanged != null) widget.onChanged!(val);
      },
      validator:
          widget.validator ??
          (val) {
            if (val == null) return "Campo obrigatório";
            return null;
          },
      autovalidateMode: AutovalidateMode
          .onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}
