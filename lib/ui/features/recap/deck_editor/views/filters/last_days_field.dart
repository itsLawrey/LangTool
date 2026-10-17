import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The number of days for "In the last N days".
class LastDaysField extends StatefulWidget {
  const LastDaysField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final int? initialValue;

  /// Called with the entered number, or `null` if there is none.
  final ValueChanged<int?> onChanged;

  @override
  State<LastDaysField> createState() => _LastDaysFieldState();
}

class _LastDaysFieldState extends State<LastDaysField> {
  late final _controller = TextEditingController(
    text: widget.initialValue?.toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = int.tryParse(_controller.text);
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Days',
        errorText: days == null || days < 1 ? 'Enter 1 or more.' : null,
      ),
      onChanged: (text) {
        setState(() {});
        widget.onChanged(int.tryParse(text));
      },
    );
  }
}
