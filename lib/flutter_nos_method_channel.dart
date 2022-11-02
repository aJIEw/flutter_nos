import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_nos_platform_interface.dart';

/// An implementation of [FlutterNosPlatform] that uses method channels.
class MethodChannelFlutterNos extends FlutterNosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_nos');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> init(Map<String, Object>? config) async {
    methodChannel.invokeMethod('init', config);
  }

  @override
  Future<void> uploadImage(String bucketName, String objName,
      String uploadToken, String imagePath) async {
    var argument = {
      "bucketName": bucketName,
      "objName": objName,
      "uploadToken": uploadToken,
      "imagePath": imagePath,
    };
    methodChannel.invokeMethod('uploadImage', argument);
  }
}
