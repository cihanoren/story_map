import 'package:flutter/material.dart';
import 'package:story_map/features/home/models.dart/route_model.dart';
import 'package:story_map/features/home/services.dart/firestore_service.dart';

class RouteController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createRoute(RouteModel route) async {
    try {
      await _firestoreService.createRoute(route);
      // kullanıcıya bildirim göster vs.
      notifyListeners();
    } catch (e) {
      debugPrint("Rota oluşturma hatası: $e");
    }
  }
}
