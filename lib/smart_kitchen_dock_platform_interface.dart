import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'smart_kitchen_dock_method_channel.dart';

enum Gesture {
  up,
  down,
  left,
  right
}

abstract class SmartKitchenDockPlatform extends PlatformInterface {
  /// Constructs a SmartKitchenDockPlatform.
  SmartKitchenDockPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmartKitchenDockPlatform _instance = MethodChannelSmartKitchenDock();

  /// The default instance of [SmartKitchenDockPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmartKitchenDock].
  static SmartKitchenDockPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmartKitchenDockPlatform] when
  /// they register themselves.
  static set instance(SmartKitchenDockPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> startListening() {
    throw UnimplementedError('startListening() has not been implemented.');
  }

  Stream<Gesture> gestures() {
    throw UnimplementedError('startListening() has not been implemented.');
  }

  Future<String?> stopListening() {
    throw UnimplementedError('stopListening() has not been implemented.');
  }
}
