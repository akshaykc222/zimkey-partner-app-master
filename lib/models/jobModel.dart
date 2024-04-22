import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';

import 'bookingsModel.dart';
import 'partnerModel.dart';
import 'serviceModel.dart';

class JobBoard extends Equatable {
  String? id;
  DateTime? jobDate;
  DateTime? addedDate;
  String? jobAreaId;
  Area? jobArea;
  String? jobServiceId;
  AllServices? jobService;
  String? bookingId;
  Bookings? booking;
  String? bookingServiceId;
  BookingService? bookingService;
  String? adminNote;
  JobPriorityEnum? jobPriority;
  BookingServiceItem? bookingServiceItem;

  JobBoard({this.id, this.jobDate, this.jobServiceId, this.jobPriority});

  JobBoard.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jobDate = json['jobDate'] != null
        ? DateTime.parse(json['jobDate']).toLocal()
        : null;
    jobServiceId = json['jobServiceId'];
    jobPriority = json['jobPriority'] != null
        ? EnumToString.fromString(JobPriorityEnum.values, json['jobPriority'])
        : null;
    jobArea =
        json['jobArea'] != null ? new Area.fromJson(json['jobArea']) : null;
    bookingService = json['bookingService'] != null
        ? new BookingService.fromJson(json['bookingService'])
        : null;
    jobServiceId = json['jobServiceId'];
    jobService = json['jobService'] != null
        ? new AllServices.fromJson(json['jobService'])
        : null;
    bookingServiceItem = json['bookingServiceItem'] != null
        ? new BookingServiceItem.fromJson(json['bookingServiceItem'])
        : null;
    booking =
        json['booking'] != null ? new Bookings.fromJson(json['booking']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['jobDate'] = this.jobDate;
    data['jobServiceId'] = this.jobServiceId;
    data['jobPriority'] = this.jobPriority;
    if (this.jobArea != null) {
      data['jobArea'] = this.jobArea!.toJson();
    }
    if (this.bookingService != null) {
      data['bookingService'] = this.bookingService!.toJson();
    }
    if (this.jobService != null) {
      data['jobService'] = this.jobService!.toJson();
    }
    if (this.booking != null) {
      data['booking'] = this.booking!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [id];
}

class BookingService {
  String? id;
  int? unitPrice;
  int? totalAdditional;
  int? totalAddon;
  List<String>? serviceRequirements;
  int? units;
  ServiceUnitEnum? unit;

  int? totalPrice;
  int? qty;
  String? serviceId;
  AllServices? service;
  bool? recurring;
  List<PartnerUser>? servicePartners;
  ServiceBillingOption? serviceBillingOption;
  String? serviceBillingOptionId;
  String? bookingId;
  Bookings? booking;
  List<BookingServiceInputs>? bookingServiceInputs;
  List<BookingServiceItem>? bookingServiceItems;
  List<BookingAdditionalPayment>? bookingAdditionalPayments;

  BookingService({
    this.booking,
    this.bookingAdditionalPayments,
    this.bookingId,
    this.bookingServiceInputs,
    this.bookingServiceItems,
    this.id,
    this.qty,
    this.serviceBillingOption,
    this.recurring,
    this.service,
    this.serviceBillingOptionId,
    this.serviceId,
    this.servicePartners,
    this.serviceRequirements,
    this.totalAdditional,
    this.totalAddon,
    this.totalPrice,
    this.unit,
    this.unitPrice,
    this.units,
  });

  BookingService.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    unit = json['unit'] != null
        ? EnumToString.fromString(ServiceUnitEnum.values, json['unit'])
        : null;
    units = json['units'];
    unitPrice = json['unitPrice'];
    totalPrice = json['totalPrice'];
    recurring = json['recurring'];
    serviceBillingOption = json['serviceBillingOption'] == null
        ? null
        : ServiceBillingOption.fromJson(json['serviceBillingOption']);
    serviceBillingOptionId = json['serviceBillingOptionId'];
    if (json['bookingServiceInputs'] != null) {
      bookingServiceInputs = <BookingServiceInputs>[];
      json['bookingServiceInputs'].forEach((v) {
        bookingServiceInputs!.add(new BookingServiceInputs.fromJson(v));
      });
    }
    if (json['serviceRequirements'] != null) {
      serviceRequirements = <String>[];
      json['serviceRequirements'].forEach((v) {
        serviceRequirements!.add(v);
      });
    }
    if (json['bookingAdditionalPayments'] != null) {
      bookingAdditionalPayments = <BookingAdditionalPayment>[];
      json['bookingAdditionalPayments'].forEach((v) {
        bookingAdditionalPayments!
            .add(new BookingAdditionalPayment.fromJson(v));
      });
    }
    service = json['service'] != null
        ? new AllServices.fromJson(json['service'])
        : null;
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['unit'] = this.unit;
    data['units'] = this.units;
    data['unitPrice'] = this.unitPrice;
    data['totalPrice'] = this.totalPrice;
    data['recurring'] = this.recurring;
    data['serviceBillingOptionId'] = this.serviceBillingOptionId;
    if (this.bookingServiceInputs != null) {
      data['bookingServiceInputs'] =
          this.bookingServiceInputs!.map((v) => v.toJson()).toList();
    }
    if (this.serviceRequirements != null) {
      data['serviceRequirements'] =
          this.serviceRequirements!.map((v) => v).toList();
    }
    if (this.service != null) {
      data['service'] = this.service!.toJson();
    }
    data['qty'] = this.qty;
    return data;
  }
}

//----------------------------
class BookingAdditionalPayment {
  String? id;
  ItemPrice? itemPrice;
  String? name;
  String? description;
  bool? refundable;
  bool? mandatory;
  String? bookingServiceItemId;
  String? refundRefId;

  BookingAdditionalPayment({
    this.bookingServiceItemId,
    this.description,
    this.id,
    this.mandatory,
    this.name,
    this.itemPrice,
    this.refundRefId,
    this.refundable,
  });

  BookingAdditionalPayment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemPrice = json['itemPrice'] != null
        ? new ItemPrice.fromJson(json['itemPrice'])
        : null;
    name = json['name'];
    mandatory = json['mandatory'];
    refundRefId = json['refundRefId'];
    refundable = json['refundable'];
    bookingServiceItemId = json['bookingServiceItemId'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.itemPrice != null) {
      data['itemPrice'] = this.itemPrice!.toJson();
    }
    data['name'] = this.name;
    data['mandatory'] = this.mandatory;
    data['refundRefId'] = this.refundRefId;
    data['refundable'] = this.refundable;
    data['description'] = this.description;
    return data;
  }
}

//-----------------------
class BookingServiceItem {
  String? id;
  String? bookingServiceId;
  bool? servicePartnerApproval;
  BookingServiceItemTypeEnum? bookingServiceItemType;
  List<BookingServiceItemReschedules>? reschedules;
  BookingServiceItemStatusTypeEnum? bookingServiceItemStatus;
  String? servicePartnerId;
  List<BookingAddons>? bookingAddons;
  DateTime? startDateTime;
  DateTime? endDateTime;
  List<BookingServiceItem>? subBookings;
  String? workCode;
  String? modificationReason;
  bool? canRework;
  bool? canReschedule;
  bool? canUncommit;
  bool? canCancel;
  PendingRescheduleByCustomer? pendingRescheduleByCustomer;
  List<AdditionalWork> additionalWorks = [];

  BookingServiceItem(
      {this.id,
      this.bookingServiceId,
      this.bookingServiceItemStatus,
      this.startDateTime,
      this.endDateTime,
      this.servicePartnerId,
      this.bookingAddons,
      this.bookingServiceItemType,
      this.reschedules,
      this.servicePartnerApproval,
      this.subBookings,
      this.workCode,
      this.modificationReason,
      this.canCancel,
      this.canReschedule,
      this.canRework,
      this.canUncommit,
      this.pendingRescheduleByCustomer});

  BookingServiceItem.fromJson(Map<String, dynamic> json) {
    additionalWorks = List<AdditionalWork>.from(
        json["additionalWorks"].map((x) => AdditionalWork.fromJson(x)));
    pendingRescheduleByCustomer = PendingRescheduleByCustomer.fromJson(
        json['pendingRescheduleByCustomer']);
    id = json['id'];
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
    bookingServiceItemType = json['bookingServiceItemType'] != null
        ? EnumToString.fromString(
            BookingServiceItemTypeEnum.values, json['bookingServiceItemType'])
        : null;
    if (json['bookingAddons'] != null) {
      bookingAddons = <BookingAddons>[];
      json['bookingAddons'].forEach((v) {
        bookingAddons!.add(new BookingAddons.fromJson(v));
      });
    }
    if (json['reschedules'] != null) {
      reschedules = <BookingServiceItemReschedules>[];
      json['reschedules'].forEach((v) {
        reschedules!.add(new BookingServiceItemReschedules.fromJson(v));
      });
    }
    if (json['subBookings'] != null) {
      subBookings = <BookingServiceItem>[];
      json['subBookings'].forEach((v) {
        subBookings!.add(new BookingServiceItem.fromJson(v));
      });
    }
    workCode = json['workCode'];
    modificationReason = json['modificationReason'];
    canCancel = json['canCancel'];
    canReschedule = json['canReschedule'];
    canRework = json['canRework'];
    canUncommit = json['canUncommit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bookingServiceId'] = this.bookingServiceId;
    data['bookingServiceItemStatus'] = this.bookingServiceItemStatus;
    data['startDateTime'] = this.startDateTime;
    data['endDateTime'] = this.endDateTime;
    data['servicePartnerId'] = this.servicePartnerId;
    data['bookingServiceItemType'] = this.bookingServiceItemType;
    if (this.bookingAddons != null) {
      data['bookingServiceInputs'] =
          this.bookingAddons!.map((v) => v.toJson()).toList();
    }
    if (this.reschedules != null) {
      data['reschedules'] = this.reschedules!.map((v) => v.toJson()).toList();
    }
    if (this.subBookings != null) {
      data['subBookings'] = this.subBookings!.map((v) => v.toJson()).toList();
    }
    data['workCode'] = this.workCode;
    data['modificationReason'] = this.modificationReason;
    data['canCancel'] = this.canCancel;
    data['canReschedule'] = this.canReschedule;
    data['canRework'] = this.canRework;
    data['canUncommit'] = this.canUncommit;
    return data;
  }
}

class PendingRescheduleByCustomer {
  final DateTime startDateTime;
  final DateTime endDateTime;

  PendingRescheduleByCustomer({
    required this.startDateTime,
    required this.endDateTime,
  });

  factory PendingRescheduleByCustomer.fromJson(Map<String, dynamic> json) =>
      PendingRescheduleByCustomer(
        startDateTime: DateTime.parse(json["startDateTime"]),
        endDateTime: DateTime.parse(json["endDateTime"]),
      );

  Map<String, dynamic> toJson() => {
        "startDateTime": startDateTime.toIso8601String(),
        "endDateTime": endDateTime.toIso8601String(),
      };
}

class BookingServiceItemReschedules {
  DateTime? oldTime;
  String? rescheduledBy;

  BookingServiceItemReschedules({
    this.rescheduledBy,
    this.oldTime,
  });

  BookingServiceItemReschedules.fromJson(Map<String, dynamic> json) {
    oldTime = json['oldTime'] != null ? DateTime.parse(json['oldTime']) : null;
    rescheduledBy = json['rescheduledBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.oldTime;
    data['rescheduledBy'] = this.rescheduledBy;
    return data;
  }
}

class BookingAddons {
  String? name;
  AddonAddedByEnum? addedBy;
  ServiceUnitEnum? unit;
  int? unitPrice;
  int? units;
  String? addonId;
  String? bookingServiceItemId;

  BookingAddons({
    this.addedBy,
    this.addonId,
    this.bookingServiceItemId,
    this.name,
    this.unit,
    this.unitPrice,
    this.units,
  });

  BookingAddons.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    addedBy = json['addedBy'] != null
        ? EnumToString.fromString(AddonAddedByEnum.values, json['addedBy'])
        : null;
    unit = json['unit'] != null
        ? EnumToString.fromString(ServiceUnitEnum.values, json['unit'])
        : null;
    unitPrice = json['unitPrice'];
    units = json['units'];
    addonId = json['addonId'];
    bookingServiceItemId = json['bookingServiceItemId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.name;
    data['unit'] = this.unit;
    data['unitPrice'] = this.unitPrice;
    data['units'] = this.units;
    data['addedBy'] = this.addedBy;
    data['addonId'] = this.addonId;
    data['bookingServiceItemId'] = this.bookingServiceItemId;
    return data;
  }
}

enum AddonAddedByEnum {
  ADMIN,
  CUSTOMER,
  PARTNER,
}

enum BookingServiceItemTypeEnum { PRIMARY, REWORK, ADDITIONAL }

enum BookingServiceItemStatusTypeEnum {
  OPEN,
  PARTNER_ASSIGNED,
  PARTNER_APPROVAL_PENDING,
  CUSTOMER_APPROVAL_PENDING,
  PAYMENT_PENDING,
  IN_PROGRESS,
  CLOSED,
  CANCELED
}

enum JobPriorityEnum {
  HIGH,
  MEDIUM,
  LOW,
}

class PartnerCalendar {
  String? id;
  DateTime? date;
  List<PartnerCalendarItem>? services;

  PartnerCalendar({
    this.date,
    this.id,
    this.services,
  });

  PartnerCalendar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'] != null ? DateTime.parse(json['date']).toLocal() : null;
    if (json['services'] != null) {
      services = <PartnerCalendarItem>[];
      json['services'].forEach((v) {
        services!.add(new PartnerCalendarItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PartnerCalendarItem extends Equatable {
  String? id;
  DateTime? serviceDate;
  String? partnerId;
  PartnerUser? partner;
  String? bookingId;
  Bookings? booking;
  String? bookingServiceItemId;
  String? refBookingServiceItemId;
  BookingServiceItems? bookingServiceItem;
  String? adminNote;
  String? partnerNote;

  PartnerCalendarStatusTypeEnum? partnerCalendarStatus;
  List<Team>? team;

  PartnerCalendarItem(
      {this.adminNote,
      this.booking,
      this.bookingId,
      this.bookingServiceItem,
      this.bookingServiceItemId,
      this.refBookingServiceItemId,
      this.id,
      this.partner,
      this.partnerId,
      this.partnerNote,
      this.serviceDate,
      this.partnerCalendarStatus,
      this.team});

  PartnerCalendarItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceDate = json['serviceDate'] != null
        ? DateTime.parse(json['serviceDate']).toLocal()
        : null;
    refBookingServiceItemId = json['refBookingServiceItemId'];
    bookingId = json['bookingId'];
    partnerId = json['partnerId'];

    partner = json['partner'] != null
        ? new PartnerUser.fromJson(json['partner'])
        : null;
    booking =
        json['booking'] != null ? new Bookings.fromJson(json['booking']) : null;
    bookingServiceItemId = json['bookingServiceItemId'];
    adminNote = json['adminNote'];
    partnerNote = json['partnerNote'];
    bookingServiceItem = json['bookingServiceItem'] != null
        ? new BookingServiceItems.fromJson(json['bookingServiceItem'])
        : null;
    partnerCalendarStatus = json['partnerCalendarStatus'] != null
        ? EnumToString.fromString(
            PartnerCalendarStatusTypeEnum.values, json['partnerCalendarStatus'])
        : null;
    team = json['teams'] == null
        ? null
        : List<Team>.from(json['teams'].map((e) => Team.fromJson(e)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['serviceDate'] = this.serviceDate;
    data['bookingId'] = this.bookingId;
    data['partnerId'] = this.partnerId;
    if (this.partner != null) {
      data['partner'] = this.partner!.toJson();
    }
    if (this.booking != null) {
      data['booking'] = this.booking!.toJson();
    }
    data['bookingServiceItemId'] = this.bookingServiceItemId;
    data['adminNote'] = this.adminNote;
    data['partnerNote'] = this.partnerNote;
    if (this.bookingServiceItem != null) {
      data['bookingServiceItem'] = this.bookingServiceItem!.toJson();
    }
    data['partnerCalendarStatus'] = this.partnerCalendarStatus;
    return data;
  }

  @override
  List<Object?> get props => [id, bookingId];
}

enum PartnerCalendarStatusTypeEnum {
  OPEN,
  CANCELED_PARTNER,
  CANCELED_CUSTOMER,
  RESCHEDULED_PARTNER,
  RESCHEDULED_CUSTOMER,
  ADMIN_REASSIGNED,
  DONE,
  REWORK_PENDING
}

class Team {
  Team({required this.uid, required this.name, this.members, this.id});

  String? id;
  String uid;
  String name;
  dynamic members;

  factory Team.fromJson(Map<String, dynamic> json) => Team(
      uid: json["uid"] ?? "",
      name: json["name"],
      members: json["members"],
      id: json['id']);

  Map<String, dynamic> toJson() =>
      {"uid": uid, "name": name, "members": members, "id": id};
}

class TotalAdditionalWork {
  final double? grandTotal;

  TotalAdditionalWork(this.grandTotal);

  factory TotalAdditionalWork.fromJson(Map<String, dynamic> json) {
    print("object $json");
    return TotalAdditionalWork(
        json['grandTotal'] == null ? 0 : json['grandTotal'].toDouble());
  }
}

class AdditionalWork {
  final TotalAdditionalWork? totalAdditionalWork;
  final String? modificationReason;
  final List<BookingAddon> bookingAddons;
  final int? additionalHoursUnits;
  final String bookingAdditionalWorkStatus;

  final bool isPaid;
  final Amount? additionalHoursAmount;
  final TotalAdditionalWorkAmount? totalAdditionalWorkAmount;

  AdditionalWork(
      {required this.bookingAddons,
      this.additionalHoursUnits,
      this.modificationReason,
      required this.bookingAdditionalWorkStatus,
      required this.isPaid,
      this.additionalHoursAmount,
      this.totalAdditionalWorkAmount,
      this.totalAdditionalWork});

  factory AdditionalWork.fromJson(Map<String, dynamic> json) {
    print("additonal json ${json}");
    return AdditionalWork(
      modificationReason: json['modificationReason'],
      totalAdditionalWork: json['totalAdditionalWorkAmount'] == null
          ? null
          : TotalAdditionalWork.fromJson(json['totalAdditionalWorkAmount']),
      bookingAddons: json["bookingAddons"] == null
          ? []
          : List<BookingAddon>.from(
              json["bookingAddons"]!.map((x) => BookingAddon.fromJson(x))),
      additionalHoursUnits: json["additionalHoursUnits"] ?? 0,
      bookingAdditionalWorkStatus: json["bookingAdditionalWorkStatus"],
      isPaid: json["isPaid"],
      additionalHoursAmount: json["additionalHoursAmount"] == null
          ? null
          : Amount.fromJson(json["additionalHoursAmount"]),
      totalAdditionalWorkAmount: json["totalAdditionalWorkAmount"] == null
          ? null
          : TotalAdditionalWorkAmount.fromJson(
              json["totalAdditionalWorkAmount"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "bookingAddons":
            List<dynamic>.from(bookingAddons.map((x) => x.toJson())),
        "additionalHoursUnits": additionalHoursUnits,
        "bookingAdditionalWorkStatus": bookingAdditionalWorkStatus,
        "isPaid": isPaid,
        "additionalHoursAmount": additionalHoursAmount?.toJson(),
        "totalAdditionalWorkAmount": totalAdditionalWorkAmount?.toJson(),
      };
}

class Amount {
  final double? grandTotal;

  Amount({
    this.grandTotal,
  });

  factory Amount.fromJson(Map<String, dynamic> json) => Amount(
        grandTotal: json["grandTotal"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "grandTotal": grandTotal,
      };
}

class TotalAdditionalWorkAmount {
  final int? grandTotal;

  TotalAdditionalWorkAmount({
    this.grandTotal,
  });

  factory TotalAdditionalWorkAmount.fromJson(Map<String, dynamic> json) =>
      TotalAdditionalWorkAmount(
        grandTotal: json["grandTotal"],
      );

  Map<String, dynamic> toJson() => {
        "grandTotal": grandTotal,
      };
}

class BookingAddon {
  final String name;
  final int units;
  final String unit;
  final Amount amount;

  BookingAddon({
    required this.name,
    required this.units,
    required this.unit,
    required this.amount,
  });

  factory BookingAddon.fromJson(Map<String, dynamic> json) => BookingAddon(
        name: json["name"],
        units: json["units"],
        unit: json['unit'],
        amount: Amount.fromJson(json["amount"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "units": units,
        "amount": amount.toJson(),
      };
}
