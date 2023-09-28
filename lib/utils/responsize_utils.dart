// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ResponsiveUtil {
  static double get heightVar =>
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
  static double get widthVar =>
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
}
