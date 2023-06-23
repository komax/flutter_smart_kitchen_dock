# smart_kitchen_dock

Flutter plugin used to receive messsages from smart kitchen dock devices

## Quick Start 🚀 #

```dart
final smartKitchenDock = SmartKitchenDock();

// listen to gesture messageSize
final subscription = smartKitchenDock.gestures().listen((gesture) {
    if (gesture == Gesture.down) {
        // scroll down
    }
});

// stop listening to messages
subscription.cancel()
```

## Setup

### ios
Make sure the `Supported external accessory protocols` info plist contains the
smart kitchen dock protocol string `com.smartkitchendock.protocol2`
