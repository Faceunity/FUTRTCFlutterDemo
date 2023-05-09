import Flutter
import UIKit

public class SwiftLocalstreamPlugin: NSObject, FlutterPlugin {
    private var entry:LocalStreamEntry?
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "localstream", binaryMessenger: registrar.messenger())
        let instance = SwiftLocalstreamPlugin()
        
        instance.entry = LocalStreamEntry(registrar: registrar);
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.isEqual("getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else {
            entry?.handle(call, result: result);
        }
    }
}
