import 'package:flutter/material.dart';
import 'package:story_map/features/home/services.dart/story_api_services.dart';

class StoryBottomSheet extends StatelessWidget {
  final String title;
  final String imagePath;

  const StoryBottomSheet({super.key, required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildImage(),
          SizedBox(height: 8),
          FutureBuilder<String>(
            future: StoryService.fetchStory(title),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingAnimation();
              } else if (snapshot.hasError) {
                return Text("Hikaye yüklenirken hata oluştu.", style: TextStyle(fontSize: 16));
              } else {
                return Text(snapshot.data ?? "Hikaye bulunamadı.", style: TextStyle(fontSize: 16));
              }
            },
          ),
        ],
      ),
    );
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
                return Center(child: CircularProgressIndicator());
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          _AnimatedLoadingText(),
        ],
      ),
    );
  }
}

class _AnimatedLoadingText extends StatefulWidget {
  @override
  _AnimatedLoadingTextState createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText> with SingleTickerProviderStateMixin {
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
          "Hikaye yükleniyor...",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
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
