import 'package:flutter/services.dart';

import 'flutter_nos_platform_interface.dart';

typedef OnUploadResult = Function(String message);

class FlutterNos {
  FlutterNos({this.onSuccess, this.onFailure});

  OnUploadResult? onSuccess;

  OnUploadResult? onFailure;

  EventChannel eventChannel = const EventChannel("flutter_nos_event");

  Future<void> init({Map<String, Object>? config}) {
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
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
