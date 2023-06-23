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


  //Future<void> streamData() async {
    //print(FlutterBluePlus.instance.state);
    //FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

    //flutterBlue.startScan(timeout: Duration(seconds: 4));

    //var subscription = flutterBlue.scanResults.listen((results) {
    //// do something with scan results
      //for (ScanResult r in results) {
        //print('${r.device.name} found! rssi: ${r.rssi}');
      //}
    //});

    //await Future.delayed(const Duration(seconds: 200), (){});
    //// Stop scanning
    //flutterBlue.stopScan();
  //}
}
