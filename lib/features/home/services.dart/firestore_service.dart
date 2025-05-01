import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story_map/features/home/models.dart/comment_model.dart';
import 'package:story_map/features/home/models.dart/route_model.dart';
import 'package:story_map/features/home/models.dart/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _db.collection("users").doc(user.uid).set(user.toJson());
  }

  Future<void> createRoute(RouteModel route) async {
    await _db.collection("routes").add(route.toJson());
  }

  Future<void> addComment(String routeId, CommentModel comment) async {
    await _db.collection("routes").doc(routeId).collection("comments").add(comment.toJson());
  }

  Future<void> addFavorite(String userId, String routeId) async {
    await _db.collection("users").doc(userId).collection("favorites").doc(routeId).set({
      "routeId": routeId,
      "savedAt": Timestamp.now()
    });
  }
}
