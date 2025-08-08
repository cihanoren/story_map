import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:story_map/features/home/models.dart/comment_model.dart';
import 'package:story_map/features/home/services.dart/comment_service.dart';
import 'package:story_map/features/home/services.dart/rating_service.dart';
import 'package:story_map/features/home/services.dart/story_api_services.dart';
import 'package:story_map/l10n/app_localizations.dart';

class StoryBottomSheet extends StatelessWidget {
  final String title;
  final String imagePath;

  const StoryBottomSheet(
      {super.key, required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              FutureBuilder<RatingStats>(
                future: RatingService.fetchRatingStats(title),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (snapshot.hasError) {
                    return Icon(Icons.error, color: Colors.red);
                  } else {
                    final stats = snapshot.data!;
                    return Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          stats.average.toStringAsFixed(1),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Text("(${stats.totalCount})"),
                      ],
                    );
                  }
                },
              ),
            ],
          ),

          SizedBox(height: 8),
          _buildImage(),
          SizedBox(height: 8),
          FutureBuilder<String>(
            future: StoryService.fetchStory(title),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingAnimation();
              } else if (snapshot.hasError) {
                return Text(AppLocalizations.of(context)!.storyLoadingError,
                    style: TextStyle(fontSize: 16));
              } else {
                return Text(
                    snapshot.data ??
                        AppLocalizations.of(context)!.storyNotFound,
                    style: TextStyle(fontSize: 16));
              }
            },
          ),
          SizedBox(height: 16),

          // Puan ve yorum butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showRatingBottomSheet(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    SizedBox(width: 10),
                    Text(AppLocalizations.of(context)!.evaluate,
                        style: TextStyle(
                            color: Colors.black)), // "Değerlendir" metni
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showCommentBottomSheet(context, title);
                },
                child: Row(
                  children: [
                    Icon(Icons.insert_comment_rounded, color: Colors.blue),
                    SizedBox(width: 10),
                    FutureBuilder<int>(
                      future: fetchCommentCount(title),
                      builder: (context, snapshot) {
                        final countText =
                            snapshot.hasData ? " (${snapshot.data})" : "";
                        return Text(
                          "${AppLocalizations.of(context)!.comments} + $countText",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Oylama alt sayfasını gösteren fonksiyon
  void _showRatingBottomSheet(BuildContext context) {
    double rating = 3;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.ratePlace,
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Slider(
                    activeColor: Colors.blue,
                    value: rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: rating.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.star, color: Colors.yellow),
                    label: Text(
                      "${AppLocalizations.of(context)!.sendEvaluate} (${rating.toStringAsFixed(0)})",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      // Puan kaydetme işlemi

                      final userId = FirebaseAuth.instance.currentUser?.uid;

                      try {
                        await RatingService.submitRating(
                          userId: userId ?? "",
                          placeTitle: title,
                          rating: rating,
                          // userId: FirebaseAuth.instance.currentUser?.uid // kullanıcı oturumu varsa eklenebilir
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.white,
                              content: Row(
                                children: [
                                  Icon(Icons.check, color: Colors.green),
                                  SizedBox(width: 10),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .sendEvaluateSuccessfuly, // "Puan gönderildi" mesajı 
                                      style: TextStyle(color: Colors.black)),
                                ],
                              )),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            content: Text(
                              AppLocalizations.of(context)!
                                  .sendEvaluateUnSuccessfuly,   // "Puan gönderilemedi" mesajı
                            ), 
                          ),
                        );
                      }
                      print("Puan gönderildi: $rating");
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCommentBottomSheet(BuildContext context, String title) {
    final TextEditingController _commentController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.comments,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<CommentModel>>(
                      future: CommentService.fetchComments(title),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text(AppLocalizations.of(context)!.commentsLoadingError)); // "Yorumlar yüklenirken hata oluştu" mesajı
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text(AppLocalizations.of(context)!.noCommentsYet)); // "Henüz yorum yok" mesajı
                        } else {
                          final comments = snapshot.data!;
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final time = comment.timestamp.toDate();
                              return ListTile(
                                leading:
                                    CircleAvatar(child: Icon(Icons.person)),
                                title: Text(comment.userName),
                                subtitle: Text(comment.comment),
                                trailing: Text(
                                  "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.writeComment, // "Yorumunuzu yazın" mesajı
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: () async {
                          final text = _commentController.text.trim();
                          if (text.isEmpty || user == null) return;

                          final comment = CommentModel(
                            userId: user.uid,
                            userName: user.email?.split('@').first ?? AppLocalizations.of(context)!.anonim, // "Anonim Kullanıcı" mesajı
                            comment: text,
                            timestamp: Timestamp.now(),
                          );

                          await CommentService.submitComment(
                            title: title,
                            comment: comment,
                          );

                          _commentController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Yorum sayısını almak için kullanılan fonksiyon
  static Future<int> fetchCommentCount(String title) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(title)
        .collection('entries')
        .get();

    return snapshot.docs.length;
  }

  /// 🔹 AWS S3 veya lokal görüntüyü destekleyen dinamik resim bileşeni
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imagePath.startsWith("http")
          ? Image.network(
              imagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center();
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 100, color: Colors.grey);
              },
            )
          : Image.asset(
              imagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
    );
  }

  /// 🔹 Hikaye yüklenirken gösterilecek animasyon
  Widget _buildLoadingAnimation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AnimatedLoadingText extends StatefulWidget {
  @override
  _AnimatedLoadingTextState createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          AppLocalizations.of(context)!.storyLoading, // "Yükleniyor..." mesajı
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
