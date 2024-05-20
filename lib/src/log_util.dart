import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:force_type/force_type.dart';

abstract class LogUtil {
  static void debug(
    dynamic message, {
    String name = 'debug log',
  }) {
    if (kDebugMode) {
      log(
        forceString(message),
        name: name,
      );
    }
  }
}
