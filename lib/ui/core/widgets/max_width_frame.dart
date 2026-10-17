import 'dart:math';

import 'package:flutter/material.dart';

/// The app's widest layout, in logical pixels.
const maxAppWidth = 600.0;

/// Shows [child] as a centred column at most [maxAppWidth] wide. The sides
/// have the screens' own background colour, so the column blends into them.
/// Narrower screens are unaffected.
///
/// The column's width is also passed down as the screen width, so drawers,
/// dialogs and snack bars size themselves to it.
class MaxWidthFrame extends StatelessWidget {
  const MaxWidthFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = min(media.size.width, maxAppWidth);
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: width,
          child: MediaQuery(
            data: media.copyWith(size: Size(width, media.size.height)),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
  }
}
