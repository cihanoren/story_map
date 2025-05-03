import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String name;
  final String image;
  final double lat;
  final double lng;

  Place({
    required this.name,
    required this.image,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'lat': lat,
        'lng': lng,
      };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        name: json['name'],
        image: json['image'],
        lat: json['lat'],
        lng: json['lng'],
      );
}

class RouteModel {
  final String id;  // Firestore'dan gelen id
  final String userId;
  final String title;
  final String description;
  final List<Place> places;  // List<Place> olarak değiştirildi
  final String mode;
  final bool isShared;
  final Timestamp createdAt;

  RouteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.places,
    required this.mode,
    required this.isShared,
    required this.createdAt,
  });

  // Firestore veri modeline dönüştürme
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'places': places.map((place) => place.toJson()).toList(),  // places verisini JSON formatına dönüştürme
        'mode': mode.isNotEmpty ? mode : 'walking',  // Varsayılan değer
        'isShared': isShared,
        'createdAt': createdAt,
      };

  // Firestore'dan gelen veriyi RouteModel'e dönüştürme
  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'] ?? '',  // id alındı
        userId: json['userId'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        places: List<Place>.from(
            json['places'].map((place) => Place.fromJson(place))),  // places'leri doğru şekilde dönüştür
        mode: json['mode'] ?? 'walking',
        isShared: json['isShared'] ?? false,
        createdAt: json['createdAt'] as Timestamp,  // Firestore Timestamp tipi
      );
  
  // Firestore'dan gelen veriyi RouteModel'e dönüştürürken tarihleri DateTime'a dönüştür
  DateTime get createdAtDate => createdAt.toDate();
}
