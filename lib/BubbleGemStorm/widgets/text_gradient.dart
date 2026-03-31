import 'package:flutter/material.dart';

import '../utils/constants.dart';

Widget gradientText(
  List<Color> color,
  String text, {
  double fontsize = 32,
  FontWeight fontweight = FontWeight.bold,
  double? height,
  double? letterSpacing = -6,
}) {
  return ShaderMask(
    shaderCallback: (bounds) => LinearGradient(
      colors: color,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.6, 0.95],
    ).createShader(bounds),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        shadows: [
          BoxShadow(
            offset: Offset(0, 10),
            blurRadius: 20,
            color: title2.withValues(alpha: 0.3),
          ),
        ],
        fontSize: fontsize,
        fontWeight: fontweight,
        color: Colors.white,
        height: height,
        fontFamily: 'Baloo2',
        letterSpacing: letterSpacing,
      ),
    ),
  );
}
