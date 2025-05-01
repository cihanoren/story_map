import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<Map<String, dynamic>> places; // her yerin lat, lng, name, image gibi bilgileri
  final String mode; // yürüyüş, bisiklet, araç
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
        'places': places,
        'mode': mode,
        'isShared': isShared,
        'createdAt': createdAt,
      };

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        description: json['description'],
        places: List<Map<String, dynamic>>.from(json['places']),
        mode: json['mode'],
        isShared: json['isShared'],
        createdAt: json['createdAt'],
      );
}
