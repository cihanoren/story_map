import 'package:cloud_firestore/cloud_firestore.dart';

class RatingStats {
  final double average;
  final int totalCount;

  RatingStats({required this.average, required this.totalCount});
}

class RatingService {
  static Future<void> submitRating({
    required String placeTitle,
    required double rating,
    required String userId,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('ratings').doc();
    await docRef.set({
      'placeTitle': placeTitle,
      'rating': rating,
      'userId': userId,
      'createdAt': Timestamp.now(),
    });
  }

  static Future<double> fetchAverageRating(String placeTitle) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('placeTitle', isEqualTo: placeTitle)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final total = snapshot.docs
        .map((doc) => doc['rating'] as num)
        .fold(0.0, (prev, rating) => prev + rating);

    return total / snapshot.docs.length;
  }

  static Future<RatingStats> fetchRatingStats(String placeTitle) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('placeTitle', isEqualTo: placeTitle)
        .get();

    final totalCount = snapshot.docs.length;

    if (totalCount == 0) {
      return RatingStats(average: 0, totalCount: 0);
    }

    final total = snapshot.docs
        .map((doc) => doc['rating'] as num)
        .fold(0.0, (prev, rating) => prev + rating);

    final average = total / totalCount;

    return RatingStats(average: average, totalCount: totalCount);
  }
}
