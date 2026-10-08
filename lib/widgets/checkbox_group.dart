import 'package:flutter/material.dart';

class CheckboxGroup extends StatelessWidget {
  const CheckboxGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.subtitles = const {},
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final Map<String, String> subtitles;

  void _toggle(String option, bool? checked) {
    final next = Set<String>.from(selected);
    if (checked == true) {
      next.add(option);
    } else {
      next.remove(option);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in options)
          CheckboxListTile(
            value: selected.contains(option),
            onChanged: (checked) => _toggle(option, checked),
            title: Text(option),
            subtitle: subtitles[option] == null
                ? null
                : Text(subtitles[option]!),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
      ],
    );
  }
}
