import 'package:enum_to_string/enum_to_string.dart';

import 'bookingsModel.dart';
import 'serviceModel.dart';

class PartnerUser {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? userType;
  DateTime? dob;
  bool? isPartnerRegistered;
  bool? isCustomerRegistered;
  String? about;
  String? uid;
  PartnerDetails? partnerDetails;
  List<Bookings>? bookings;

  PartnerUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.userType,
    this.dob,
    this.about,
    this.uid,
    this.partnerDetails,
    this.bookings,
    this.isCustomerRegistered,
    this.isPartnerRegistered,
  });

  PartnerUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    userType = json['userType'];
    dob = json['dob'];
    about = json['about'];
    uid = json['uid'];
    partnerDetails = json['partnerDetails'] != null
        ? new PartnerDetails.fromJson(json['partnerDetails'])
        : null;
    isCustomerRegistered = json['isCustomerRegistered'];
    isPartnerRegistered = json['isPartnerRegistered'];
  }

  Map<String, dynamic> toJson({bool? print}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['userType'] = this.userType;
    data['dob'] = this.dob;
    data['about'] = this.about;
    data['uid'] = this.uid;
    if (print == true) {
      data['partnerDetails'] = this.partnerDetails?.toJson();
    } else {
      data['partnerDetails'] = this.partnerDetails;
    }

    data['isCustomerRegistered'] = this.isCustomerRegistered;
    data['isPartnerRegistered'] = this.isPartnerRegistered;
    return data;
  }
}

class PartnerDetails {
  String? id;
  bool? approved;
  String? aadharNumber;
  String? accountNumber;
  String? ifsc;
  bool? categorySelected;
  bool? documentsUploaded;
  bool? serviceAreaSelected;
  PartnerAddress? address;
  List<Area>? serviceAreas;
  List<AllServices>? services;
  List<PartnerPendingTaskEnum?>? pendingTasks;
  double? walletBalance;
  List<PartnerCompany>? company;
  bool? isAvailable;
  bool? isZimkeyPartner;
  bool? disableAccount;
  DateTime? unavailableTill;
  Media? photo;
  List<PartnerWalletLog>? walletLogs;

  PartnerDetails(
      {this.id,
      this.aadharNumber,
      this.accountNumber,
      this.address,
      this.approved,
      this.serviceAreaSelected,
      this.ifsc,
      this.categorySelected,
      this.documentsUploaded,
      this.serviceAreas,
      this.services,
      this.pendingTasks,
      this.walletBalance,
      this.company,
      this.isAvailable,
      this.unavailableTill,
      this.photo,
      this.walletLogs,
      this.isZimkeyPartner,
      this.disableAccount});

  PartnerDetails.fromJson(Map<String, dynamic> json) {
    isZimkeyPartner = json['isZimkeyPartner'];
    disableAccount = json['disableAccount'];
    id = json['id'];
    aadharNumber = json['aadharNumber'].toString();
    accountNumber = json['accountNumber'];
    address = json['address'] != null
        ? PartnerAddress.fromJson(json['address'])
        : null;
    approved = json['approved'];
    serviceAreaSelected = json['serviceAreaSelected'];
    ifsc = json['ifsc'];
    categorySelected = json['categorySelected'];
    documentsUploaded = json['documentsUploaded'];
    if (json['serviceAreas'] != null) {
      serviceAreas = [];
      json['serviceAreas'].forEach((v) {
        serviceAreas!.add(new Area.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = [];
      json['services'].forEach((v) {
        services!.add(new AllServices.fromJson(v));
      });
    }
    if (json['pendingTasks'] != null) {
      pendingTasks = [];
      json['pendingTasks'].forEach((v) {
        pendingTasks!
            .add(EnumToString.fromString(PartnerPendingTaskEnum.values, v));
      });
    }
    walletBalance = double.parse(json['walletBalance'].toString()) ?? 0;
    if (json['company'] != null) {
      company = [];
      json['company'].forEach((v) {
        company!.add(new PartnerCompany.fromJson(v));
      });
    }
    isAvailable = json['isAvailable'];
    print("unavailableTill ${json['unavailableTill']}");
    unavailableTill = json['unavailableTill'] == null
        ? null
        : DateTime.tryParse(json['unavailableTill']);
    photo = json['photo'] != null ? Media.fromJson(json['photo']) : null;
    if (json['walletLogs'] != null) {
      walletLogs = [];
      json['walletLogs'].forEach((v) {
        walletLogs!.add(new PartnerWalletLog.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['aadharNumber'] = this.aadharNumber;
    data['accountNumber'] = this.accountNumber;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['serviceAreaSelected'] = this.serviceAreaSelected;
    data['ifsc'] = this.ifsc;
    data['categorySelected'] = this.categorySelected;
    data['documentsUploaded'] = this.documentsUploaded;
    if (this.serviceAreas != null) {
      data['serviceAreas'] = this.serviceAreas!.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    if (this.pendingTasks != null) {
      data['pendingTasks'] = this.pendingTasks!.toList();
    }
    data['walletBalance'] = this.walletBalance;
    if (this.company != null) {
      data['company'] = this.company!.map((v) => v.toJson()).toList();
    }
    data['isAvailable'] = this.isAvailable;
    data['unavailableTill'] = this.unavailableTill;
    if (this.photo != null) {
      data['photo'] = this.photo!.toJson();
    }
    if (this.walletLogs != null) {
      data['walletLogs'] = this.walletLogs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PartnerCompany {
  String? id;
  String? companyName;
  String? companyAddress;

  PartnerCompany({
    this.id,
    this.companyName,
    this.companyAddress,
  });

  PartnerCompany.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyAddress = json['companyAddress'];
    companyName = json['companyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['companyAddress'] = this.companyAddress;
    data['companyName'] = this.companyName;
    return data;
  }
}

enum PartnerPendingTaskEnum {
  UPLOAD_DOCUMENT,
  SELECT_SERVICE,
  SELECT_AREA,
  UPLOAD_PROFILE_PICTURE
}

enum PartnerSignupProgressEnum {
  SIGNUP_COMPLECTED,
  PROFILE_COMPLECTED,
  DOCUMENTS_UPLOADED,
  DOCUMENTS_VERIFIED,
  APPROVED,
  REJECTED,
}

class PartnerRegisterAddressGqlInput {
  String? buildingName;
  String? address;
  String? locality;
  String? landmark;
  String? postalCode;
  String? area;
  bool? isDefault;
  String? city;

  PartnerRegisterAddressGqlInput({
    this.buildingName,
    this.address,
    this.area,
    this.isDefault,
    this.landmark,
    this.locality,
    this.postalCode,
    this.city,
  });

  PartnerRegisterAddressGqlInput.fromJson(Map<String, dynamic> json) {
    buildingName = json['buildingName'];
    address = json['address'];
    locality = json['locality'];
    landmark = json['landmark'];
    isDefault = json['isDefault'];
    area = json['area'];
    postalCode = json['postalCode'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buildingName'] = this.buildingName;
    data['address'] = this.address;
    data['postalCode'] = this.postalCode;
    data['locality'] = locality;
    data['landmark'] = landmark;
    data['isDefault'] = isDefault;
    data['area'] = area;
    data['city'] = city;
    return data;
  }
}

class PartnerAddress {
  String? id;
  String? address;
  String? postalCode;
  String? buildingName;
  String? buildingNumber;
  String? landmark;
  String? locality;
  String? areaId;
  String? area;

  PartnerAddress({
    this.id,
    this.address,
    this.postalCode,
    this.area,
    this.areaId,
    this.buildingName,
    this.buildingNumber,
    this.landmark,
    this.locality,
  });

  PartnerAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    postalCode = json['postalCode'];
    buildingName = json['buildingName'];
    buildingNumber = json['buildingNumber'];
    landmark = json['landmark'];
    locality = json['locality'];
    areaId = json['areaId'];
    landmark = json['landmark'];
    area = json['area'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['postalCode'] = this.postalCode;
    data['buildingName'] = this.buildingName;
    data['buildingNumber'] = this.buildingNumber;
    data['landmark'] = this.landmark;
    data['locality'] = this.locality;
    data['areaId'] = this.areaId;
    data['postalCode'] = this.postalCode;
    data['area'] = this.area;
    return data;
  }
}

class Area {
  String? id;
  String? name;
  String? code;
  List<Pincodes>? pincodes;
  City? city;
  bool? isSelected;

  Area({
    this.id,
    this.name,
    this.code,
    this.city,
    this.pincodes,
    this.isSelected,
  });

  Area.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    city = json['city'] != null ? City.fromJson(json['city']) : null;
    if (json['pinCodes'] != null) {
      pincodes = [];
      json['pinCodes'].forEach((v) {
        pincodes!.add(new Pincodes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    if (this.pincodes != null) {
      data['pinCodes'] = this.pincodes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pincodes {
  String? id;
  String? name;
  String? areaId;
  String? code;
  String? pinCode;

  Pincodes({
    this.id,
    this.name,
    this.code,
    this.areaId,
    this.pinCode,
  });

  Pincodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    pinCode = json['pinCode'];
    areaId = json['areaId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['areaId'] = this.areaId;
    data['pinCode'] = this.pinCode;
    return data;
  }
}

class City {
  String? id;
  String? name;
  String? code;
  List<Area>? areas;

  City({
    this.id,
    this.name,
    this.code,
    this.areas,
  });

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    if (json['areas'] != null) {
      areas = [];
      json['areas'].forEach((v) {
        areas!.add(new Area.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    if (this.areas != null) {
      data['areas'] = this.areas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

enum DeviceTypeEnum { IOS, ANDROID, WEB }

class CmsContent {
  String? id;
  String? aboutUs;
  String? referPolicy;
  String? termsConditions;
  String? privacyPolicy;
  String? safetyPolicy;

  CmsContent({
    this.id,
    this.aboutUs,
    this.referPolicy,
    this.termsConditions,
    this.privacyPolicy,
    this.safetyPolicy,
  });

  CmsContent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    aboutUs = json['aboutUs'];
    referPolicy = json['referPolicy'];
    termsConditions = json['termsConditionsPartner'];
    safetyPolicy = json['safetyPolicy'];
    privacyPolicy = json['privacyPolicy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['aboutUs'] = this.aboutUs;
    data['referPolicy'] = this.referPolicy;
    data['safetyPolicy'] = this.safetyPolicy;
    data['privacyPolicy'] = this.privacyPolicy;
    return data;
  }
}

class UserModel {
  String? name;
  String? email;
  String? id;
  String? phone;
  UserModelType? userType;
  DateTime? dob;
  bool? isCustomerRegistered;
  bool? isPartnerRegistered;
  String? about;
  String? uid;
  CustomerDetails? customerDetails;
  PartnerDetails? partnerDetails;
  List<Bookings>? bookings;

  UserModel({
    this.name,
    this.email,
    this.id,
    this.phone,
    this.userType,
    this.dob,
    this.about,
    this.uid,
    this.customerDetails,
    this.partnerDetails,
    this.bookings,
    this.isCustomerRegistered,
    this.isPartnerRegistered,
  });
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    userType = json['userType'];
    dob = json['dob'] != null ? DateTime.parse(json['dob']).toLocal() : null;
    about = json['about'];
    uid = json['uid'];
    customerDetails = json['customerDetails'] != null
        ? new CustomerDetails.fromJson(json['customerDetails'])
        : null;
    if (json['bookings'] != null) {
      bookings = [];
      json['bookings'].forEach((v) {
        bookings!.add(new Bookings.fromJson(v));
      });
    }
    isCustomerRegistered = json['isCustomerRegistered'];
    isPartnerRegistered = json['isPartnerRegistered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['userType'] = this.userType;
    data['dob'] = this.dob;
    data['uid'] = this.uid;
    if (this.customerDetails != null) {
      data['customerDetails'] = this.customerDetails!.toJson();
    }
    if (this.bookings != null) {
      data['boookings'] = this.bookings!.map((v) => v.toJson()).toList();
    }
    data['isPartnerRegistered'] = this.isPartnerRegistered;
    data['isCustomerRegistered'] = this.isCustomerRegistered;
    return data;
  }
}

class CustomerDetails {
  String? id;
  CustomerAddress? defaultAddress;
  List<CustomerAddress>? addresses;
  List<AllServices>? favoriteServices;

  CustomerDetails({
    this.id,
    this.defaultAddress,
    this.addresses,
    this.favoriteServices,
  });

  CustomerDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['addresses'] != null) {
      addresses = [];
      json['addresses'].forEach((v) {
        addresses!.add(new CustomerAddress.fromJson(v));
      });
    }
    defaultAddress = json['defaultAddress'] != null
        ? new CustomerAddress.fromJson(json['defaultAddress'])
        : null;
    if (json['favoriteServices'] != null) {
      favoriteServices = [];
      json['favoriteServices'].forEach((v) {
        favoriteServices!.add(new AllServices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.defaultAddress != null) {
      data['defaultAddress'] = this.defaultAddress!.toJson();
    }
    if (this.addresses != null) {
      data['addresses'] = this.addresses!.map((v) => v.toJson()).toList();
    }
    if (this.favoriteServices != null) {
      data['favoriteServices'] =
          this.favoriteServices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerAddress {
  String? id;
  String? buildingName;
  String? buildingNumber;
  String? postalCode;
  Area? area;
  String? areaId;
  String? address;
  String? locality;
  bool? isDefault;
  String? city;
  String? addressType;
  String? landmark;
  String? lat;
  String? long;
  String? addressPhone;

  CustomerAddress(
      {this.id,
      this.buildingName,
      this.buildingNumber,
      this.postalCode,
      this.area,
      this.addressType,
      this.isDefault,
      this.city,
      this.landmark,
      this.locality,
      this.lat,
      this.long,
      this.addressPhone,
      this.address,
      this.areaId});

  CustomerAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    buildingName = json['buildingName'];
    buildingNumber = json['buildingNumber'];
    postalCode = json['postalCode'];
    area = json['area'] != null ? Area.fromJson(json['area']) : null;
    addressType = json['addressType'];
    isDefault = json['isDefault'];
    city = json['city'];
    landmark = json['landmark'];
    locality = json['locality'];
    lat = json['lat'];
    long = json['long'];
    addressPhone = json['addressPhone'];
    address = json['address'];
    areaId = json['areaId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['buildingName'] = this.buildingName;
    data['buildingNumber'] = this.buildingNumber;
    data['postalCode'] = this.postalCode;
    if (this.area != null) {
      data['area'] = this.area!.toJson();
    }
    data['addressType'] = this.addressType;
    data['city'] = this.city;
    data['landmark'] = this.landmark;
    data['locality'] = this.locality;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['addressPhone'] = this.addressPhone;
    data['address'] = this.address;
    data['areaId'] = this.areaId;
    return data;
  }
}

enum UserModelType {
  CUSTOMER,
  PARTNER,
  ADMIN,
  PENDING,
}

class PartnerWalletLog {
  String? id;
  double? points;
  DateTime? transactionDate;
  PartnerWalletLogTypeEnum? logType;
  WalletTransactionOriginEnum? source;
  String? refId;
  double? amount;
  String? transferRef;

  PartnerWalletLog(
      {this.id,
      this.points,
      this.logType,
      this.refId,
      this.source,
      this.transactionDate,
      this.transferRef,
      this.amount});

  PartnerWalletLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    points = json['points'];
    amount = json['amount']?.toDouble();
    transactionDate = json['transactionDate'] != null
        ? DateTime.parse(json['transactionDate']).toLocal()
        : null;
    logType = json['logType'] != null
        ? EnumToString.fromString(
            PartnerWalletLogTypeEnum.values, json['logType'])
        : null;
    source = json['source'] != null
        ? EnumToString.fromString(
            WalletTransactionOriginEnum.values, json['source'])
        : null;
    refId = json['refId'];
    transferRef = json['transferRef'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['points'] = this.points;
    data['transactionDate'] = this.transactionDate;
    data['logType'] = this.logType;
    data['source'] = this.source;
    data['refId'] = this.refId;
    data['transferRef'] = this.transferRef;
    return data;
  }
}

enum PartnerWalletLogTypeEnum { CREDIT, DEBIT }

enum WalletTransactionOriginEnum { SYSTEM, ADMIN, PARTNER }
