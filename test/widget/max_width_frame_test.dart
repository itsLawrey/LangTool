import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/ui/core/widgets/max_width_frame.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size window) async {
    tester.view.physicalSize = window;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MaxWidthFrame(child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Packs')),
            body: Text('width ${MediaQuery.sizeOf(context).width}'),
          ),
        ),
      ),
    );
  }

  testWidgets('centres the app in a 600 px column on a wide window', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1200, 800));

    final scaffold = tester.getRect(find.byType(Scaffold));
    expect(scaffold.width, 600);
    expect(scaffold.center.dx, 600);
    expect(find.text('width 600.0'), findsOneWidget);
  });

  testWidgets('leaves narrow windows as they are', (tester) async {
    await pumpAt(tester, const Size(360, 800));

    expect(tester.getRect(find.byType(Scaffold)).width, 360);
    expect(find.text('width 360.0'), findsOneWidget);
  });

  testWidgets('the sides match the screens background', (tester) async {
    await pumpAt(tester, const Size(1200, 800));

    final frame = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(MaxWidthFrame),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    final context = tester.element(find.byType(Scaffold));
    expect(frame.color, Theme.of(context).scaffoldBackgroundColor);
  });
}
