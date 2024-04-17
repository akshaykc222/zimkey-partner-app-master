import 'package:enum_to_string/enum_to_string.dart';

import 'jobModel.dart';
import 'partnerModel.dart';
import 'serviceModel.dart';

class Bookings {
  String? id;
  String? orderRefId;
  String? userId;
  UserModel? user;
  PaymentInfo? paymentDetails;
  DateTime? bookingDate;
  String? bookingStatus;
  BookingAddress? bookingAddress;
  BookingServices? bookingService;
  String? bookingNote;

  // int totalPrice;
  String? userBookingNumber;

  // double pendingPayment;
  List<BookingPayment>? bookingPayments;
  PendingAmount? pendingAmount;
  BookingAmount? bookingAmount;

  Bookings(
      {this.id,
      this.orderRefId,
      this.userId,
      this.bookingDate,
      this.bookingStatus,
      this.bookingAddress,
      this.bookingService,
      this.bookingNote,
      // this.totalPrice,
      this.userBookingNumber,
      // this.pendingPayment,
      this.paymentDetails,
      this.user,
      this.bookingPayments});

  Bookings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderRefId = json['orderRefId'];
    userId = json['userId'];
    bookingDate = json['bookingDate'] != null
        ? DateTime.parse(json['bookingDate']).toLocal()
        : null;
    bookingStatus = json['bookingStatus'];
    bookingAddress = json['bookingAddress'] != null
        ? new BookingAddress.fromJson(json['bookingAddress'])
        : null;
    bookingService = json['bookingService'] != null
        ? new BookingServices.fromJson(json['bookingService'])
        : null;
    bookingNote = json['bookingNote'];
    // totalPrice = json['totalPrice'];
    userBookingNumber = json['userBookingNumber'];
    user = json['user'] != null ? new UserModel.fromJson(json['user']) : null;
    pendingAmount = json['pendingAmount'] != null
        ? PendingAmount.fromJson(json['pendingAmount'])
        : null;
    bookingAmount = json['bookingAmount'] != null
        ? BookingAmount.fromJson(json['bookingAmount'])
        : null;
    if (json['bookingPayments'] != null) {
      bookingPayments = <BookingPayment>[];
      json['bookingPayments'].forEach((v) {
        bookingPayments!.add(new BookingPayment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['orderRefId'] = this.orderRefId;
    data['userId'] = this.userId;
    data['bookingDate'] = this.bookingDate;
    data['bookingStatus'] = this.bookingStatus;
    if (this.bookingAddress != null) {
      data['bookingAddress'] = this.bookingAddress!.toJson();
    }
    if (this.bookingService != null) {
      data['bookingService'] = this.bookingService!.toJson();
    }
    // data['totalPrice'] = this.totalPrice;
    data['userBookingNumber'] = this.userBookingNumber;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.bookingAmount != null) {
      data['bookingAmount'] = this.bookingAmount!.toJson();
    }
    if (this.pendingAmount != null) {
      data['pendingAmount'] = this.pendingAmount!.toJson();
    }
    if (this.bookingPayments != null) {
      data['bookingPayments'] =
          this.bookingPayments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentInfo {
  String? paymentId;
  String? orderId;
  String? signature;

  PaymentInfo({
    this.orderId,
    this.paymentId,
    this.signature,
  });

  PaymentInfo.fromJson(Map<String, dynamic> json) {
    paymentId = json['paymentId'];
    orderId = json['orderId'];
    signature = json['signature'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paymentId'] = this.paymentId;
    data['orderId'] = this.orderId;
    data['signature'] = this.signature;

    return data;
  }
}

class BookingAddress {
  String? address;
  String? id;
  String? bookingId;
  String? buildingName;
  String? buildingNumber;
  String? addressType;
  String? areaId;
  String? postalCode;
  String? landmark;
  String? locality;
  Area? area;

  BookingAddress({
    this.address,
    this.id,
    this.bookingId,
    this.buildingName,
    this.buildingNumber,
    this.addressType,
    this.area,
    this.areaId,
    this.landmark,
    this.postalCode,
    this.locality,
  });

  BookingAddress.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    id = json['id'];
    bookingId = json['bookingId'];
    buildingName = json['buildingName'];
    buildingNumber = json['buildingNumber'];
    addressType = json['addressType'];
    area = json['area'] != null ? new Area.fromJson(json['area']) : null;
    areaId = json['areaId'];
    landmark = json['landmark'];
    postalCode = json['postalCode'];
    locality = json['locality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['id'] = this.id;
    data['bookingId'] = this.bookingId;
    data['buildingName'] = this.buildingName;
    data['buildingNumber'] = this.buildingNumber;
    if (this.area != null) {
      data['area'] = this.area!.toJson();
    }
    data['locality'] = this.locality;
    return data;
  }
}

class BookingServices {
  String? id;
  String? serviceId;
  PartnerUser? servicePartner;
  int? units;
  int? unitPrice;
  ServiceUnit? unit;
  int? totalPrice;
  int? qty;
  String? servicePartnerId;
  String? serviceBillingOptionId;
  String? bookingId;
  List<BookingServiceItems>? bookingServiceItems;
  AllServices? service;
  ServiceBillingOption? serviceBillingOption;
  bool? recurring;
  List<BookingServiceInputs>? bookingServiceInputs;
  List<String>? serviceRequirements;
  List<BookingAdditionalPayment>? bookingAdditionalPayments;

  BookingServices({
    this.id,
    this.serviceId,
    this.servicePartner,
    this.units,
    this.unitPrice,
    this.servicePartnerId,
    this.serviceBillingOptionId,
    this.bookingId,
    this.bookingServiceItems,
    this.service,
    this.bookingServiceInputs,
    this.qty,
    this.recurring,
    this.totalPrice,
    this.unit,
  });

  BookingServices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    print("from json ${json}");
    serviceBillingOption = json['serviceBillingOption'] == null
        ? null
        : ServiceBillingOption.fromJson(json['serviceBillingOption']);
    serviceId = json['serviceId'];
    servicePartner = json['servicePartner'] != null
        ? PartnerUser.fromJson(json['servicePartner'])
        : null;
    units = json['units'];
    unitPrice = json['unitPrice'];
    servicePartnerId = json['servicePartnerId'];
    serviceBillingOptionId = json['serviceBillingOptionId'];
    bookingId = json['bookingId'];
    if (json['bookingServiceItems'] != null) {
      bookingServiceItems = <BookingServiceItems>[];
      json['bookingServiceItems'].forEach((v) {
        bookingServiceItems!.add(new BookingServiceItems.fromJson(v));
      });
    }
    service = json['service'] != null
        ? new AllServices.fromJson(json['service'])
        : null;
    if (json['bookingServiceInputs'] != null) {
      bookingServiceInputs = <BookingServiceInputs>[];
      json['bookingServiceInputs'].forEach((v) {
        bookingServiceInputs!.add(new BookingServiceInputs.fromJson(v));
      });
    }
    qty = json['qty'];
    recurring = json['recurring'];
    totalPrice = json['totalPrice'];
    unit = json['unit'] != null
        ? EnumToString.fromString(ServiceUnit.values, json['unit'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['serviceId'] = this.serviceId;
    data['servicePartner'] = this.servicePartner;
    data['units'] = this.units;
    data['unitPrice'] = this.unitPrice;
    data['servicePartnerId'] = this.servicePartnerId;
    data['serviceBillingOptionId'] = this.serviceBillingOptionId;
    data['bookingId'] = this.bookingId;
    if (this.bookingServiceItems != null) {
      data['bookingServiceItems'] =
          this.bookingServiceItems!.map((v) => v.toJson()).toList();
    }
    if (this.service != null) {
      data['service'] = this.service!.toJson();
    }
    return data;
  }
}

class BookingServiceInputs {
  String? id;
  String? bookingServiceId;
  String? value;
  String? name;
  String? key;
  ServiceInputType? type;

  BookingServiceInputs({
    this.bookingServiceId,
    this.id,
    this.key,
    this.name,
    this.type,
    this.value,
  });

  BookingServiceInputs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingServiceId = json['bookingServiceId'];
    name = json['name'];
    key = json['key'];
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bookingServiceId'] = this.bookingServiceId;
    data['key'] = this.key;
    data['value'] = this.value;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }
}

class BookingServiceItems {
  String? id;
  String? bookingServiceId;
  BookingServiceItemStatusTypeEnum? bookingServiceItemStatus;
  DateTime? startDateTime;
  DateTime? actualStartDateTime;
  DateTime? endDateTime;
  String? servicePartnerId;
  BookingService? bookingService;
  List<BookingServiceItemReschedules>? reschedules;
  List<BookingServiceItems>? subBookings;
  List<BookingAddons>? bookingAddons;
  String? workCode;
  BookingServiceItemTypeEnum? bookingServiceItemType;
  String? modificationReason;
  bool? canRework;
  bool? canReschedule;
  bool? canUncommit;
  bool? canCancel;
  bool? canStartJob;
  PendingRescheduleByCustomer? pendingRescheduleByCustomer;
  List<AdditionalWork> additionalWork = [];

  BookingServiceItems(
      {this.id,
      this.bookingServiceId,
      this.bookingServiceItemStatus,
      this.startDateTime,
      this.endDateTime,
      this.servicePartnerId,
      this.bookingService,
      this.reschedules,
      this.subBookings,
      this.bookingAddons,
      this.workCode,
      this.bookingServiceItemType,
      this.modificationReason,
      this.canCancel,
      this.canReschedule,
      this.canRework,
      this.canUncommit,
      this.canStartJob,
      this.actualStartDateTime,
      this.pendingRescheduleByCustomer});

  BookingServiceItems.fromJson(Map<String, dynamic> json) {
    additionalWork = json['additionalWorks'] == null
        ? []
        : List<AdditionalWork>.from(
            json['additionalWorks'].map((e) => AdditionalWork.fromJson(e)));
    pendingRescheduleByCustomer = json['pendingRescheduleByCustomer'] == null
        ? null
        : PendingRescheduleByCustomer.fromJson(
            json['pendingRescheduleByCustomer']);
    actualStartDateTime = json['actualStartDateTime'] == null
        ? null
        : DateTime.parse(json['actualStartDateTime']);
    id = json['id'];
    canStartJob = json['canStartJob'];
    bookingServiceId = json['bookingServiceId'];
    bookingServiceItemStatus = json['bookingServiceItemStatus'] != null
        ? EnumToString.fromString(BookingServiceItemStatusTypeEnum.values,
            json['bookingServiceItemStatus'])
        : null;
    startDateTime = json['startDateTime'] != null
        ? DateTime.parse(json['startDateTime']).toLocal()
        : null;
    endDateTime = json['endDateTime'] != null
        ? DateTime.parse(json['endDateTime']).toLocal()
        : null;
    servicePartnerId = json['servicePartnerId'];
    bookingService = json['bookingService'] != null
        ? new BookingService.fromJson(json['bookingService'])
        : null;
    if (json['bookingAddons'] != null) {
      bookingAddons = <BookingAddons>[];
      json['bookingAddons'].forEach((v) {
        bookingAddons!.add(new BookingAddons.fromJson(v));
      });
    }
    if (json['subBookings'] != null) {
      subBookings = <BookingServiceItems>[];
      json['subBookings'].forEach((v) {
        subBookings!.add(new BookingServiceItems.fromJson(v));
      });
    }
    workCode = json['workCode'];
    bookingServiceItemType = json['bookingServiceItemType'] != null
        ? EnumToString.fromString(
            BookingServiceItemTypeEnum.values, json['bookingServiceItemType'])
        : null;
    modificationReason = json['modificationReason'];
    if (json['reschedules'] != null) {
      reschedules = <BookingServiceItemReschedules>[];
      json['reschedules'].forEach((v) {
        reschedules!.add(new BookingServiceItemReschedules.fromJson(v));
      });
    }
    canCancel = json['canCancel'];
    canReschedule = json['canReschedule'];
    canRework = json['canRework'];
    canUncommit = json['canUncommit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['canStartJob'] = this.canStartJob;
    data['bookingServiceId'] = this.bookingServiceId;
    data['bookingServiceItemStatus'] = this.bookingServiceItemStatus;
    data['startDateTime'] = this.startDateTime;
    data['endDateTime'] = this.endDateTime;
    data['servicePartnerId'] = this.servicePartnerId;
    if (this.bookingService != null) {
      data['bookingService'] = this.bookingService!.toJson();
    }
    if (this.bookingAddons != null) {
      data['bookingAddons'] =
          this.bookingAddons!.map((v) => v.toJson()).toList();
    }
    if (this.subBookings != null) {
      data['subBookings'] = this.subBookings!.map((v) => v.toJson()).toList();
    }
    data['workCode'] = this.workCode;
    data['bookingServiceItemType'] = this.bookingServiceItemType;
    data['modificationReason'] = this.modificationReason;
    data['canCancel'] = this.canCancel;
    data['canReschedule'] = this.canReschedule;
    data['canRework'] = this.canRework;
    data['canUncommit'] = this.canUncommit;
    return data;
  }
}

enum BookingServiceItemTypeEnum {
  PRIMARY,
  REWORK,
  ADDITIONAL,
}

class AdditionalPaymentRefundInput {
  String? bookingAdditionalPaymentId;
  double? amount;

  AdditionalPaymentRefundInput({
    this.amount,
    this.bookingAdditionalPaymentId,
  });

  AdditionalPaymentRefundInput.fromJson(Map<String, dynamic> json) {
    bookingAdditionalPaymentId = json['bookingAdditionalPaymentId'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bookingAdditionalPaymentId'] = this.bookingAdditionalPaymentId;
    data['amount'] = this.amount;
    return data;
  }
}

//for createbooking
class BookingInput {
  String? addressId;
  String? message;
  List<BookingServiceInput>? services;

  BookingInput({
    this.addressId,
    this.message,
    this.services,
  });

  BookingInput.fromJson(Map<String, dynamic> json) {
    addressId = json['addressId'];
    message = json['message'];
    if (json['bookingServiceItems'] != null) {
      services = <BookingServiceInput>[];
      json['services'].forEach((v) {
        services!.add(new BookingServiceInput.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addressId'] = this.addressId;
    data['message'] = this.message;
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingServiceInput {
  String? serviceOptionId;
  int? units;
  int? qty;
  String? startDateTime;
  List<BookingServiceAdditionalInput>? additionalInputs;
  List<String>? serviceRequirementIds;

  BookingServiceInput(
      {this.additionalInputs,
      this.qty = 1,
      this.serviceOptionId,
      this.startDateTime,
      this.units,
      this.serviceRequirementIds});

  BookingServiceInput.fromJson(Map<String, dynamic> json) {
    additionalInputs = json['additionalInputs'];
    serviceOptionId = json['serviceOptionId'];
    startDateTime = json['startDateTime'];
    // ? DateTime.parse(json['startDateTime'])
    // : null;
    if (json['additionalInputs'] != null) {
      additionalInputs = <BookingServiceAdditionalInput>[];
      json['additionalInputs'].forEach((v) {
        additionalInputs!.add(new BookingServiceAdditionalInput.fromJson(v));
      });
    }
    serviceRequirementIds = json['serviceRequirementIds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['additionalInputs'] = this.additionalInputs;
    data['serviceOptionId'] = this.serviceOptionId;
    data['startDateTime'] = this.startDateTime;
    if (this.additionalInputs != null) {
      data['additionalInputs'] =
          this.additionalInputs!.map((v) => v.toJson()).toList();
    }
    data['serviceRequirementIds'] = this.serviceRequirementIds;
    return data;
  }
}

class BookingServiceAdditionalInput {
  String? inputId;
  String? value;

  BookingServiceAdditionalInput({this.inputId, this.value});

  BookingServiceAdditionalInput.fromJson(Map<String, dynamic> json) {
    inputId = json['inputId'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['inputId'] = this.inputId;
    data['value'] = this.value;
    return data;
  }
}

class PaymentCardItem {
  // final CreditCardType cardtype;
  final String cardnumber;
  final String cardHoldername;
  final String cardExpiry;
  final String cardCvv;
  final bool isSaved;
  final String cardImg;

  PaymentCardItem(this.cardnumber, this.cardHoldername, this.cardExpiry,
      this.cardCvv, this.isSaved, this.cardImg);
}

class AddressAreas {
  final String area;
  final String pincode;

  AddressAreas(this.area, this.pincode);
}

class BookingServiceAddonGqlInput {
  String? addonId;
  double? units;

  BookingServiceAddonGqlInput({
    this.addonId,
    this.units,
  });
}

class BookingPayment {
  String? id;
  String? orderId;
  String? paymentId;
  double? amount;
  double? amountPaid;
  double? amountDue;
  String? currency;
  String? status;
  int? attempts;
  int? invoiceNumber;
  String? bookingId;

  BookingPayment({
    this.amount,
    this.amountDue,
    this.amountPaid,
    this.attempts,
    this.bookingId,
    this.currency,
    this.id,
    this.invoiceNumber,
    this.orderId,
    this.paymentId,
    this.status,
  });

  BookingPayment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['orderId'];
    paymentId = json['paymentId'];
    amount =
        json['amount'] != null ? double.parse(json['amount'].toString()) : 0;
    amountPaid = json['amountPaid'] != null
        ? double.parse(json['amountPaid'].toString())
        : 0;
    amountDue = json['amountDue'] != null
        ? double.parse(json['amountDue'].toString())
        : 0;
    currency = json['currency'];
    status = json['status'];
    attempts = json['attempts'];
    invoiceNumber = json['invoiceNumber'];
    bookingId = json['bookingId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['amount'] = this.amount;
    data['amountDue'] = this.amountDue;
    data['orderId'] = this.orderId;
    data['paymentId'] = this.paymentId;
    data['amountPaid'] = this.amountPaid;
    data['currency'] = this.currency;
    data['status'] = this.status;
    data['attempts'] = this.attempts;
    data['invoiceNumber'] = this.invoiceNumber;
    data['bookingId'] = this.bookingId;
    return data;
  }
}

class PendingAmount {
  double? amount;

  PendingAmount([this.amount]);

  PendingAmount.fromJson(Map<String, dynamic> json) {
    amount =
        json['amount'] != null ? double.parse(json['amount'].toString()) : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    return data;
  }
}

class BookingAmount {
  double? totalPartnerPrice;
  double? totalCommission;
  double? totalCommissionTax;
  double? totalPartnerTax;
  double? totalDiscount;
  double? totalRefundable;
  double? totalRefunded;

  BookingAmount({
    this.totalCommission,
    this.totalCommissionTax,
    this.totalDiscount,
    this.totalPartnerPrice,
    this.totalPartnerTax,
    this.totalRefundable,
    this.totalRefunded,
  });

  BookingAmount.fromJson(Map<String, dynamic> json) {
    totalCommission = json['totalCommission'] != null
        ? double.parse(json['totalCommission'].toString())
        : 0;
    totalCommissionTax = json['totalCommissionTax'] != null
        ? double.parse(json['totalCommissionTax'].toString())
        : 0;
    totalDiscount = json['totalDiscount'] != null
        ? double.parse(json['totalDiscount'].toString())
        : 0;
    totalPartnerPrice = json['totalPartnerPrice'] != null
        ? double.parse(json['totalPartnerPrice'].toString())
        : 0;
    totalPartnerTax = json['totalPartnerTax'] != null
        ? double.parse(json['totalPartnerTax'].toString())
        : 0;
    totalRefundable = json['totalRefundable'] != null
        ? double.parse(json['totalRefundable'].toString())
        : 0;
    totalRefunded = json['totalRefunded'] != null
        ? double.parse(json['totalRefunded'].toString())
        : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCommission'] = this.totalCommission;
    data['totalCommissionTax'] = this.totalCommissionTax;
    data['totalDiscount'] = this.totalDiscount;
    data['totalPartnerPrice'] = this.totalPartnerPrice;
    data['totalPartnerTax'] = this.totalPartnerTax;
    data['totalRefundable'] = this.totalRefundable;
    data['totalRefunded'] = this.totalRefunded;
    return data;
  }
}
