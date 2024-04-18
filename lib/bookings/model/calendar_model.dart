import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';

import '../../models/bookingsModel.dart';

class PartnerCalendarItemNew extends Equatable {
  final String id;
  final DateTime serviceDate;
  final String partnerCalendarStatus;
  final Booking booking;
  final BookingServiceItem bookingServiceItem;

  PartnerCalendarItemNew({
    required this.id,
    required this.serviceDate,
    required this.partnerCalendarStatus,
    required this.booking,
    required this.bookingServiceItem,
  });

  factory PartnerCalendarItemNew.fromJson(Map<String, dynamic> json) {
    return PartnerCalendarItemNew(
      id: json['id'],
      serviceDate: DateTime.parse(json['serviceDate']),
      partnerCalendarStatus: json['partnerCalendarStatus'],
      booking: Booking.fromJson(json['booking']),
      bookingServiceItem:
          BookingServiceItem.fromJson(json['bookingServiceItem']),
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class Booking {
  final String userBookingNumber;
  final String bookingStatus;
  final BookingService bookingService;
  final BookingAddress bookingAddress;
  List<BookingPayment>? bookingPayments;

  Booking(
      {required this.userBookingNumber,
      required this.bookingStatus,
      required this.bookingService,
      required this.bookingAddress,
      this.bookingPayments});

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      userBookingNumber: json['userBookingNumber'],
      bookingStatus: json['bookingStatus'],
      bookingPayments: json['bookingPayments'] == null
          ? null
          : List<BookingPayment>.from(
              json['bookingPayments'].map((x) => BookingPayment.fromJson(x))),
      bookingService: BookingService.fromJson(json['bookingService']),
      bookingAddress: BookingAddress.fromJson(json['bookingAddress']),
    );
  }
}

class BookingService {
  final Service service;
  final String serviceBillingOptionId;

  BookingService({required this.service, required this.serviceBillingOptionId});

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
        service: Service.fromJson(json['service']),
        serviceBillingOptionId: json['serviceBillingOptionId']);
  }
}

class Service {
  final String name;
  final String icon;
  final String description;
  final String title;
  final List<BillingOption> billingOptions;

  Service({
    required this.name,
    required this.icon,
    required this.description,
    required this.title,
    required this.billingOptions,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'],
      icon: json['icon']['url'],
      description: '',
      title: '',
      billingOptions: (json['billingOptions'] as List)
          .map((option) => BillingOption.fromJson(option))
          .toList(),
    );
  }
}

class BillingOption {
  final String name;
  final String id;

  BillingOption({
    required this.name,
    required this.id,
  });

  factory BillingOption.fromJson(Map<String, dynamic> json) {
    return BillingOption(
      name: json['name'],
      id: json['id'],
    );
  }
}

class BookingAddress {
  final Area area;

  BookingAddress({required this.area});

  factory BookingAddress.fromJson(Map<String, dynamic> json) {
    return BookingAddress(
      area: Area.fromJson(json['area']),
    );
  }
}

class Area {
  final String name;

  Area({required this.name});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      name: json['name'],
    );
  }
}

class BookingServiceItem {
  final BookingServiceItemTypeEnum? bookingServiceItemType;
  final String bookingServiceItemStatus;
  final DateTime? endDateTime;
  final DateTime? startDateTime;
  final ChangedPrice? changedPrice;

  BookingServiceItem(
      {required this.bookingServiceItemType,
      required this.bookingServiceItemStatus,
      required this.endDateTime,
      required this.startDateTime,
      required this.changedPrice});

  factory BookingServiceItem.fromJson(Map<String, dynamic> json) {
    return BookingServiceItem(
        bookingServiceItemType: EnumToString.fromString(
            BookingServiceItemTypeEnum.values, json['bookingServiceItemType']),
        bookingServiceItemStatus: json['bookingServiceItemStatus'],
        endDateTime: json['actualEndDateTime'] == null
            ? null
            : DateTime.parse(json['actualEndDateTime']),
        startDateTime: DateTime.parse(json['startDateTime']),
        changedPrice: json['chargedPrice'] == null
            ? null
            : ChangedPrice.fromJson(json['chargedPrice']));
  }
}

class ChangedPrice {
  final double grandTotal;

  ChangedPrice(this.grandTotal);

  factory ChangedPrice.fromJson(Map<String, dynamic> json) {
    return ChangedPrice(
        json['grandTotal'] == null ? 0 : json['grandTotal'].toDouble());
  }
}
