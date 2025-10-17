import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @noConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get noConnection;

  /// No description provided for @noRoutesMessage.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydedilmiş bir rotanız yok.\nYeni bir rota oluşturmak için haritayı kullanabilirsiniz.'**
  String get noRoutesMessage;

  /// No description provided for @emptyImageText.
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get emptyImageText;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @homeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get homeTitle;

  /// No description provided for @exploreTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get exploreTitle;

  /// No description provided for @mapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get mapTitle;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @unnamedRoute.
  ///
  /// In tr, this message translates to:
  /// **'İsimsiz Rota'**
  String get unnamedRoute;

  /// No description provided for @connectionErrorRoute.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok. Rota oluşturulamadı.'**
  String get connectionErrorRoute;

  /// No description provided for @startingPoint.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Noktası'**
  String get startingPoint;

  /// No description provided for @locationError.
  ///
  /// In tr, this message translates to:
  /// **'Konum Hatası'**
  String get locationError;

  /// No description provided for @getLocationError.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınırken bir hata oluştu. Lütfen tekrar deneyin.'**
  String get getLocationError;

  /// No description provided for @actionOK.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get actionOK;

  /// No description provided for @noLocationPermission.
  ///
  /// In tr, this message translates to:
  /// **'İzin Verilmedi'**
  String get noLocationPermission;

  /// No description provided for @rejectedLocationPermissionMessage.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni kalıcı olarak reddedilmiş. Ayarlardan manuel olarak izin verin.'**
  String get rejectedLocationPermissionMessage;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @requiredPermission.
  ///
  /// In tr, this message translates to:
  /// **'İzin Gerekli'**
  String get requiredPermission;

  /// No description provided for @requiredAppLocationPermissionMessage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın konum iznine ihtiyacı var'**
  String get requiredAppLocationPermissionMessage;

  /// No description provided for @locationServiceDisable.
  ///
  /// In tr, this message translates to:
  /// **'Konum Servisi Kapalı'**
  String get locationServiceDisable;

  /// No description provided for @openLocationServiceMessage.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisleri kapalı. Lütfen cihaz ayarlarından açın.'**
  String get openLocationServiceMessage;

  /// No description provided for @noStoryAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu mekan için bir hikaye bulunamadı.'**
  String get noStoryAvailable;

  /// No description provided for @averageScore.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Puan'**
  String get averageScore;

  /// No description provided for @ratingsCount.
  ///
  /// In tr, this message translates to:
  /// **'Oy'**
  String get ratingsCount;

  /// No description provided for @notFoundAnyPlace.
  ///
  /// In tr, this message translates to:
  /// **'Hiç mekan bulunamadı.'**
  String get notFoundAnyPlace;

  /// No description provided for @noName.
  ///
  /// In tr, this message translates to:
  /// **'İsim Yok'**
  String get noName;

  /// No description provided for @unKnown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get unKnown;

  /// No description provided for @transport.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım'**
  String get transport;

  /// No description provided for @location.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get location;

  /// No description provided for @sharing.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım'**
  String get sharing;

  /// No description provided for @region.
  ///
  /// In tr, this message translates to:
  /// **'Bölge'**
  String get region;

  /// No description provided for @allCountries.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Ülkeler'**
  String get allCountries;

  /// No description provided for @notSharedRouteYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz paylaşılmış rota yok.'**
  String get notSharedRouteYet;

  /// No description provided for @shared.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşıldı'**
  String get shared;

  /// No description provided for @noImage.
  ///
  /// In tr, this message translates to:
  /// **'Resim Yok'**
  String get noImage;

  /// No description provided for @exploreTabPlaceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mekanlar'**
  String get exploreTabPlaceTitle;

  /// No description provided for @exploreTabRouteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rotalar'**
  String get exploreTabRouteTitle;

  /// No description provided for @howManyLocationTripQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Kaç lokasyon gezmek istiyorsunuz?'**
  String get howManyLocationTripQuestion;

  /// No description provided for @selectTransportMode.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım Modu Seçin'**
  String get selectTransportMode;

  /// No description provided for @driving.
  ///
  /// In tr, this message translates to:
  /// **'Araç'**
  String get driving;

  /// No description provided for @walking.
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get walking;

  /// No description provided for @bicycling.
  ///
  /// In tr, this message translates to:
  /// **'Bisiklet'**
  String get bicycling;

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get start;

  /// No description provided for @startTrip.
  ///
  /// In tr, this message translates to:
  /// **'Geziye Başla'**
  String get startTrip;

  /// No description provided for @tripRoute.
  ///
  /// In tr, this message translates to:
  /// **'Gezi Rotası'**
  String get tripRoute;

  /// No description provided for @routeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rota Başlığı'**
  String get routeTitle;

  /// No description provided for @tripHintText.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Sultanahmet Gezisi'**
  String get tripHintText;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @tourSavedSuccessfuly.
  ///
  /// In tr, this message translates to:
  /// **'Tur Başarıyla Kaydedildi'**
  String get tourSavedSuccessfuly;

  /// No description provided for @saveTour.
  ///
  /// In tr, this message translates to:
  /// **'Turu Kaydet'**
  String get saveTour;

  /// No description provided for @endTour.
  ///
  /// In tr, this message translates to:
  /// **'Turu Bitir'**
  String get endTour;

  /// No description provided for @seeTours.
  ///
  /// In tr, this message translates to:
  /// **'Rotaları Gör'**
  String get seeTours;

  /// No description provided for @routeDetails.
  ///
  /// In tr, this message translates to:
  /// **'Rota Detayları'**
  String get routeDetails;

  /// No description provided for @editRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotayı Düzenle'**
  String get editRoute;

  /// No description provided for @shareInExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfette Paylaş'**
  String get shareInExplore;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @deleteRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotayı Sil'**
  String get deleteRoute;

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @routeNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Rota Bulunamadı'**
  String get routeNotFound;

  /// No description provided for @alreadyRouteSharedExplore.
  ///
  /// In tr, this message translates to:
  /// **'Bu rota zaten keşfette paylaşılmış'**
  String get alreadyRouteSharedExplore;

  /// No description provided for @routeSharedInExplore.
  ///
  /// In tr, this message translates to:
  /// **'Rota keşfet sayfasında paylaşıldı'**
  String get routeSharedInExplore;

  /// No description provided for @errorOccured.
  ///
  /// In tr, this message translates to:
  /// **'Hata oluştu!'**
  String get errorOccured;

  /// No description provided for @editRouteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rota Adını Düzenle'**
  String get editRouteTitle;

  /// No description provided for @newRouteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Rota Başlığı'**
  String get newRouteTitle;

  /// No description provided for @deleteRouteConfirmation.
  ///
  /// In tr, this message translates to:
  /// **'Bu rotayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'**
  String get deleteRouteConfirmation;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @routeDeletedSuccessfuly.
  ///
  /// In tr, this message translates to:
  /// **'Rota başarıyla silindi'**
  String get routeDeletedSuccessfuly;

  /// No description provided for @routeDeleteUnsuccessfuly.
  ///
  /// In tr, this message translates to:
  /// **'Rota silme işlemi başarısız'**
  String get routeDeleteUnsuccessfuly;

  /// No description provided for @storyLoadingError.
  ///
  /// In tr, this message translates to:
  /// **'Hikaye yüklenirken bir hata oluştu'**
  String get storyLoadingError;

  /// No description provided for @storyNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Hikaye bulunamadı'**
  String get storyNotFound;

  /// No description provided for @evaluate.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendir'**
  String get evaluate;

  /// No description provided for @comments.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get comments;

  /// No description provided for @ratePlace.
  ///
  /// In tr, this message translates to:
  /// **'Bu mekana kaç puan verirsiniz?'**
  String get ratePlace;

  /// No description provided for @sendEvaluate.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmeyi Gönder'**
  String get sendEvaluate;

  /// No description provided for @sendEvaluateSuccessfuly.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmeniz başarıyla gönderildi'**
  String get sendEvaluateSuccessfuly;

  /// No description provided for @sendEvaluateUnSuccessfuly.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmeniz gönderilirken hata oluştu'**
  String get sendEvaluateUnSuccessfuly;

  /// No description provided for @commentsLoadingError.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar yüklenirken hata oluştu'**
  String get commentsLoadingError;

  /// No description provided for @noCommentsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yapılmamış'**
  String get noCommentsYet;

  /// No description provided for @writeComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yap'**
  String get writeComment;

  /// No description provided for @anonim.
  ///
  /// In tr, this message translates to:
  /// **'Anonim'**
  String get anonim;

  /// No description provided for @storyLoading.
  ///
  /// In tr, this message translates to:
  /// **'Hikaye yükleniyor...'**
  String get storyLoading;

  /// No description provided for @reportIssue.
  ///
  /// In tr, this message translates to:
  /// **'Sorun Bildir'**
  String get reportIssue;

  /// No description provided for @notOpenMailApp.
  ///
  /// In tr, this message translates to:
  /// **'Mail uygulaması açılamadı'**
  String get notOpenMailApp;

  /// No description provided for @openingMailApp.
  ///
  /// In tr, this message translates to:
  /// **'Mail uygulaması açılıyor...'**
  String get openingMailApp;

  /// No description provided for @issueHintText.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Harita yüklenmiyor'**
  String get issueHintText;

  /// No description provided for @issueBoxTitle.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştığınız sorunu lütfen detaylı şekilde yazınız.'**
  String get issueBoxTitle;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @accountInfo.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Bilgileri'**
  String get accountInfo;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Değiştir'**
  String get changePassword;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @languageOptions.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçenekleri'**
  String get languageOptions;

  /// No description provided for @lightMode.
  ///
  /// In tr, this message translates to:
  /// **'Açık Moda Geç'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Moda Geç'**
  String get darkMode;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @helpAndSupport.
  ///
  /// In tr, this message translates to:
  /// **'Yardım ve Destek'**
  String get helpAndSupport;

  /// No description provided for @logOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logOut;

  /// No description provided for @logOutConfirmation.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunuzu kapatmak istediğinizden emin misiniz?'**
  String get logOutConfirmation;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// No description provided for @removeFromExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfetten Kaldır'**
  String get removeFromExplore;

  /// No description provided for @removeFromExploreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Rota Keşfetten Kaldırıldı'**
  String get removeFromExploreSuccess;

  /// No description provided for @profilPhotoChangeRule.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafını sadece giriş yapmış kullanıcılar değiştirebilir.'**
  String get profilPhotoChangeRule;

  /// No description provided for @chooseFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden seç'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Kamera ile çek'**
  String get takePhoto;

  /// No description provided for @enterLocationInfo.
  ///
  /// In tr, this message translates to:
  /// **'Konum Bilgisi Gir'**
  String get enterLocationInfo;

  /// No description provided for @locationHintText.
  ///
  /// In tr, this message translates to:
  /// **'Örn: İstanbul, Fatih'**
  String get locationHintText;

  /// No description provided for @gettingLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınıyor...'**
  String get gettingLocation;

  /// No description provided for @username.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get username;

  /// No description provided for @loadingEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta yükleniyor...'**
  String get loadingEmail;

  /// No description provided for @returnCurrentLocation.
  ///
  /// In tr, this message translates to:
  /// **'Anlık Konuma Geri Dön'**
  String get returnCurrentLocation;

  /// No description provided for @liked.
  ///
  /// In tr, this message translates to:
  /// **'Beğenilenler'**
  String get liked;

  /// No description provided for @noLikedRouteYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz beğendiğin rota yok'**
  String get noLikedRouteYet;

  /// No description provided for @feedback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim'**
  String get feedback;

  /// No description provided for @feedbackMessageInfo.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama hakkındaki düşüncelerini paylaş:'**
  String get feedbackMessageInfo;

  /// No description provided for @feedbackHintText.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Arayüz çok hoşuma gitti...'**
  String get feedbackHintText;

  /// No description provided for @newPasswordsNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifreler uyuşmuyor'**
  String get newPasswordsNotMatch;

  /// No description provided for @newPasswordCondition.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre en az 8 karakter olmalı'**
  String get newPasswordCondition;

  /// No description provided for @oldPassword.
  ///
  /// In tr, this message translates to:
  /// **'Eski Şifre'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get newPassword;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-Posta'**
  String get email;

  /// No description provided for @newPasswordAgain.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre (Tekrar)'**
  String get newPasswordAgain;

  /// No description provided for @changePasswordSuccesfuly.
  ///
  /// In tr, this message translates to:
  /// **'Şifre başarıyla değiştirildi'**
  String get changePasswordSuccesfuly;

  /// No description provided for @usernameWasTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı daha önce alınmış. Başka bir kullanıcı adı seçin.'**
  String get usernameWasTaken;

  /// No description provided for @updateInfoSuccessfuly.
  ///
  /// In tr, this message translates to:
  /// **'Bilgiler başarıyla güncellendi'**
  String get updateInfoSuccessfuly;

  /// No description provided for @errorOccurredWhenInfoUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Bilgiler güncellenirken bir hata oluştu'**
  String get errorOccurredWhenInfoUpdate;

  /// No description provided for @name.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get name;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get signUp;

  /// No description provided for @emailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta alanı boş bırakılamaz'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre alanı boş bırakılamaz'**
  String get passwordRequired;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @successRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Başarılı'**
  String get successRegister;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten bir hesabın var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// No description provided for @sendEmailVerification.
  ///
  /// In tr, this message translates to:
  /// **'E-posta doğrulama linki gönderildi. Lütfen e-postanızı doğrulayın.'**
  String get sendEmailVerification;

  /// No description provided for @continueWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile devam et'**
  String get continueWithGoogle;

  /// No description provided for @googleSignInFailed.
  ///
  /// In tr, this message translates to:
  /// **'Google ile giriş başarısız'**
  String get googleSignInFailed;

  /// No description provided for @signInAnonymously.
  ///
  /// In tr, this message translates to:
  /// **'Misafir olarak giriş yap'**
  String get signInAnonymously;

  /// No description provided for @dontHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get dontHaveAccount;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyTextTitle.
  ///
  /// In tr, this message translates to:
  /// **'Story Map Gizlilik Politikası'**
  String get privacyPolicyTextTitle;

  /// No description provided for @privacyPolicyLastUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Son Güncellenme Tarihi: 01.08.2025'**
  String get privacyPolicyLastUpdate;

  /// No description provided for @privacyPolicyIntroTitle.
  ///
  /// In tr, this message translates to:
  /// **'1. Giriş'**
  String get privacyPolicyIntroTitle;

  /// No description provided for @privacyPolicyIntroText.
  ///
  /// In tr, this message translates to:
  /// **'Bu gizlilik politikası, Story Map adlı mobil uygulamanın kullanıcı verilerini nasıl topladığını, kullandığını ve koruduğunu açıklamaktadır. Uygulamayı kullanarak bu politikayı kabul etmiş sayılırsınız.'**
  String get privacyPolicyIntroText;

  /// No description provided for @privacyPolicyCollectedDataTitle.
  ///
  /// In tr, this message translates to:
  /// **'2. Toplanan Veriler'**
  String get privacyPolicyCollectedDataTitle;

  /// No description provided for @privacyPolicyLocationData.
  ///
  /// In tr, this message translates to:
  /// **'Konum Verisi'**
  String get privacyPolicyLocationData;

  /// No description provided for @privacyPolicyLocationDataText.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcının mevcut konumunu alarak harita üzerinde konuma dayalı rotalar ve hikayeler sunar.'**
  String get privacyPolicyLocationDataText;

  /// No description provided for @privacyPolicyLocationDataText2.
  ///
  /// In tr, this message translates to:
  /// **'Konum yalnızca kullanıcı izniyle alınır ve arka planda izleme yapılmaz.'**
  String get privacyPolicyLocationDataText2;

  /// No description provided for @privacyPolicyUserDataTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullnıcı Bilgileri (Google hesabı ile giriş yapıldığında)'**
  String get privacyPolicyUserDataTitle;

  /// No description provided for @privacyPolicyUserDataText.
  ///
  /// In tr, this message translates to:
  /// **'Ad, soyad, e-posta adresi'**
  String get privacyPolicyUserDataText;

  /// No description provided for @privacyPolicyUserDataText2.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı'**
  String get privacyPolicyUserDataText2;

  /// No description provided for @privacyPolicyUsingAppTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Kullanım Bilgileri'**
  String get privacyPolicyUsingAppTitle;

  /// No description provided for @privacyPolicyUsingAppText.
  ///
  /// In tr, this message translates to:
  /// **'Firebase üzerinden kullanıcı davranışı ve uygulama performansına dair anonim veriler toplanabilir.'**
  String get privacyPolicyUsingAppText;

  /// No description provided for @privacyPolicyUsingDataTitle.
  ///
  /// In tr, this message translates to:
  /// **'3. Verilerin Kullanımı'**
  String get privacyPolicyUsingDataTitle;

  /// No description provided for @privacyPolicyUsingDataText.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama içeriğini kişiselleştirmek'**
  String get privacyPolicyUsingDataText;

  /// No description provided for @privacyPolicyUsingDataText2.
  ///
  /// In tr, this message translates to:
  /// **'Konum bazlı hikaye ve rota önerileri sunmak'**
  String get privacyPolicyUsingDataText2;

  /// No description provided for @privacyPolicyUsingDataText3.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama performansını ve kullanıcı deneyimini iyileştirmek'**
  String get privacyPolicyUsingDataText3;

  /// No description provided for @privacyPolicyUsingDataText4.
  ///
  /// In tr, this message translates to:
  /// **'Hataları analiz etmek ve düzeltmek'**
  String get privacyPolicyUsingDataText4;

  /// No description provided for @privacyPolicyThirdPartyServicesTitle.
  ///
  /// In tr, this message translates to:
  /// **'4. Üçüncü Taraf Servisler'**
  String get privacyPolicyThirdPartyServicesTitle;

  /// No description provided for @privacyPolicyThirdPartyServicesText.
  ///
  /// In tr, this message translates to:
  /// **'- Google Firebase (Auth, Firestore, Storage)\n- Google Maps SDK\n- Geolocator ve Harita servisleri\n\n> Bu servislerin her biri kendi gizlilik politikalarına sahiptir.'**
  String get privacyPolicyThirdPartyServicesText;

  /// No description provided for @privacyPolicyDataStorageTitle.
  ///
  /// In tr, this message translates to:
  /// **'5. Verilerin Saklanması ve Güvenliği'**
  String get privacyPolicyDataStorageTitle;

  /// No description provided for @privacyPolicyDataStorageText.
  ///
  /// In tr, this message translates to:
  /// **'- Kullanıcı verileri Firebase altyapısında güvenli şekilde saklanır.\n- Uygulama, verilerin yetkisiz erişime karşı korunması için gerekli teknik önlemleri alır.'**
  String get privacyPolicyDataStorageText;

  /// No description provided for @privacyPolicyCookiesTitle.
  ///
  /// In tr, this message translates to:
  /// **'6. Çerezler'**
  String get privacyPolicyCookiesTitle;

  /// No description provided for @privacyPolicyCookiesText.
  ///
  /// In tr, this message translates to:
  /// **'- Uygulama herhangi bir çerez (cookie) kullanmaz.'**
  String get privacyPolicyCookiesText;

  /// No description provided for @privacyPolicyDataSharingTitle.
  ///
  /// In tr, this message translates to:
  /// **'7. Verilerin Paylaşımı'**
  String get privacyPolicyDataSharingTitle;

  /// No description provided for @privacyPolicyDataSharingText.
  ///
  /// In tr, this message translates to:
  /// **'- Kullanıcı verileri üçüncü kişilerle asla paylaşılmaz, satılmaz veya kiralanmaz.\n- Yasal zorunluluk durumunda yalnızca yetkili makamlarla paylaşılabilir.'**
  String get privacyPolicyDataSharingText;

  /// No description provided for @privacyPolicyUserRightsTitle.
  ///
  /// In tr, this message translates to:
  /// **'8. Kullanıcı Hakları'**
  String get privacyPolicyUserRightsTitle;

  /// No description provided for @privacyPolicyUserRightsText.
  ///
  /// In tr, this message translates to:
  /// **'- Kullanıcılar, kişisel verilerine erişme, düzeltme veya silme hakkına sahiptir.\n- Bu tür talepler için geliştirici ile iletişime geçilebilir:\n📧 E-posta: cihanoren1@gmail.com'**
  String get privacyPolicyUserRightsText;

  /// No description provided for @privacyPolicyChangesTitle.
  ///
  /// In tr, this message translates to:
  /// **'9. Politikadaki Değişiklikler'**
  String get privacyPolicyChangesTitle;

  /// No description provided for @privacyPolicyChangesText.
  ///
  /// In tr, this message translates to:
  /// **'- Bu gizlilik politikası zaman zaman güncellenebilir.\n- Güncellemeler uygulama içinden veya bu sayfa üzerinden duyurulur.'**
  String get privacyPolicyChangesText;

  /// No description provided for @searchPlace.
  ///
  /// In tr, this message translates to:
  /// **'Yer Ara...'**
  String get searchPlace;

  /// No description provided for @help_editAccount_title.
  ///
  /// In tr, this message translates to:
  /// **'Hesap bilgilerini nasıl düzenlerim?'**
  String get help_editAccount_title;

  /// No description provided for @help_editAccount_content.
  ///
  /// In tr, this message translates to:
  /// **'Profil sayfasındaki ayarlar simgesine tıklayarak kullanıcı adı ve e-posta gibi bilgileri düzenleyebilirsin.'**
  String get help_editAccount_content;

  /// No description provided for @help_shareRoute_title.
  ///
  /// In tr, this message translates to:
  /// **'Rota nasıl paylaşılır?'**
  String get help_shareRoute_title;

  /// No description provided for @help_shareRoute_content.
  ///
  /// In tr, this message translates to:
  /// **'Bir rota oluşturduktan sonra \'Keşfette Paylaş\' seçeneğini kullanarak rotanı keşfet bölümüne gönderebilirsin.'**
  String get help_shareRoute_content;

  /// No description provided for @help_favorites_title.
  ///
  /// In tr, this message translates to:
  /// **'Beğendiğim rotaları nereden görebilirim?'**
  String get help_favorites_title;

  /// No description provided for @help_favorites_content.
  ///
  /// In tr, this message translates to:
  /// **'Profil sayfasında \'Beğendiklerin\' sekmesine tıklayarak daha önce beğendiğin rotaları görebilirsin.'**
  String get help_favorites_content;

  /// No description provided for @help_editLocation_title.
  ///
  /// In tr, this message translates to:
  /// **'Konum bilgilerimi nasıl değiştirebilirim?'**
  String get help_editLocation_title;

  /// No description provided for @help_editLocation_content.
  ///
  /// In tr, this message translates to:
  /// **'Profil sayfasında konum kısmındaki kalem ikonuna tıklayarak manuel konum girişi yapabilirsin.'**
  String get help_editLocation_content;

  /// No description provided for @help_reportIssue_title.
  ///
  /// In tr, this message translates to:
  /// **'Sorun bildirimi nasıl yapabilirim?'**
  String get help_reportIssue_title;

  /// No description provided for @help_reportIssue_content.
  ///
  /// In tr, this message translates to:
  /// **'Geliştiriciye ulaşmak için uygulama içindeki iletişim sekmesini kullanabilirsin. Eğer iletişim sekmesinden ulaşamaz iseniz cihanoren10@gmail.com adresine e-posta gönderebilirsin.'**
  String get help_reportIssue_content;

  /// No description provided for @help_deleteRoute_title.
  ///
  /// In tr, this message translates to:
  /// **'Rotalarımı nasıl silebilirim?'**
  String get help_deleteRoute_title;

  /// No description provided for @help_deleteRoute_content.
  ///
  /// In tr, this message translates to:
  /// **'Kendi oluşturduğun rotaların detay sayfasına gidip \'Sil\' seçeneğini kullanarak rotayı kalıcı olarak kaldırabilirsin.'**
  String get help_deleteRoute_content;

  /// No description provided for @help_addFavorites_title.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere nasıl rota eklerim?'**
  String get help_addFavorites_title;

  /// No description provided for @help_addFavorites_content.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet bölümünde beğendiğin bir rotanın kalp ikonuna tıklayarak favorilerine ekleyebilirsin.'**
  String get help_addFavorites_content;

  /// No description provided for @help_addComment_title.
  ///
  /// In tr, this message translates to:
  /// **'Yorum nasıl yapabilirim?'**
  String get help_addComment_title;

  /// No description provided for @help_addComment_content.
  ///
  /// In tr, this message translates to:
  /// **'Harita bölümünden ilgili yere tıklayarak hikayenin en altındaki alana gidebilir ve \'Yorum Yap\' alanından düşüncelerini paylaşabilirsin.'**
  String get help_addComment_content;

  /// No description provided for @help_changeLanguage_title.
  ///
  /// In tr, this message translates to:
  /// **'Dil ayarlarını nasıl değiştirebilirim?'**
  String get help_changeLanguage_title;

  /// No description provided for @help_changeLanguage_content.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar sayfasındaki \'Dil\' seçeneğinden uygulamanın görüntüleneceği dilini değiştirebilirsin.'**
  String get help_changeLanguage_content;

  /// No description provided for @help_notifications_title.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama bildirimlerini kapatabilir miyim?'**
  String get help_notifications_title;

  /// No description provided for @help_notifications_content.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz ayarlarından uygulamanın bildirim izinlerini kapatabilir veya uygulama içi ayarlardan sessize alabilirsin.'**
  String get help_notifications_content;

  /// No description provided for @help_viewStories_title.
  ///
  /// In tr, this message translates to:
  /// **'Hikayeler nasıl görüntülenir?'**
  String get help_viewStories_title;

  /// No description provided for @help_viewStories_content.
  ///
  /// In tr, this message translates to:
  /// **'Harita üzerinde veya keşfet bölümünde seçtiğin mekanların altındaki hikaye ikonuna tıklayarak paylaşılan hikayeleri görebilirsin.'**
  String get help_viewStories_content;

  /// No description provided for @help_offlineUsage_title.
  ///
  /// In tr, this message translates to:
  /// **'İnternet olmadan uygulamayı kullanabilir miyim?'**
  String get help_offlineUsage_title;

  /// No description provided for @help_offlineUsage_content.
  ///
  /// In tr, this message translates to:
  /// **'Rotaları oluşturmak ve kayıtlı rotaları görmek için internet bağlantısı gerekir.'**
  String get help_offlineUsage_content;

  /// No description provided for @help_deleteAccount_title.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı silebilir miyim?'**
  String get help_deleteAccount_title;

  /// No description provided for @help_deleteAccount_content.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek için uygulama içindeki iletişim sekmesini kullanarak geliştiriciye ulaşabilirsiniz ve kullanıcı adınız ile beraber e-posta adresinizi belirtmeniz yeterlidir.'**
  String get help_deleteAccount_content;

  /// No description provided for @helpCenterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yardım Merkezi'**
  String get helpCenterTitle;

  /// No description provided for @sendFeedback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim Gönder'**
  String get sendFeedback;

  /// No description provided for @continueWithApple.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile devam et'**
  String get continueWithApple;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ru',
        'tr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
