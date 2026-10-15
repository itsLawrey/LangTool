import 'package:flutter/widgets.dart';

import '../../../../domain/models/entry.dart';

/// A growable list of text fields, e.g. translations.
class TextListController extends ChangeNotifier {
  TextListController(Iterable<String> initial)
    : _items = [for (final text in initial) TextEditingController(text: text)];

  final List<TextEditingController> _items;

  List<TextEditingController> get items => List.unmodifiable(_items);

  List<String> get values => [for (final c in _items) c.text];

  void add() {
    _items.add(TextEditingController());
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index).dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in _items) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// One example sentence and its optional translation.
class ExampleControllers {
  ExampleControllers([Example? example])
    : text = TextEditingController(text: example?.text),
      translation = TextEditingController(text: example?.translation);

  final TextEditingController text;
  final TextEditingController translation;

  Example get value => Example(text: text.text, translation: translation.text);

  void dispose() {
    text.dispose();
    translation.dispose();
  }
}

/// A growable list of example sentences.
class ExampleListController extends ChangeNotifier {
  ExampleListController(Iterable<Example> initial)
    : _items = [for (final example in initial) ExampleControllers(example)];

  final List<ExampleControllers> _items;

  List<ExampleControllers> get items => List.unmodifiable(_items);

  List<Example> get values => [for (final c in _items) c.value];

  void add() {
    _items.add(ExampleControllers());
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index).dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controllers in _items) {
      controllers.dispose();
    }
    super.dispose();
  }
}
