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
      'У вас ещё нет сохранённых маршрутов.\nВы можете создать новый маршрут, используя карту.';

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
  String get unnamedRoute => 'Безымянный маршрут';

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
  String get notFoundAnyPlace => 'Места не найдены.';

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
  String get notSharedRouteYet => 'Пока нет опубликованных маршрутов.';

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
  String get driving => 'Автомобиль';

  @override
  String get walking => 'Пешком';

  @override
  String get bicycling => 'Велосипед';

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
  String get storyLoadingError => 'Ошибка загрузки истории';

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
  String get sendEvaluateUnSuccessfuly => 'Ошибка при отправке оценки';

  @override
  String get commentsLoadingError => 'Ошибка загрузки комментариев';

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
  String get issueBoxTitle => 'Пожалуйста, опишите проблему подробно.';

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
  String get errorOccurredWhenInfoUpdate => 'Ошибка при обновлении данных';

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

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get privacyPolicyTextTitle => 'Политика конфиденциальности Story Map';

  @override
  String get privacyPolicyLastUpdate => 'Последнее обновление: 01.08.2025';

  @override
  String get privacyPolicyIntroTitle => '1. Введение';

  @override
  String get privacyPolicyIntroText =>
      'Данная политика конфиденциальности объясняет, как мобильное приложение Story Map собирает, использует и защищает данные пользователей. Используя приложение, вы принимаете данную политику.';

  @override
  String get privacyPolicyCollectedDataTitle => '2. Собираемые данные';

  @override
  String get privacyPolicyLocationData => 'Данные о местоположении';

  @override
  String get privacyPolicyLocationDataText =>
      'Определяет текущее местоположение пользователя для предоставления маршрутов и историй на карте на основе местоположения.';

  @override
  String get privacyPolicyLocationDataText2 =>
      'Местоположение определяется только с разрешения пользователя, фонового отслеживания не осуществляется.';

  @override
  String get privacyPolicyUserDataTitle =>
      'Данные пользователя (при входе через Google аккаунт)';

  @override
  String get privacyPolicyUserDataText =>
      'Имя, фамилия, адрес электронной почты';

  @override
  String get privacyPolicyUserDataText2 => 'Фото профиля';

  @override
  String get privacyPolicyUsingAppTitle =>
      'Информация об использовании приложения';

  @override
  String get privacyPolicyUsingAppText =>
      'Через Firebase могут собираться анонимные данные о поведении пользователя и производительности приложения.';

  @override
  String get privacyPolicyUsingDataTitle => '3. Использование данных';

  @override
  String get privacyPolicyUsingDataText =>
      'Персонализация содержимого приложения';

  @override
  String get privacyPolicyUsingDataText2 =>
      'Предоставление рекомендаций маршрутов и историй на основе местоположения';

  @override
  String get privacyPolicyUsingDataText3 =>
      'Улучшение производительности приложения и пользовательского опыта';

  @override
  String get privacyPolicyUsingDataText4 => 'Анализ и исправление ошибок';

  @override
  String get privacyPolicyThirdPartyServicesTitle => '4. Сторонние сервисы';

  @override
  String get privacyPolicyThirdPartyServicesText =>
      '- Google Firebase (Auth, Firestore, Storage)\n- Google Maps SDK\n- Geolocator и сервисы карт\n\n> Каждый из этих сервисов имеет собственную политику конфиденциальности.';

  @override
  String get privacyPolicyDataStorageTitle =>
      '5. Хранение и безопасность данных';

  @override
  String get privacyPolicyDataStorageText =>
      '- Данные пользователей надежно хранятся в инфраструктуре Firebase.\n- Приложение принимает необходимые технические меры для защиты данных от несанкционированного доступа.';

  @override
  String get privacyPolicyCookiesTitle => '6. Cookies';

  @override
  String get privacyPolicyCookiesText => '- Приложение не использует cookies.';

  @override
  String get privacyPolicyDataSharingTitle => '7. Передача данных';

  @override
  String get privacyPolicyDataSharingText =>
      '- Данные пользователей никогда не передаются, не продаются и не сдаются в аренду третьим лицам.\n- Передача возможна только уполномоченным органам в случае законных требований.';

  @override
  String get privacyPolicyUserRightsTitle => '8. Права пользователей';

  @override
  String get privacyPolicyUserRightsText =>
      '- Пользователи имеют право на доступ, исправление или удаление своих персональных данных.\n- По таким запросам можно обращаться к разработчику:\n📧 Эл. почта: cihanoren1@gmail.com';

  @override
  String get privacyPolicyChangesTitle => '9. Изменения в политике';

  @override
  String get privacyPolicyChangesText =>
      '- Данная политика конфиденциальности может время от времени обновляться.\n- Обновления будут объявляться через приложение или на этой странице.';

  @override
  String get searchPlace => 'Поиск места...';

  @override
  String get help_editAccount_title => 'Как изменить данные учетной записи?';

  @override
  String get help_editAccount_content =>
      'Нажмите на значок настроек на странице профиля, чтобы изменить имя пользователя и адрес электронной почты.';

  @override
  String get help_shareRoute_title => 'Как поделиться маршрутом?';

  @override
  String get help_shareRoute_content =>
      'После создания маршрута используйте опцию \'Поделиться в разделе Исследовать\', чтобы отправить его в раздел Исследовать.';

  @override
  String get help_favorites_title =>
      'Где я могу увидеть понравившиеся маршруты?';

  @override
  String get help_favorites_content =>
      'На странице профиля нажмите на вкладку \'Избранное\', чтобы увидеть ранее понравившиеся маршруты.';

  @override
  String get help_editLocation_title =>
      'Как изменить информацию о местоположении?';

  @override
  String get help_editLocation_content =>
      'На странице профиля нажмите на значок карандаша рядом с местоположением, чтобы вручную ввести ваше местоположение.';

  @override
  String get help_reportIssue_title => 'Как сообщить о проблеме?';

  @override
  String get help_reportIssue_content =>
      'Вы можете связаться с разработчиком через раздел контактов в приложении. Если это не сработает, отправьте письмо на cihanoren10@gmail.com.';

  @override
  String get help_deleteRoute_title => 'Как удалить мои маршруты?';

  @override
  String get help_deleteRoute_content =>
      'Перейдите на страницу деталей маршрута, который вы создали, и используйте опцию \'Удалить\', чтобы навсегда удалить маршрут.';

  @override
  String get help_addFavorites_title => 'Как добавить маршрут в избранное?';

  @override
  String get help_addFavorites_content =>
      'В разделе Исследовать нажмите на значок сердца на понравившемся маршруте, чтобы добавить его в избранное.';

  @override
  String get help_addComment_title => 'Как оставить комментарий?';

  @override
  String get help_addComment_content =>
      'Нажмите на соответствующее место на карте, прокрутите вниз до конца истории и поделитесь своими мыслями в поле \'Оставить комментарий\'.';

  @override
  String get help_changeLanguage_title => 'Как изменить язык?';

  @override
  String get help_changeLanguage_content =>
      'Вы можете изменить язык приложения в разделе настроек, в пункте \'Язык\'.';

  @override
  String get help_notifications_title =>
      'Могу ли я отключить уведомления приложения?';

  @override
  String get help_notifications_content =>
      'Вы можете отключить разрешения на уведомления в настройках устройства или отключить уведомления внутри приложения.';

  @override
  String get help_viewStories_title => 'Как просматривать истории?';

  @override
  String get help_viewStories_content =>
      'Нажмите на значок истории под выбранными местами на карте или в разделе Исследовать, чтобы увидеть опубликованные истории.';

  @override
  String get help_offlineUsage_title =>
      'Можно ли использовать приложение без интернета?';

  @override
  String get help_offlineUsage_content =>
      'Для создания маршрутов и просмотра сохраненных маршрутов требуется интернет-соединение.';

  @override
  String get help_deleteAccount_title => 'Могу ли я удалить свой аккаунт?';

  @override
  String get help_deleteAccount_content =>
      'Чтобы удалить свой аккаунт, свяжитесь с разработчиком через раздел контактов в приложении и укажите ваше имя пользователя и адрес электронной почты.';

  @override
  String get helpCenterTitle => 'Центр помощи';

  @override
  String get sendFeedback => 'Отправить отзыв';

  @override
  String get continueWithApple => 'Продолжить с Apple';
}
