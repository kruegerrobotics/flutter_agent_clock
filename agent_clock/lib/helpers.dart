import 'package:flutter/material.dart';
import 'dart:math';

//function to map between values
double map(
    double value, double start1, double stop1, double start2, double stop2,
    {bool withinBounds = false}) {
  double newval =
      (value - start1) / (stop1 - start1) * (stop2 - start2) + start2;
  if (!withinBounds) {
    return newval;
  }
  if (start2 < stop2) {
    return newval.clamp(start2, stop2);
  } else {
    return newval.clamp(stop2, start2);
  }
}
//helper to adapt for different screen sizes
//inspired by https://medium.com/flutteropen/canvas-tutorial-01-how-to-use-the-canvas-in-the-flutter-8aade29ddc9

class SizeUtil {
  static const _DESIGN_WIDTH = 640;
  static const _DESIGN_HEIGHT = 384;

  //logic size in device
  static Size _logicSize;

  //device pixel radio.

  static get width {
    return _logicSize.width;
  }

  static get height {
    return _logicSize.height;
  }

  static set size(size) {
    _logicSize = size;
  }

  //@param w is the design w;
  static double getAxisX(double w) {
    return (w * width) / _DESIGN_WIDTH;
  }

// the y direction
  static double getAxisY(double h) {
    return (h * height) / _DESIGN_HEIGHT;
  }

  // diagonal direction value with design size s.
  static double getAxisBoth(double s) {
    return s *
        sqrt((width * width + height * height) /
            (_DESIGN_WIDTH * _DESIGN_WIDTH + _DESIGN_HEIGHT * _DESIGN_HEIGHT));
  }
}