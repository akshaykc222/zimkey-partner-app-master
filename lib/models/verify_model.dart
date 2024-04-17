class VerifyOtpModel {
  VerifyOtpModel({
    required this.data,
  });

  Welcome2Data data;

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
        data: Welcome2Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Welcome2Data {
  Welcome2Data({
    required this.verifyOtp,
  });

  VerifyOtp verifyOtp;

  factory Welcome2Data.fromJson(Map<String, dynamic> json) => Welcome2Data(
        verifyOtp: VerifyOtp.fromJson(json["verifyOtp"]),
      );

  Map<String, dynamic> toJson() => {
        "verifyOtp": verifyOtp.toJson(),
      };
}

class VerifyOtp {
  VerifyOtp({
    required this.status,
    required this.message,
    required this.data,
  });

  bool status;
  String message;
  VerifyOtpData data;

  factory VerifyOtp.fromJson(Map<String, dynamic> json) => VerifyOtp(
        status: json["status"],
        message: json["message"],
        data: VerifyOtpData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class VerifyOtpData {
  VerifyOtpData({
    required this.isPartnerRegistered,
    required this.token,
    required this.user,
  });

  bool isPartnerRegistered;
  String token;
  User user;

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) => VerifyOtpData(
        isPartnerRegistered: json["isPartnerRegistered"],
        token: json["token"],
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "isPartnerRegistered": isPartnerRegistered,
        "token": token,
        "user": user.toJson(),
      };
}

class User {
  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  String id;
  String name;
  String phone;
  String email;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
      };
}
