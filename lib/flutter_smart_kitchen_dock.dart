import 'smart_kitchen_dock_platform_interface.dart';

class SmartKitchenDock {
  Future<String?> getPlatformVersion() {
    return SmartKitchenDockPlatform.instance.getPlatformVersion();
  }

  Future<String?> startListening() {
    return SmartKitchenDockPlatform.instance.startListening();
  }

  Future<String?> stopListening() {
    return SmartKitchenDockPlatform.instance.stopListening();
  }

  Stream<Gesture> gestures() {
    return SmartKitchenDockPlatform.instance.gestures();
  }
}
