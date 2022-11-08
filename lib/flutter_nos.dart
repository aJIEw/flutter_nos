import 'package:flutter/services.dart';

import 'flutter_nos_platform_interface.dart';

typedef OnUploadResult = Function(String message);

class FlutterNos {
  FlutterNos({this.onSuccess, this.onFailure});

  /// 图片上传成功后的回调
  OnUploadResult? onSuccess;

  /// 失败回调，只支持安卓
  OnUploadResult? onFailure;

  final EventChannel _eventChannel = const EventChannel("flutter_nos_event");

  Future<void> init({Map<String, Object>? config}) {
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    return FlutterNosPlatform.instance.init(config);
  }

  Future<void> uploadImage(
      String bucketName, String objName, String uploadToken, String imagePath) {
    return FlutterNosPlatform.instance
        .uploadImage(bucketName, objName, uploadToken, imagePath);
  }

  void setOnSuccess(OnUploadResult onSuccess) {
    this.onSuccess = onSuccess;
  }

  /// 目前只支持安卓
  void setOnFailure(OnUploadResult onFailure) {
    this.onFailure = onFailure;
  }

  void _onEvent(dynamic event) {
    String method = event['method'];
    switch (method) {
      case "onSuccess":
        if (onSuccess != null) {
          String message = event['message'];
          onSuccess!(message);
        }
        break;
      case "onFailure":
        if (onFailure != null) {
          String message = event['message'];
          onFailure!(message);
        }
        break;
    }
  }

  void _onError(dynamic error) {}
}
