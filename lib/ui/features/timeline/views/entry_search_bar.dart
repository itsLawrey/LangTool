import 'package:flutter/material.dart';

class EntrySearchBar extends StatefulWidget {
  const EntrySearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<EntrySearchBar> createState() => _EntrySearchBarState();
}

class _EntrySearchBarState extends State<EntrySearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) => SearchBar(
    controller: _controller,
    hintText: 'Search term or translation',
    leading: const Icon(Icons.search),
    trailing: [
      ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _controller.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close),
                onPressed: _clear,
              ),
      ),
    ],
    onChanged: widget.onChanged,
  );
}
