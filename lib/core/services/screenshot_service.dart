import 'package:flutter/services.dart';

/// Define a method channel to talk w/ [Android]
class ScreenshotService {
  static const _channel = MethodChannel('screenshot_protection');

  static Future<void> enable() async {
    await _channel.invokeMethod('enable');
  }

  static Future<void> disable() async {
    await _channel.invokeMethod('disable');
  }
}