import 'package:flutter/material.dart';

const gradient = LinearGradient(
  colors: [Color(0xff8a2387), Color(0xffe94057), Color(0xfff27121)],
  stops: [0, 0.5, 1],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
ThemeData appThemeData = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Inter',
  useMaterial3: true,
  primaryColor: Color(0xff8a2387),
  primaryColorLight: Color(0xff8a2387),
  primaryColorDark: Color(0xfff27121),
  scaffoldBackgroundColor: Colors.white,
);
