import Flutter
import UIKit

public class NiimbotLabelPrinterPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel?
    let manager = JCAPIManager.sharedInstance()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "niimbot_label_printer", binaryMessenger: registrar.messenger())
        let instance = NiimbotLabelPrinterPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "connect":
            // SDK usually auto-connects on scan; assume it initializes here
            manager?.startScan()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let device = self.manager?.connectedPeripheral {
                    print("✅ Connected to printer: \(device.name ?? "")")
                    result(true)
                } else {
                    result(FlutterError(code: "not_connected", message: "No printer found", details: nil))
                }
            }

        case "isConnected":
            result(manager?.connectedPeripheral != nil)

        case "getBatteryLevel":
            let battery = manager?.getDeviceBattery() ?? -1
            result(battery)

        case "getRfidInfo":
            if let info = manager?.getRFIDInfo() {
                let dict: [String: Any] = [
                    "barcode": info.barcode ?? "",
                    "serial": info.serial ?? "",
                    "used_len": info.usedLength,
                    "total_len": info.totalLength,
                    "type": info.type
                ]
                result(dict)
            } else {
                result(FlutterError(code: "no_rfid", message: "RFID not available", details: nil))
            }

        case "printLabel":
            guard let args = call.arguments as? [String: Any],
                  let byteData = args["bytes"] as? FlutterStandardTypedData,
                  let image = UIImage(data: byteData.data) else {
                result(FlutterError(code: "invalid_data", message: "Missing or invalid image data", details: nil))
                return
            }

            let printConfig = JCPrintConfig()
            printConfig.density = 3
            printConfig.labelType = 1
            printConfig.width = Int32(image.size.width)
            printConfig.height = Int32(image.size.height)

            manager?.printImage(image, config: printConfig) { success in
                result(success)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
