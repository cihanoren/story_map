import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Gizlilik Politikası',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Story Map - Gizlilik Politikası',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Son güncelleme tarihi: 01.08.2025',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '1. Giriş',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Bu gizlilik politikası, Story Map adlı mobil uygulamanın kullanıcı verilerini nasıl topladığını, kullandığını ve koruduğunu açıklamaktadır. '
              'Uygulamayı kullanarak bu politikayı kabul etmiş sayılırsınız.',
            ),
            SizedBox(height: 16),
            Text(
              '2. Toplanan Veriler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('📍 Konum Verisi'),
            Text(
              '- Kullanıcının mevcut konumunu alarak harita üzerinde konuma dayalı rotalar ve hikayeler sunar.\n'
              '- Konum yalnızca kullanıcı izniyle alınır ve arka planda izleme yapılmaz.',
            ),
            SizedBox(height: 8),
            Text(
                '👤 Kullanıcı Bilgileri (Google hesabı ile giriş yapıldığında)'),
            Text('- Ad, soyad, e-posta adresi\n- Profil fotoğrafı'),
            SizedBox(height: 8),
            Text('📊 Uygulama Kullanım Bilgileri'),
            Text(
                '- Firebase üzerinden kullanıcı davranışı ve uygulama performansına dair anonim veriler toplanabilir.'),
            SizedBox(height: 16),
            Text(
              '3. Verilerin Kullanımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Uygulama içeriğini kişiselleştirmek\n'
              '- Konum bazlı hikaye ve rota önerileri sunmak\n'
              '- Uygulama performansını ve kullanıcı deneyimini iyileştirmek\n'
              '- Hataları analiz etmek ve düzeltmek',
            ),
            SizedBox(height: 16),
            Text(
              '4. Üçüncü Taraf Servisler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Google Firebase (Auth, Firestore, Storage)\n'
              '- Google Maps SDK\n'
              '- Geolocator ve Harita servisleri\n\n'
              '> Bu servislerin her biri kendi gizlilik politikalarına sahiptir.',
            ),
            SizedBox(height: 16),
            Text(
              '5. Verilerin Saklanması ve Güvenliği',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Kullanıcı verileri Firebase altyapısında güvenli şekilde saklanır.\n'
              '- Uygulama, verilerin yetkisiz erişime karşı korunması için gerekli teknik önlemleri alır.',
            ),
            SizedBox(height: 16),
            Text(
              '6. Çerezler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('- Uygulama herhangi bir çerez (cookie) kullanmaz.'),
            SizedBox(height: 16),
            Text(
              '7. Verilerin Paylaşımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Kullanıcı verileri üçüncü kişilerle asla paylaşılmaz, satılmaz veya kiralanmaz.\n'
              '- Yasal zorunluluk durumunda yalnızca yetkili makamlarla paylaşılabilir.',
            ),
            SizedBox(height: 16),
            Text(
              '8. Kullanıcı Hakları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Kullanıcılar, kişisel verilerine erişme, düzeltme veya silme hakkına sahiptir.\n'
              '- Bu tür talepler için geliştirici ile iletişime geçilebilir:\n'
              '📧 E-posta: cihanoren1@gmail.com',
            ),
            SizedBox(height: 16),
            Text(
              '9. Politikadaki Değişiklikler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Bu gizlilik politikası zaman zaman güncellenebilir.\n'
              '- Güncellemeler uygulama içinden veya bu sayfa üzerinden duyurulur.',
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
