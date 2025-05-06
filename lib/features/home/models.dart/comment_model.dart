import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String userId;
  final String userName;
  final String comment;
  final Timestamp timestamp;

  CommentModel({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'timestamp': timestamp,
      };

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        userId: json['userId'],
        userName: json['userName'],
        comment: json['comment'],
        timestamp: json['timestamp'],
      );
}
