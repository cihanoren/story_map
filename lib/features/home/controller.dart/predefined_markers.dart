import 'package:google_maps_flutter/google_maps_flutter.dart';

class PredefinedMarkers {
  static List<Map<String, dynamic>> markers = [
    {
      'position': LatLng(41.008469, 28.980261),
      'title': "Ayasofya Camii",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/ayasofya.png",
      'iconPath': 'assets/markers/mosque.png'
    },
    {
      'position': LatLng(41.0055, 28.9769),
      'title': "Topkapı Sarayı",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/topkapi.png",
      'iconPath': 'assets/markers/palace.png'
    },
    {
      'position': LatLng(41.44061, 31.83312),
      'title': "Gökgöl Mağarası",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/gokgol.jpg",
      'iconPath': 'assets/markers/cave.png'
    },
    {
      'position': LatLng(40.6854, 39.6583),
      'title': "Sümela Manastırı",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/sumela.jpeg",
      'iconPath': 'assets/markers/church.png'
    },
    {
      'position': LatLng(40.6171, 40.7110),
      'title': "Uzungöl",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/uzungol.jpeg",
      'iconPath': 'assets/markers/lake.png'
    },
    {
      'position': LatLng(41.4542, 31.7885),
      'title': "Zonguldak Maden Müzesi",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/maden_m%C3%BCzesi2.jpeg",
      'iconPath': 'assets/markers/museum.png'
    },
    {
      'position': LatLng(41.4515, 31.7843),
      'title': "Cehennemağzı Mağaraları",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/cehennemagzi_magaralari.jpg",
      'iconPath': 'assets/markers/cave.png'
    },
    {
      'position': LatLng(41.005409, 28.976813),
      'title': "Sultanahmet Camii",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/sultan_ahmet_cami.jpg",
      'iconPath': 'assets/markers/mosque.png'
    },
    {
      'position': LatLng(38.6517, 34.8430), // Göreme Milli Parkı düzeltildi
      'title': "Göreme Milli Parkı (Kapadokya)",
      'image': "",
      'iconPath': 'assets/markers/national_park.png'
    },
    {
      'position': LatLng(37.9206, 29.1225), // Pamukkale Travertenleri düzeltildi
      'title': "Pamukkale Travertenleri",
      'image': "",
      'iconPath': 'assets/markers/mountain.png'
    },
    {
      'position': LatLng(37.9413, 27.3360), // Efes Antik Kenti düzeltildi (yaklaşık konum)
      'title': "Efes Antik Kenti",
      'image': "",
      'iconPath': 'assets/markers/ruins.png'
    },
    {
      'position': LatLng(37.8718, 32.5075), // Mevlana Müzesi düzeltildi
      'title': "Mevlana Müzesi (Konya)",
      'image': "",
      'iconPath': 'assets/markers/museum.png'
    },
    {
      'position': LatLng(39.9255, 32.8658), // Anıtkabir düzeltildi
      'title': "Anıtkabir (Ankara)",
      'image': "",
      'iconPath': 'assets/markers/monument.png'
    },
    {
      'position': LatLng(37.0533, 35.5011), // Varda Köprüsü düzeltildi
      'title': "Varda Köprüsü (Adana)",
      'image': "",
      'iconPath': 'assets/markers/bridge.png'
    },
    {
      'position': LatLng(40.0433, 34.6188), // Hattuşa Antik Kenti düzeltildi
      'title': "Hattuşa Antik Kenti (Çorum)",
      'image': "",
      'iconPath': 'assets/markers/ruins.png'
    },
    {
      'position': LatLng(37.9957, 30.8789), // Eğirdir Gölü düzeltildi (gölün merkezi alınmıştır)
      'title': "Eğirdir Gölü (Isparta)",
      'image': "",
      'iconPath': 'assets/markers/lake.png'
    },
    {
      'position': LatLng(41.0067, 40.5247), // Rize Kalesi düzeltildi
      'title': "Rize Kalesi",
      'image': "",
      'iconPath': 'assets/markers/castle.png'
    },
    {
      'position': LatLng(39.2036, 43.3331), // İshak Paşa Sarayı düzeltildi
      'title': "İshak Paşa Sarayı (Ağrı)",
      'image': "",
      'iconPath': 'assets/markers/palace.png'
    }
  ];
}