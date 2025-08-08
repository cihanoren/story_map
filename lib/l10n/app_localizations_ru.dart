// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get noConnection => 'Нет подключения к интернету';

  @override
  String get noRoutesMessage =>
      'У вас ещё нет сохранённых маршрутов.\nВы можете использовать карту, чтобы создать новый маршрут.';

  @override
  String get emptyImageText => 'Пусто';

  @override
  String get loading => 'Загрузка...';

  @override
  String get homeTitle => 'Главная';

  @override
  String get exploreTitle => 'Исследовать';

  @override
  String get mapTitle => 'Карта';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get unnamedRoute => 'Маршрут без названия';

  @override
  String get connectionErrorRoute =>
      'Нет подключения к интернету. Не удалось создать маршрут.';

  @override
  String get startingPoint => 'Точка отправления';

  @override
  String get locationError => 'Ошибка местоположения';

  @override
  String get getLocationError =>
      'Произошла ошибка при получении местоположения. Пожалуйста, попробуйте снова.';

  @override
  String get actionOK => 'ОК';

  @override
  String get noLocationPermission => 'Разрешение не предоставлено';

  @override
  String get rejectedLocationPermissionMessage =>
      'Доступ к местоположению был навсегда отклонён. Разрешите вручную в настройках.';

  @override
  String get settings => 'Настройки';

  @override
  String get requiredPermission => 'Требуется разрешение';

  @override
  String get requiredAppLocationPermissionMessage =>
      'Приложению необходимо разрешение на доступ к местоположению';

  @override
  String get locationServiceDisable => 'Служба геолокации отключена';

  @override
  String get openLocationServiceMessage =>
      'Службы геолокации отключены. Пожалуйста, включите их в настройках устройства.';

  @override
  String get noStoryAvailable => 'Для этого места нет истории.';

  @override
  String get averageScore => 'Средний балл';

  @override
  String get ratingsCount => 'Оценки';

  @override
  String get notFoundAnyPlace => 'Ни одного места не найдено.';

  @override
  String get noName => 'Без имени';

  @override
  String get unKnown => 'Неизвестно';

  @override
  String get transport => 'Транспорт';

  @override
  String get location => 'Местоположение';

  @override
  String get sharing => 'Общий доступ';

  @override
  String get region => 'Регион';

  @override
  String get allCountries => 'Все страны';

  @override
  String get notSharedRouteYet => 'Ещё нет опубликованных маршрутов.';

  @override
  String get shared => 'Опубликовано';

  @override
  String get noImage => 'Нет изображения';

  @override
  String get exploreTabPlaceTitle => 'Места';

  @override
  String get exploreTabRouteTitle => 'Маршруты';

  @override
  String get howManyLocationTripQuestion => 'Сколько мест вы хотите посетить?';

  @override
  String get selectTransportMode => 'Выберите вид транспорта';

  @override
  String get driving => 'На машине';

  @override
  String get walking => 'Пешком';

  @override
  String get bicycling => 'На велосипеде';

  @override
  String get start => 'Начать';

  @override
  String get startTrip => 'Начать путешествие';

  @override
  String get tripRoute => 'Маршрут поездки';

  @override
  String get routeTitle => 'Название маршрута';

  @override
  String get tripHintText => 'Напр.: Поездка в Султанахмет';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get tourSavedSuccessfuly => 'Тур успешно сохранён';

  @override
  String get saveTour => 'Сохранить тур';

  @override
  String get endTour => 'Завершить тур';

  @override
  String get seeTours => 'Посмотреть маршруты';

  @override
  String get routeDetails => 'Детали маршрута';

  @override
  String get editRoute => 'Редактировать маршрут';

  @override
  String get shareInExplore => 'Опубликовать в разделе «Исследовать»';

  @override
  String get share => 'Поделиться';

  @override
  String get deleteRoute => 'Удалить маршрут';

  @override
  String get date => 'Дата';

  @override
  String get routeNotFound => 'Маршрут не найден';

  @override
  String get alreadyRouteSharedExplore =>
      'Этот маршрут уже опубликован в разделе «Исследовать»';

  @override
  String get routeSharedInExplore =>
      'Маршрут опубликован в разделе «Исследовать»';

  @override
  String get errorOccured => 'Произошла ошибка!';

  @override
  String get editRouteTitle => 'Изменить название маршрута';

  @override
  String get newRouteTitle => 'Новое название маршрута';

  @override
  String get deleteRouteConfirmation =>
      'Вы уверены, что хотите удалить этот маршрут? Это действие нельзя отменить.';

  @override
  String get delete => 'Удалить';

  @override
  String get routeDeletedSuccessfuly => 'Маршрут успешно удалён';

  @override
  String get routeDeleteUnsuccessfuly => 'Не удалось удалить маршрут';

  @override
  String get storyLoadingError => 'Произошла ошибка при загрузке истории';

  @override
  String get storyNotFound => 'История не найдена';

  @override
  String get evaluate => 'Оценить';

  @override
  String get comments => 'Комментарии';

  @override
  String get ratePlace => 'Какую оценку вы дадите этому месту?';

  @override
  String get sendEvaluate => 'Отправить оценку';

  @override
  String get sendEvaluateSuccessfuly => 'Ваша оценка успешно отправлена';

  @override
  String get sendEvaluateUnSuccessfuly =>
      'Произошла ошибка при отправке оценки';

  @override
  String get commentsLoadingError => 'Ошибка при загрузке комментариев';

  @override
  String get noCommentsYet => 'Комментариев пока нет';

  @override
  String get writeComment => 'Написать комментарий';

  @override
  String get anonim => 'Аноним';

  @override
  String get storyLoading => 'Загрузка истории...';

  @override
  String get reportIssue => 'Сообщить о проблеме';

  @override
  String get notOpenMailApp => 'Не удалось открыть почтовое приложение';

  @override
  String get openingMailApp => 'Открытие почтового приложения...';

  @override
  String get issueHintText => 'Напр.: Карта не загружается';

  @override
  String get issueBoxTitle =>
      'Пожалуйста, опишите проблему, с которой вы столкнулись, подробно.';

  @override
  String get send => 'Отправить';

  @override
  String get accountInfo => 'Информация об аккаунте';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get notificationSettings => 'Настройки уведомлений';

  @override
  String get languageOptions => 'Языковые настройки';

  @override
  String get lightMode => 'Светлый режим';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get logOut => 'Выйти';

  @override
  String get logOutConfirmation => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get removeFromExplore => 'Удалить из раздела «Исследовать»';

  @override
  String get removeFromExploreSuccess =>
      'Маршрут удалён из раздела «Исследовать»';

  @override
  String get profilPhotoChangeRule =>
      'Фото профиля могут менять только авторизованные пользователи.';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get enterLocationInfo => 'Введите информацию о местоположении';

  @override
  String get locationHintText => 'Напр.: Стамбул, Фатих';

  @override
  String get gettingLocation => 'Получение местоположения...';

  @override
  String get username => 'Имя пользователя';

  @override
  String get loadingEmail => 'Загрузка электронной почты...';

  @override
  String get returnCurrentLocation => 'Вернуться к текущему местоположению';

  @override
  String get liked => 'Понравившиеся';

  @override
  String get noLikedRouteYet => 'У вас пока нет понравившихся маршрутов';

  @override
  String get feedback => 'Обратная связь';

  @override
  String get feedbackMessageInfo => 'Поделитесь своим мнением о приложении:';

  @override
  String get feedbackHintText => 'Напр.: Интерфейс мне очень понравился...';

  @override
  String get newPasswordsNotMatch => 'Новые пароли не совпадают';

  @override
  String get newPasswordCondition =>
      'Новый пароль должен содержать не менее 8 символов';

  @override
  String get oldPassword => 'Старый пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get email => 'Электронная почта';

  @override
  String get newPasswordAgain => 'Новый пароль (ещё раз)';

  @override
  String get changePasswordSuccesfuly => 'Пароль успешно изменён';

  @override
  String get usernameWasTaken =>
      'Это имя пользователя уже занято. Пожалуйста, выберите другое.';

  @override
  String get updateInfoSuccessfuly => 'Данные успешно обновлены';

  @override
  String get errorOccurredWhenInfoUpdate =>
      'Произошла ошибка при обновлении данных';

  @override
  String get name => 'Имя';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get emailRequired => 'Поле электронной почты не может быть пустым';

  @override
  String get passwordRequired => 'Поле пароля не может быть пустым';

  @override
  String get password => 'Пароль';

  @override
  String get successRegister => 'Регистрация успешна';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get signIn => 'Войти';

  @override
  String get sendEmailVerification =>
      'Ссылка для подтверждения отправлена на вашу почту. Пожалуйста, подтвердите адрес.';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get googleSignInFailed => 'Вход через Google не удался';

  @override
  String get signInAnonymously => 'Войти как гость';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';
}
