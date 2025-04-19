import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIcons {
  static BitmapDescriptor? churchIcon;
  static BitmapDescriptor? caveIcon;
  static BitmapDescriptor? palaceIcon;
  static BitmapDescriptor? castleIcon;
  static BitmapDescriptor? mosqueIcon;
  static BitmapDescriptor? museumIcon;

  // PNG ikonlarını yükle ve cachele
  static Future<void> loadIcons() async {
    churchIcon = await getBitmapDescriptor('assets/markers/church.png');
    caveIcon = await getBitmapDescriptor('assets/markers/cave.png');
    palaceIcon = await getBitmapDescriptor('assets/markers/palace.png');
    castleIcon = await getBitmapDescriptor('assets/markers/castle.png');
    mosqueIcon = await getBitmapDescriptor('assets/markers/mosque.png');
    museumIcon = await getBitmapDescriptor('assets/markers/museum.png');
  }

  // PNG dosyasını BitmapDescriptor'a dönüştür
  static Future<BitmapDescriptor> getBitmapDescriptor(String assetPath) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: 90, // İkon boyutunu buradan ayarlayabilirsin
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
