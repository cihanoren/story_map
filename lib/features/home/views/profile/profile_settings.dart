import 'package:flutter/material.dart';

class ProfileSettingPage extends StatelessWidget {
  const ProfileSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Şifreyi Değiştir"),
          ),

          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Bildirim Ayarları"),
          ),

          ListTile(
            leading: Icon(Icons.language),
            title: Text("Dil Seçenekleri"),
          ),

          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text("Tema Değiştir"),
          ),

          ListTile(
            leading: Icon(
              Icons.logout_outlined,
              color: Colors.red,
            ),
            title: Text(
              "Çıkış Yap",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),

          
        ],
      ),
    );
  }
}
