import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String userId;
  final String userName;
  final String content;
  final double rating;
  final Timestamp createdAt;

  CommentModel({
    required this.userId,
    required this.userName,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'content': content,
        'rating': rating,
        'createdAt': createdAt,
      };

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        userId: json['userId'],
        userName: json['userName'],
        content: json['content'],
        rating: (json['rating'] as num).toDouble(),
        createdAt: json['createdAt'],
      );
}
