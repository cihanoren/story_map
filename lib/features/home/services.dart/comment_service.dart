import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story_map/features/home/models.dart/comment_model.dart';

class CommentService {
  static Future<List<CommentModel>> fetchComments(String title) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(title)
        .collection('entries')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromJson(doc.data()))
        .toList();
  }

  static Future<void> submitComment({
    required String title,
    required CommentModel comment,
  }) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(title)
        .collection('entries')
        .add(comment.toJson());
  }
}
