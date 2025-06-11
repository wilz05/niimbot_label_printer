import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NiimbotLabelPrinter {
  final MethodChannel methodChannel = const MethodChannel('niimbot_label_printer');

  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<bool> requestPermissionGrant() async {
    final bool? result = await methodChannel.invokeMethod<bool>('ispermissionbluetoothgranted');
    return result ?? false;
  }

  Future<bool> bluetoothIsEnabled() async {
    final bool? result = await methodChannel.invokeMethod<bool>('isBluetoothEnabled');
    return result ?? false;
  }

  Future<bool> isConnected() async {
    final bool? result = await methodChannel.invokeMethod<bool>('isConnected');
    return result ?? false;
  }

  /// Returns bluetooth paired devices (stubbed for iOS)
  Future<List<BluetoothDevice>> getPairedDevices() async {
    if (Platform.isIOS) {
      return [];
    }
    final List<Object?>? result = await methodChannel.invokeMethod<List<Object?>?>('getPairedDevices');
    List<BluetoothDevice> devices = [];
    for (Object? o in result!) {
      devices.add(BluetoothDevice.fromString(o.toString()));
    }
    return devices;
  }

  Future<bool> connect(BluetoothDevice device) async {
    final bool? result = await methodChannel.invokeMethod<bool>('connect', device.address);
    return result ?? false;
  }

  Future<bool> disconnect() async {
    final bool? result = await methodChannel.invokeMethod<bool>('disconnect');
    return result ?? false;
  }

  Future<bool> send(PrintData data) async {
    final bool? result = await methodChannel.invokeMethod<bool>('send', data.toMap());
    return result ?? false;
  }

  Future<Map<String, dynamic>?> getRfid() async {
    final result = await methodChannel.invokeMethod('getRfid');
    if (result == null) return null;
    final casted = Map<String, dynamic>.from(result as Map);
    return casted;
  }

  Future<Map<String, dynamic>> heartbeat() async {
    final result = await methodChannel.invokeMethod('heartbeat');
    final casted = Map<String, dynamic>.from(result as Map);
    return casted;
  }

  static Future<ui.Image> rotateImage(ui.Image image, double grades) async {
    double angleInRadians = grades * (math.pi / 180);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final double longestSide = math.max(image.width, image.height).toDouble();
    final size = Size(longestSide, longestSide);

    final double halfWidth = image.width / 2;
    final double halfHeight = image.height / 2;

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angleInRadians);
    canvas.drawImage(image, Offset(-halfWidth, -halfHeight), Paint());

    final picture = recorder.endRecording();
    final rotatedImage = await picture.toImage(size.width.toInt(), size.height.toInt());

    return rotatedImage;
  }
}

class BluetoothDevice {
  late String name;
  late String address;

  BluetoothDevice({
    required this.name,
    required this.address,
  });

  BluetoothDevice.fromString(String string) {
    List<String> list = string.split('#');
    name = list[0];
    address = list[1];
  }

  BluetoothDevice.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    address = map['address'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
    };
  }
}

class PrintData {
  late List<int> data;
  late int width;
  late int height;
  late bool rotate;
  late bool invertColor;
  late int density;
  late int labelType;

  PrintData({
    required this.data,
    required this.width,
    required this.height,
    required this.rotate,
    required this.invertColor,
    required this.density,
    required this.labelType,
  });

  PrintData.fromMap(Map<String, dynamic> map) {
    data = map['bytes'];
    width = map['width'];
    height = map['height'];
    rotate = map['rotate'];
    invertColor = map['invertColor'];
    density = map['density'];
    labelType = map['labelType'];
  }

  Map<String, dynamic> toMap() {
    List<int> bytes = data;
    if (bytes.runtimeType == Uint8List) {
      bytes = bytes.toList();
    }
    return {
      'bytes': bytes,
      'width': width,
      'height': height,
      'rotate': rotate,
      'invertColor': invertColor,
      'density': density,
      'labelType': labelType,
    };
  }
}
