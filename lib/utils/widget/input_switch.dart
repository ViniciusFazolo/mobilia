import 'package:flutter/material.dart';

class InputSwitch extends StatefulWidget {
  final String? label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final void Function(bool)? onFocusChange;

  const InputSwitch({
    super.key,
    this.label,
    required this.value,
    this.onChanged,
    this.onFocusChange,
  });

  @override
  State<InputSwitch> createState() => _InputSwitchState();
}

class _InputSwitchState extends State<InputSwitch> {
  late bool _currentValue;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
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

  void _toggleSwitch(bool newValue) {
    setState(() {
      _currentValue = newValue;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        spacing: 10,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Focus(
            focusNode: _focusNode,
            child: Align(
              alignment: Alignment.centerLeft, // <-- switch na esquerda
              child: Switch(
                value: _currentValue,
                onChanged: _toggleSwitch,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
