import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story_map/features/home/models.dart/route_model.dart';

class RouteService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveRoute(RouteModel route) async {
    final docRef = _firestore.collection('routes').doc();

    final newRoute = RouteModel(
      id: docRef.id, // Firestore'un oluşturduğu ID'yi modele ekle
      userId: route.userId,
      title: route.title,
      description: route.description,
      places: route.places,
      mode: route.mode,
      isShared: route.isShared,
      createdAt: route.createdAt,
    );

    await docRef.set(newRoute.toJson());
  }
}
