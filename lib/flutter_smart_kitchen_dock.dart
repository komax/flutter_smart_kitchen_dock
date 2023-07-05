import 'smart_kitchen_dock_platform_interface.dart';

class SmartKitchenDock {
  Future<String?> getPlatformVersion() {
    return SmartKitchenDockPlatform.instance.getPlatformVersion();
  }

  Stream<Gesture> gestures() {
    return SmartKitchenDockPlatform.instance.gestures();
  }
}
