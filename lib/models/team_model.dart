class TeamModel {
  TeamModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.partnerId,
    required this.strength,
    required this.members,
    required this.isActive,
    required this.partner,
  });

  String id;
  String uid;
  String name;
  String partnerId;
  String strength;
  List<Member> members;
  bool isActive;
  Partner partner;

  factory TeamModel.fromJson(Map<String, dynamic> json) => TeamModel(
        id: json["id"],
        uid: json["uid"],
        name: json["name"],
        partnerId: json["partnerId"],
        strength: json["strength"],
        members:
            List<Member>.from(json["members"].map((x) => Member.fromJson(x))),
        isActive: json["isActive"],
        partner: Partner.fromJson(json["partner"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "name": name,
        "partnerId": partnerId,
        "strength": strength,
        "members": List<dynamic>.from(members.map((x) => x.toJson())),
        "isActive": isActive,
        "partner": partner.toJson(),
      };
}

class Member {
  Member({
    required this.id,
    required this.name,
    required this.uid,
    required this.phone,
    required this.rank,
    required this.isActive,
  });

  String id;
  String name;
  String uid;
  String phone;
  String rank;
  bool isActive;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json["id"],
        name: json["name"],
        uid: json["uid"],
        phone: json["phone"],
        rank: json["rank"],
        isActive: json["isActive"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "uid": uid,
        "phone": phone,
        "rank": rank,
        "isActive": isActive,
      };
}

class Partner {
  Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.dob,
    this.gender,
    this.uid,
  });

  String id;
  String name;
  String email;
  String phone;
  dynamic dob;
  dynamic gender;
  dynamic uid;

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        dob: json["dob"],
        gender: json["gender"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "dob": dob,
        "gender": gender,
        "uid": uid,
      };
}
