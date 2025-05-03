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
  final String id; // Bu değer Firestore'dan alınabilir
  final String userId;
  final String title;
  final String description;
  final List<Place> places;  // Burada List<Map<String, dynamic>> yerine List<Place> kullandık
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'places': places.map((place) => place.toJson()).toList(),  // places verilerini JSON formatına dönüştürdük
        'mode': mode.isNotEmpty ? mode : 'walking',  // Eğer mode boşsa 'walking' olarak ayarlıyoruz
        'isShared': isShared,
        'createdAt': createdAt,
      };

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        description: json['description'],
        places: List<Place>.from(
            json['places'].map((place) => Place.fromJson(place))),  // places verisini doğru şekilde dönüştürüyoruz
        mode: json['mode'],
        isShared: json['isShared'],
        createdAt: json['createdAt'],
      );
}
