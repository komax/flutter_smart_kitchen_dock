import Cocoa
import FlutterMacOS
import ExternalAccessory
import AppKit
import Combine


final public class ExternalAccessoryKitchenDock: NSObject, StreamDelegate {
    private let manager: EAAccessoryManager
    private let protocolString = "com.smartkitchendock.protocol2"
    private var cancellables = Set<AnyCancellable>()
    private let connectionSubject: CurrentValueSubject<Bool, Never>
    public let gestureSubject: PassthroughSubject<Gesture, Never>
    private var session: EASession?

    public static let shared = ExternalAccessoryKitchenDock()

    private init(manager: EAAccessoryManager = .shared()) {
        print("initing")
        self.manager = manager
        self.connectionSubject = CurrentValueSubject(false)
        self.gestureSubject = PassthroughSubject()
        super.init()
        self.registerForLocalNotifications()
    }

    deinit {
        manager.unregisterForLocalNotifications()
    }

    // MARK: - Public interface

    public func connectIfNecessary() {
        guard let accessory = self.connectedAccessory else {
            updateConnectionStatus()
            return
        }
        openInputStream(for: accessory)
    }

    public func connectionPublisher() -> AnyPublisher<Bool, Never> {
        connectionSubject.removeDuplicates().eraseToAnyPublisher()
    }

    public func gesturePublisher() -> AnyPublisher<Gesture, Never> {
        gestureSubject.eraseToAnyPublisher()
    }

    // MARK: - Private Helpers

    private func registerForLocalNotifications() {
        print("REgistered")
        manager.registerForLocalNotifications()

        NotificationCenter.default.publisher(for: .EAAccessoryDidConnect)
        .sink { [weak self] _ in
            self?.connectIfNecessary()
        }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .EAAccessoryDidDisconnect)
        .sink { [weak self] _ in
            self?.updateConnectionStatus()
        }
        .store(in: &cancellables)
    }

    private var connectedAccessory: EAAccessory? {
        print("connected? \(manager.connectedAccessories)")
        return manager.connectedAccessories.first(where: { $0.protocolStrings.contains(protocolString) })
    }

    public func resume() {
        connectIfNecessary()
    }

    public func pause() {
        session?.inputStream?.close()
        session?.inputStream?.remove(from: .current, forMode: .default)
        session?.inputStream?.delegate = nil
        session?.outputStream?.close()
        session = nil
    }

    private func openInputStream(for accessory: EAAccessory) {
        session = EASession(accessory: accessory, forProtocol: self.protocolString)
        session?.inputStream?.delegate = self
        session?.inputStream?.schedule(in: .current, forMode: .default)
        session?.inputStream?.open()
    }

    private func closeStream(_ stream: Stream) {
        stream.close()
        stream.remove(from: .current, forMode: .default)
        stream.delegate = nil
    }

    private func updateConnectionStatus() {
        connectionSubject.value = session?.inputStream?.streamStatus == .open
    }

    private func readData(from stream: InputStream) -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        let bytesRead = stream.read(buffer, maxLength: 1024)
        var readData = Data()
        readData.append(buffer, count: bytesRead)
        return readData
    }

    // MARK: - StreamDelegate

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch (aStream, eventCode) {
        case (let inputStream as InputStream, .hasBytesAvailable):
            print(inputStream)
            let readData = readData(from: inputStream)
            print("Just read \(readData)")
            if let gesture = Gesture.decode(from: readData) {
                print(gesture.rawValue)
                gestureSubject.send(gesture)
            }
        case (_, .endEncountered), (_, .errorOccurred):
            closeStream(aStream)
            updateConnectionStatus()
        case (_, .openCompleted):
            updateConnectionStatus()
        default:
            break
        }
    }

    public func sendTest() {
        gestureSubject.send(Gesture(rawValue: "LEFT")!)
    }
}

extension ExternalAccessoryKitchenDock {
    public enum Gesture: String {
        case up = "UP"
        case down = "DOWN"
        case left = "LEFT"
        case right = "RIGHT"

        static func decode(from data: Data) -> Gesture? {
            let headerSize = 10
            let messageSize = Int(data[3])
            let range = headerSize..<messageSize
            let messageData = data.subdata(in: range)
            let string = String(data: messageData, encoding: .utf8)
            let gesture = Gesture(rawValue: string ?? "")
            return gesture
        }
    }
}


public class SmartKitchenDockPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let dock: ExternalAccessoryKitchenDock = ExternalAccessoryKitchenDock.shared
  public var eventChannel: FlutterEventChannel
  private var eventSink: FlutterEventSink? = nil

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "smart_kitchen_dock", binaryMessenger: registrar.messenger)
    let instance = SmartKitchenDockPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  init(registrar: FlutterPluginRegistrar) {
    eventChannel = FlutterEventChannel(name: "smart_kitchen_dock_events", binaryMessenger: registrar.messenger)
    super.init()
    eventChannel.setStreamHandler(self)
  }

  func publishEvent(_ event: [String: Any?]) {
    print("publishing \(event)")
    eventSink?(event)
  }

    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        print("swift on listen")
        var cancellables = Set<AnyCancellable>()
        self.eventSink = eventSink
        dock.resume();
        dock.gesturePublisher()
        .sink { [weak self] gesture in
            self?.publishEvent(["type": "gesture", "data": gesture.rawValue])
        }
        .store(in: &cancellables)
        dock.sendTest();
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("Swift: removing listener")
        eventSink = nil
        dock.pause();
        return nil
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
