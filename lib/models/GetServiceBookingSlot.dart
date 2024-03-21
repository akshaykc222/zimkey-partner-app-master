class GetServiceBookingSlot {
  final DateTime start;
  final DateTime end;
  final bool available;

  GetServiceBookingSlot({
    required this.start,
    required this.end,
    required this.available,
  });

  factory GetServiceBookingSlot.fromJson(Map<String, dynamic> json) =>
      GetServiceBookingSlot(
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        available: json["available"],
      );

  Map<String, dynamic> toJson() => {
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
        "available": available,
      };
}
