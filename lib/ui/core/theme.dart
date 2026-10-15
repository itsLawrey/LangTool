import 'package:flutter/material.dart';

const _seed = Color(0xFF3F51B5);

ThemeData buildTheme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
  cardTheme: const CardThemeData(margin: EdgeInsets.zero),
);
