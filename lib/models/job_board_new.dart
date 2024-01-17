class JobBoardNew {
  JobBoardNew({
    required this.data,
  });

  Data data;

  factory JobBoardNew.fromJson(Map<String, dynamic> json) => JobBoardNew(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.getJobBoard,
  });

  GetJobBoard getJobBoard;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        getJobBoard: GetJobBoard.fromJson(json["getJobBoard"]),
      );

  Map<String, dynamic> toJson() => {
        "getJobBoard": getJobBoard.toJson(),
      };
}

class GetJobBoard {
  GetJobBoard({
    required this.data,
  });

  List<Datum> data;

  factory GetJobBoard.fromJson(Map<String, dynamic> json) => GetJobBoard(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.jobDate,
    required this.addedDate,
    required this.jobAreaId,
    required this.jobArea,
    required this.jobService,
    required this.jobServiceId,
    required this.autoAssign,
    required this.bookingId,
    required this.bookingServiceId,
    required this.bookingService,
    required this.bookingServiceItemId,
    required this.jobPriority,
  });

  String id;
  DateTime jobDate;
  DateTime addedDate;
  String jobAreaId;
  JobArea jobArea;
  JobService jobService;
  String jobServiceId;
  bool autoAssign;
  String bookingId;
  String bookingServiceId;
  BookingService bookingService;
  String bookingServiceItemId;
  String jobPriority;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        jobDate: DateTime.parse(json["jobDate"]),
        addedDate: DateTime.parse(json["addedDate"]),
        jobAreaId: json["jobAreaId"],
        jobArea: JobArea.fromJson(json["jobArea"]),
        jobService: JobService.fromJson(json["jobService"]),
        jobServiceId: json["jobServiceId"],
        autoAssign: json["autoAssign"],
        bookingId: json["bookingId"],
        bookingServiceId: json["bookingServiceId"],
        bookingService: BookingService.fromJson(json["bookingService"]),
        bookingServiceItemId: json["bookingServiceItemId"],
        jobPriority: json["jobPriority"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "jobDate": jobDate.toIso8601String(),
        "addedDate": addedDate.toIso8601String(),
        "jobAreaId": jobAreaId,
        "jobArea": jobArea.toJson(),
        "jobService": jobService.toJson(),
        "jobServiceId": jobServiceId,
        "autoAssign": autoAssign,
        "bookingId": bookingId,
        "bookingServiceId": bookingServiceId,
        "bookingService": bookingService.toJson(),
        "bookingServiceItemId": bookingServiceItemId,
        "jobPriority": jobPriority,
      };
}

class BookingService {
  BookingService({
    required this.unit,
    required this.serviceBillingOptionId,
    this.serviceBillingOption,
    required this.qty,
    required this.service,
  });

  String unit;
  String serviceBillingOptionId;
  dynamic serviceBillingOption;
  int qty;
  Service service;

  factory BookingService.fromJson(Map<String, dynamic> json) => BookingService(
        unit: json["unit"],
        serviceBillingOptionId: json["serviceBillingOptionId"],
        serviceBillingOption: json["serviceBillingOption"],
        qty: json["qty"],
        service: Service.fromJson(json["service"]),
      );

  Map<String, dynamic> toJson() => {
        "unit": unit,
        "serviceBillingOptionId": serviceBillingOptionId,
        "serviceBillingOption": serviceBillingOption,
        "qty": qty,
        "service": service.toJson(),
      };
}

class Service {
  Service({
    required this.icon,
  });

  Icon icon;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        icon: Icon.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "icon": icon.toJson(),
      };
}

class Icon {
  Icon({
    required this.url,
  });

  String url;

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}

class JobArea {
  JobArea({
    required this.name,
    required this.id,
  });

  String name;
  String id;

  factory JobArea.fromJson(Map<String, dynamic> json) => JobArea(
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}

class JobService {
  JobService({
    required this.name,
    required this.icon,
  });

  String name;
  Icon icon;

  factory JobService.fromJson(Map<String, dynamic> json) => JobService(
        name: json["name"],
        icon: Icon.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "icon": icon.toJson(),
      };
}
