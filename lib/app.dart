import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'routing/router.dart';
import 'ui/core/theme.dart';

class LangToolApp extends StatefulWidget {
  const LangToolApp({super.key});

  @override
  State<LangToolApp> createState() => _LangToolAppState();
}

class _LangToolAppState extends State<LangToolApp> {
  late final GoRouter _router = buildRouter(context.read<AuthRepository>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'LangTool',
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    routerConfig: _router,
  );
}
