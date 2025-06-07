//front_client\lib\core\widgets\input_datetime.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputDateTime extends StatefulWidget {
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final String labelText;

  const InputDateTime({
    Key? key,
    this.initialValue,
    required this.onChanged,
    required this.labelText,
  }) : super(key: key);

  @override
  _InputDateTimeState createState() => _InputDateTimeState();
}

class _InputDateTimeState extends State<InputDateTime> {
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _selected ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _selected = combined;
    });
    widget.onChanged(combined);
  }

  @override
  Widget build(BuildContext context) {
    final text = _selected != null
        ? DateFormat.yMd(context.locale.toString()).add_jm().format(_selected!)
        : null;

    return GestureDetector(
      onTap: _pickDateTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          text ?? '',
          style: TextStyle(
            color: _selected != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
