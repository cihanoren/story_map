class UserModel {
  final String uid;
  final String name;
  final String nickname;
  final String email;
  final String profilePhoto;
  final String language;
  final String theme;

  UserModel({
    required this.uid,
    required this.name,
    required this.nickname,
    required this.email,
    required this.profilePhoto,
    required this.language,
    required this.theme,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "nickname": nickname,
        "email": email,
        "profile_photo": profilePhoto,
        "language": language,
        "theme": theme,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json["uid"],
        name: json["name"],
        nickname: json["nickname"],
        email: json["email"],
        profilePhoto: json["profile_photo"],
        language: json["language"],
        theme: json["theme"],
      );
}
