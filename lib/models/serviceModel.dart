import 'package:enum_to_string/enum_to_string.dart';

class AreaPincodes {
  String areaName;
  String pincode;

  AreaPincodes(this.areaName, this.pincode);
}

class ServiceCategory {
  String? id;
  String? code;
  String? name;
  Media? icon;
  List<Media>? images;
  List<AllServices>? services;

  ServiceCategory(
      {this.id, this.code, this.name, this.services, this.icon, this.images});

  ServiceCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    icon = json['icon'];
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images!.add(new Media.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = [];
      json['services'].forEach((v) {
        services!.add(new AllServices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['icon'] = this.icon;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['children'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

//--------GET SERVICES-------
class AllServices {
  String? id;
  String? name;
  String? code;
  List<Media>? medias;
  Media? icon;
  bool? isTeamService;
  List<ServiceRequirement>? requirements;
  List<BillingOptions>? billingOptions;
  List<ServiceSlot>? slots;
  String? description;
  List<ServiceInput>? inputs;
  bool? reworkGracePeriod;
  bool? enabled;
  List<ServiceAddon>? addons;

  bool? isSelected;

  AllServices(
      {this.id,
      this.name,
      this.medias,
      this.requirements,
      this.billingOptions,
      this.code,
      this.slots,
      this.description,
      this.icon,
      this.inputs,
      this.addons,
      this.enabled,
      this.reworkGracePeriod,
      this.isSelected,
      this.isTeamService});

  AllServices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isTeamService = json['isTeamService'];
    description = json['description'];
    icon = json['icon'] != null ? Media.fromJson(json['icon']) : null;
    if (json['medias'] != null) {
      medias = <Media>[];
      json['medias'].forEach((v) {
        medias!.add(Media.fromJson(v));
      });
    }
    if (json['requirements'] != null) {
      requirements = <ServiceRequirement>[];
      json['requirements'].forEach((v) {
        requirements!.add(new ServiceRequirement.fromJson(v));
      });
    }
    if (json['billingOptions'] != null) {
      billingOptions = <BillingOptions>[];
      json['billingOptions'].forEach((v) {
        billingOptions!.add(new BillingOptions.fromJson(v));
      });
    }
    code = json['code'];
    if (json['slots'] != null) {
      slots = <ServiceSlot>[];
      json['slots'].forEach((v) {
        slots!.add(new ServiceSlot.fromJson(v));
      });
    }
    if (json['inputs'] != null) {
      inputs = <ServiceInput>[];
      json['inputs'].forEach((v) {
        inputs!.add(new ServiceInput.fromJson(v));
      });
    }
    reworkGracePeriod = json['reworkGracePeriod'];
    enabled = json['enabled'];
    if (json['addons'] != null) {
      addons = <ServiceAddon>[];
      json['addons'].forEach((v) {
        addons!.add(new ServiceAddon.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.medias != null) {
      data['medias'] = this.medias!.map((v) => v).toList();
    }
    if (this.requirements != null) {
      data['requirements'] = this.requirements!.map((v) => v).toList();
    }
    if (this.billingOptions != null) {
      data['billingOptions'] =
          this.billingOptions!.map((v) => v.toJson()).toList();
    }
    data['code'] = this.code;
    if (this.slots != null) {
      data['slots'] = this.slots!.map((v) => v).toList();
    }
    data['description'] = this.description;
    if (this.inputs != null) {
      data['inputs'] = this.inputs!.map((v) => v).toList();
    }
    data['reworkGracePeriod'] = this.reworkGracePeriod;
    data['enabled'] = this.enabled;
    if (this.addons != null) {
      data['addons'] = this.addons!.map((v) => v).toList();
    }
    if (this.icon != null) {
      data['icon'] = this.icon!.toJson();
    }
    return data;
  }
}

class ServiceBillingOption {
  final int? additionalMinUnit;
  final int? additionalMaxUnit;

  ServiceBillingOption(this.additionalMinUnit, this.additionalMaxUnit);

  factory ServiceBillingOption.fromJson(Map<String, dynamic> json) {
    return ServiceBillingOption(
      json['additionalMinUnit'],
      json['additionalMaxUnit'],
    );
  }
}

class ServiceAddon {
  String? id;
  String? name;
  String? description;
  AddonTypeEnum? type;
  ServiceUnitEnum? unit;
  ItemPrice? unitPrice;
  int? minUnit;
  int? maxUnit;
  String? serviceId;

  ServiceAddon({
    this.description,
    this.id,
    this.maxUnit,
    this.minUnit,
    this.name,
    this.serviceId,
    this.type,
    this.unit,
    this.unitPrice,
  });

  ServiceAddon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    maxUnit = json['maxUnit'];
    minUnit = json['minUnit'];
    serviceId = json['serviceId'];
    unit = (json['type'] != null)
        ? EnumToString.fromString(ServiceUnitEnum.values, json['unit'])
        : null; //Enum
    unitPrice = json['unitPrice'] != null
        ? ItemPrice.fromJson(json['unitPrice'])
        : null;
    type = (json['type'] != null)
        ? EnumToString.fromString(AddonTypeEnum.values, json['type'])
        : null; //Enum
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['maxUnit'] = this.maxUnit;
    data['type'] = this.type;
    data['minUnit'] = this.minUnit;
    data['serviceId'] = this.serviceId;
    data['unit'] = this.unit;
    data['type'] = this.type;
    if (this.unitPrice != null) {
      data['unitPrice'] = this.unitPrice!.toJson();
    }
    return data;
  }
}

enum ServiceUnitEnum {
  HOUR,
  DAY,
  COUNT,
  LITER,
  KILOGRAM,
  METER,
  WEEK,
  MONTH,
}

enum AddonTypeEnum {
  PARTNER,
  CUSTOMER,
  ALL,
}

class ServiceInput {
  String? id;
  String? name;
  String? description;
  String? key;
  ServiceInputType? type;

  ServiceInput(this.id, this.name, this.description, this.key, this.type);

  ServiceInput.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    key = json['key'];
    type =
        EnumToString.fromString(ServiceInputType.values, json['type']); //Enum
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['key'] = this.key;
    data['type'] = this.type;
    return data;
  }
}

enum ServiceInputType { DATE, TEXT, LOCATION }

class ServiceSlot {
  String? id;
  String? name;
  DateTime? startTime;
  DateTime? endTime;

  ServiceSlot(this.id, this.name, this.startTime, this.endTime);

  ServiceSlot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    return data;
  }
}

class ServiceRequirement {
  String? id;
  String? title;
  String? descriptuion;
  bool? isSelected;

  ServiceRequirement(this.id, this.title, this.descriptuion, this.isSelected);

  ServiceRequirement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    descriptuion = json['descriptuion'];
    isSelected = json['isSelected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['descriptuion'] = this.descriptuion;
    data['isSelected'] = this.isSelected;
    return data;
  }
}

class Media {
  String? id;
  MediaTypeEnum? type;
  String? url;
  bool? name;
  bool? enabled;
  Media? thumbnail;

  Media(this.id, this.type, this.url, this.name, this.enabled, this.thumbnail);

  Media.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'] != null
        ? EnumToString.fromString(MediaTypeEnum.values, json['type'])
        : null;
    url = json['url'];
    name = json['name'];
    enabled = json['enabled'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['url'] = this.url;
    data['name'] = this.name;
    data['enabled'] = this.enabled;
    data['thumbnail'] = this.thumbnail;
    return data;
  }
}

enum MediaTypeEnum {
  IMAGE,
  VIDEO,
  EMBEDDED,
  GIF,
}

enum MediaType {
  IMAGE,
  VIDEO,
  EMBEDDED,
  GIF,
}

class BillingOptions {
  String? id;
  String? code;
  String? name;
  String? description;
  bool? recurring;
  String? recurringPeriod;
  bool? autoAssignPartner;
  String? unit;
  int? minUnit;
  int? maxUnit;
  ItemPrice? unitPrice;
  ItemPrice? additionalUnitPrice;
  int additionalMinUnit = 0;

  BillingOptions(
      {this.id,
      this.code,
      this.name,
      this.description,
      this.recurring,
      this.recurringPeriod,
      this.autoAssignPartner,
      this.unit,
      this.minUnit,
      this.maxUnit,
      this.additionalUnitPrice,
      this.unitPrice,
      required this.additionalMinUnit});

  BillingOptions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    additionalMinUnit = json['additionalMinUnit'] ?? 0;
    description = json['description'];
    recurring = json['recurring'];
    recurringPeriod = json['recurringPeriod'];
    autoAssignPartner = json['autoAssignPartner'];
    unit = json['unit'];
    minUnit = json['minUnit'];
    maxUnit = json['maxUnit'];
    unitPrice = json['unitPrice'] != null
        ? ItemPrice.fromJson(json['unitPrice'])
        : null;
    additionalUnitPrice = json['additionalUnitPrice'] != null
        ? ItemPrice.fromJson(json['additionalUnitPrice'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['description'] = this.description;
    data['recurring'] = this.recurring;
    data['recurringPeriod'] = this.recurringPeriod;
    data['autoAssignPartner'] = this.autoAssignPartner;
    data['unit'] = this.unit;
    data['minUnit'] = this.minUnit;
    data['maxUnit'] = this.maxUnit;
    if (this.unitPrice != null) {
      data['unitPrice'] = this.unitPrice!.toJson();
    }
    if (this.additionalUnitPrice != null) {
      data['additionalUnitPrice'] = this.additionalUnitPrice!.toJson();
    }
    return data;
  }
}

enum ServiceUnit {
  HOUR,
  DAY,
  COUNT,
  WEEK,
  MONTH,
}

enum RecurringPeriod {
  DAILY,
  WEEKLY,
  MONTHLY,
  TWICE_A_WEEK,
}

class ItemPrice {
  double? partnerPrice;
  double? commission;
  double? commissionTax;
  double? partnerTax;
  double? total;

  ItemPrice({
    this.commission,
    this.commissionTax,
    this.partnerPrice,
    this.partnerTax,
    this.total,
  });

  ItemPrice.fromJson(Map<String, dynamic> json) {
    partnerPrice = json['partnerPrice'] != null
        ? double.parse(json['partnerPrice'].toString())
        : null;
    commission = json['commission'] != null
        ? double.parse(json['commission'].toString())
        : null;
    commissionTax = json['commissionTax'] != null
        ? double.parse(json['commissionTax'].toString())
        : null;
    partnerTax = json['partnerTax'] != null
        ? double.parse(json['partnerTax'].toString())
        : null;
    total =
        json['total'] != null ? double.parse(json['total'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['partnerPrice'] = this.partnerPrice;
    data['partnerTax'] = this.partnerTax;
    data['commission'] = this.commission;
    data['commissionTax'] = this.commissionTax;
    data['total'] = this.total;
    return data;
  }
}
