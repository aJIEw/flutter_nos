import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_nos_method_channel.dart';

abstract class FlutterNosPlatform extends PlatformInterface {
  /// Constructs a FlutterNosPlatform.
  FlutterNosPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNosPlatform _instance = MethodChannelFlutterNos();

  /// The default instance of [FlutterNosPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNos].
  static FlutterNosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNosPlatform] when
  /// they register themselves.
  static set instance(FlutterNosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(Map<String, Object>? config) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> uploadImage(
      String bucketName, String objName, String uploadToken, String imagePath) {
    throw UnimplementedError('init() has not been implemented.');
  }
}
