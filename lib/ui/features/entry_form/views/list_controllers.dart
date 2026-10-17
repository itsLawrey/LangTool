import 'package:flutter/widgets.dart';

import '../../../../domain/models/entry.dart';

/// A growable list of text fields, e.g. translations, each with its focus
/// node.
class TextListController extends ChangeNotifier {
  TextListController(Iterable<String> initial)
    : _items = [for (final text in initial) TextEditingController(text: text)],
      _focusNodes = [for (final _ in initial) FocusNode()];

  final List<TextEditingController> _items;
  final List<FocusNode> _focusNodes;

  List<TextEditingController> get items => List.unmodifiable(_items);

  /// The focus node of each item, in the order of [items].
  List<FocusNode> get focusNodes => List.unmodifiable(_focusNodes);

  List<String> get values => [for (final c in _items) c.text];

  void add() {
    _items.add(TextEditingController());
    _focusNodes.add(FocusNode());
    notifyListeners();
  }

  /// Removes the item at [index]. Its controller and focus node are
  /// disposed after the next frame, once its field is gone.
  void removeAt(int index) {
    final controller = _items.removeAt(index);
    final node = _focusNodes.removeAt(index);
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
      node.dispose();
    });
  }

  @override
  void dispose() {
    for (final controller in _items) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
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

  /// The focus node of the sentence field.
  final textFocusNode = FocusNode();

  Example get value => Example(text: text.text, translation: translation.text);

  void dispose() {
    text.dispose();
    translation.dispose();
    textFocusNode.dispose();
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

  /// Removes the example at [index]. Its controllers are disposed after
  /// the next frame, once its fields are gone.
  void removeAt(int index) {
    final controllers = _items.removeAt(index);
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => controllers.dispose());
  }

  @override
  void dispose() {
    for (final controllers in _items) {
      controllers.dispose();
    }
    super.dispose();
  }
}
