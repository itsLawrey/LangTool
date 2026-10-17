import 'package:flutter/material.dart';

import '../../view_models/filters/added_filter_editor.dart';
import 'date_field.dart';
import 'filter_section.dart';
import 'last_days_field.dart';

/// Filter on when entries were added: any time, between two dates, or in
/// the last N days.
class AddedFilterSection extends StatelessWidget {
  const AddedFilterSection({super.key, required this.editor});

  final AddedFilterEditor editor;

  static String _modeLabel(AddedMode mode) => switch (mode) {
    AddedMode.anyTime => 'Any time',
    AddedMode.between => 'Between dates',
    AddedMode.lastDays => 'In the last N days',
  };

  static String _presetLabel(AddedPreset preset) => switch (preset) {
    AddedPreset.today => 'Today',
    AddedPreset.last7Days => 'Last 7 days',
    AddedPreset.last30Days => 'Last 30 days',
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) => FilterSection(
      title: 'Added',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final mode in AddedMode.values)
                ChoiceChip(
                  label: Text(_modeLabel(mode)),
                  selected: editor.mode == mode,
                  onSelected: (_) => editor.setMode(mode),
                ),
            ],
          ),
          ...switch (editor.mode) {
            AddedMode.anyTime => const <Widget>[],
            AddedMode.between => _between(),
            AddedMode.lastDays => [
              LastDaysField(
                initialValue: editor.lastDays,
                onChanged: editor.setLastDays,
              ),
            ],
          },
        ],
      ),
    ),
  );

  List<Widget> _between() => [
    Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final preset in AddedPreset.values)
          ActionChip(
            label: Text(_presetLabel(preset)),
            onPressed: () => editor.applyPreset(preset),
          ),
      ],
    ),
    DateField(
      label: 'From',
      value: editor.from,
      today: editor.today,
      lastDate: editor.to,
      onChanged: editor.setFrom,
    ),
    DateField(
      label: 'To',
      value: editor.to,
      today: editor.today,
      firstDate: editor.from,
      onChanged: editor.setTo,
    ),
  ];
}
