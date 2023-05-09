import 'dart:async';

import 'package:flutter/services.dart';

class Localstream {
  static const MethodChannel _channel = MethodChannel('localstream');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<int?> setLocalStream(bool isFront) async {
    final int? textureId = await _channel
        .invokeMethod("setLocalVideoRenderListener", {"isFront": isFront});
    return textureId;
  }
}
