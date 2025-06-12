import Flutter
import UIKit

public class NiimbotLabelPrinterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "niimbot_label_printer", binaryMessenger: registrar.messenger())
    let instance = NiimbotLabelPrinterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {

    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "connect":
      if let address = call.arguments as? String {
        JCAPI.openPrinter(address) { success in
          print("🔌 connect result: \(success)")
          result(success)
        }
      } else {
        result(FlutterError(code: "invalid_args", message: "Missing printer address", details: nil))
      }

    case "disconnect":
      print("🛑 disconnect called")
      JCAPI.closePrinter()
      print("🛑 disconnect complete")
      result(true)

    case "isConnected":
      let connected = JCAPI.isConnectingState() != 0
      print("🔗 isConnected = \(connected)")
      result(connected)

    case "isBluetoothEnabled":
      print("📶 isBluetoothEnabled called (stubbed true)")
      result(true)

    case "ispermissionbluetoothgranted":
      print("🔐 ispermissionbluetoothgranted called")
      result(true)

    case "getPairedDevices":
      print("📱 getPairedDevices called (iOS cannot list paired devices)")
      result([])

    case "getRfid":
      print("📡 getRfid called")
      result(["rfid": "dummy_value"]) // TODO: implement JCAPI.getRfidInfo

    case "heartbeat":
      print("💓 heartbeat called")
      JCAPI.getPrintStatusChange { status in
        if let statusDict = status as? [String: Any] {
          result(statusDict)
        } else {
          result(["status": "unknown"])
        }
      }

    case "send":
      print("🖨️ send called")
      guard let args = call.arguments as? [String: Any],
            let byteData = args["bytes"] as? FlutterStandardTypedData,
            let image = UIImage(data: byteData.data),
            let cgImage = image.cgImage,
            let provider = cgImage.dataProvider,
            let pixelData = provider.data else {
        result(FlutterError(code: "invalid_image", message: "Image conversion failed", details: nil))
        return
      }

      let width = UInt32(cgImage.width)
      let height = UInt32(cgImage.height)
      let rawData = pixelData as Data

      JCAPI.setTotalQuantityOfPrints(1)
      JCAPI.initDrawingBoard(50, withHeight: 30, withHorizontalShift: 0, withVerticalShift: 0, rotate: 0, fontArray: [])

      JCAPI.drawLableImage(
        2,
        withY: 2,
        withWidth: Float((width / 8)),
        withHeight: Float((height / 8)),
        withImageData: rawData.base64EncodedString(),
        withRotate: 0,
        withImageProcessingType: 1,
        withImageProcessingValue: 127
      )

      let json = JCAPI.generateLableJson() ?? ""
      JCAPI.commit(json, withOnePageNumbers: 1) { isSuccess in
        print("🖨️ commit print success: \(isSuccess)")
        result(isSuccess)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
