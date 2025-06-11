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
           print("📦 [iOS] getPlatformVersion called")
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
            case "isBluetoothEnabled":
                // iOS assumes Bluetooth is enabled if CoreBluetooth is available
                result(true)

            case "getPairedDevices":
                // iOS does not expose paired list; stub empty array
                result([])
        case "disconnect":
            manager?.disConnectPeripheral()
            result(true)
        case "isConnected":
            result(manager?.connectedPeripheral != nil)
        case "heartbeat":
            let status = manager?.getDeviceStatus()
            let response: [String: Any] = [
                "closing_state": status?.isCoverOpen ?? false,
                "power_level": status?.batteryLevel ?? -1,
                "paper_state": status?.isPaperPresent ?? false,
                "rfid_read_state": status?.canReadRFID ?? false
            ]
            result(response)
        case "ispermissionbluetoothgranted":
            // iOS handles permissions via Info.plist and system prompts
            result(true)
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
