import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:instant/instant.dart' as ins;
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/jobModel.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';

class RescheduleJobpage extends StatefulWidget {
  final String? bookingItemId;
  final PartnerCalendarItem? jobitem;
  RescheduleJobpage({
    Key? key,
    this.bookingItemId,
    this.jobitem,
  }) : super(key: key);

  @override
  _RescheduleJobpageState createState() => _RescheduleJobpageState();
}

class _RescheduleJobpageState extends State<RescheduleJobpage> {
  bool showMonthList = false;
  String monthFilter = months[DateTime.now().month - 1];
  var tempMonth = [];
  DateTime? selectedDate;
  DateTime? fullBookingDate;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  List<DateTime?>? days;
  String selectedTimeSlot = "";
  bool isLoading = false;
  List<String> timeHours = [];
  final FbState fbState = Get.find();
  TextEditingController _commentMsg = TextEditingController();
  final FocusNode _commentMsgNode = FocusNode();
  double bottom = 0;
  bool addheight = false;

  String? hr;
  String? endHr;
  String? endMin;
  String? min;

  @override
  void initState() {
    print("start date${widget.jobitem?.bookingServiceItem?.startDateTime}");

    ///---------
    hr = DateTime.parse('${widget.jobitem!.serviceDate}').hour.toString();
    if (hr!.length < 2) hr = '0$hr';
    min = DateTime.parse('${widget.jobitem!.serviceDate}').minute.toString();
    if (min!.length < 2) min = '0$min';
    if (min == '30') {
      endMin = '00';
      endHr = '${DateTime.parse('${widget.jobitem!.serviceDate}').hour + 1}';
    } else {
      endMin = '30';
      endHr = hr;
    }
    if (endHr.toString().length < 2) endHr = '0$endHr';
    //////////////
    calculateDays();
    //default selection
    int monthNo = 0;
    for (int i = 0; i < months.length; i++) {
      if (months[i] == monthFilter) {
        tempMonth = months.sublist(i, months.length);
        monthNo = i;
        print('tempMonth length --- ${tempMonth.length}');
      }
    }
    // if dec, show next yeras 2 months
    if (monthNo >= 11) {
      tempMonth.add(months[0]);
      tempMonth.add(months[1]);
    }

    //-----
    _commentMsgNode.addListener(() {
      bool hasFocus = _commentMsgNode.hasFocus;
      if (hasFocus)
        setState(() {
          addheight = true;
        });
      else
        setState(() {
          addheight = false;
        });
    });

    super.initState();
  }

  //Get  booking time slots
  Future<QueryResult?> getBookingTimeSlots(
      String? billingOption, String? partnerId, bool nextday, Widget nextPage,
      {String? bookingServiceItemId, bool? isReschedule}) async {
    DateTime? thisDate;
    setState(() {
      thisDate = fullBookingDate;
      if (nextday) thisDate = thisDate!.add(new Duration(days: 1));
      selectedDate = thisDate;
    });
    final MutationOptions _options = MutationOptions(
      document: gql(getTimeSlots),
      variables: <String, dynamic>{
        "date": thisDate.toString(),
        "billingOptionId": billingOption,
        "partnerId": partnerId,
        "isReschedule": isReschedule,
        "bookingServiceItemId": bookingServiceItemId
      },
    );
    setState(() {
      isLoading = true;
    });
    final QueryResult? slotsResult =
        await globalGQLClient.value.mutate(_options);
    setState(() {
      isLoading = false;
    });
    if (slotsResult != null && slotsResult.hasException) {
      showCustomDialog(
          'Oops!', slotsResult.exception.toString(), context, null);
      print(slotsResult.exception.toString());
    }
    if (slotsResult != null &&
        slotsResult.data != null &&
        slotsResult.data!['getServiceBookingSlots'] != null) {
      timeHours.clear();
      for (Map slot in slotsResult.data!['getServiceBookingSlots']) {
        String time;
        String hr;
        String min;
        if (slot['available'] != null && slot['available']) {
          DateTime startTime = DateTime.parse(slot['start']);
          startTime = ins.dateTimeToZone(zone: "IST", datetime: startTime);
          // startTime = startTime.toLocal();
          DateTime endTime = DateTime.parse(slot['end']);
          endTime = ins.dateTimeToZone(zone: "IST", datetime: endTime);
          //current time------
          DateTime nowTime = DateTime.now();
          nowTime = ins.dateTimeToZone(zone: "IST", datetime: nowTime);
          //if start time is after 3 hrs  from current time-------
          if (startTime.difference(nowTime).inHours >= 3) {
            hr = '${DateTime.parse(slot['start']).toLocal().hour}';
            if (hr.length < 2) hr = '0$hr';
            min = '${DateTime.parse(slot['start']).toLocal().minute}';
            if (min.length < 2) min = '0$min';
            time = '$hr.$min - ';
            hr = '${DateTime.parse(slot['end']).toLocal().hour}';
            if (hr.length < 2) hr = '0$hr';
            min = '${DateTime.parse(slot['end']).toLocal().minute}';
            if (min.length < 2) min = '0$min';
            time = time + '$hr.$min';
            print(
                '${DateTime.parse(slot['start']).day - DateTime.parse(slot['start']).month} time slots - $time');
            timeHours.add(time);
          }
        }
      }
      if (timeHours.isEmpty)
        confirmationTimeSlotsMsg(
          'Oops!',
          'All boooking time slots for the date ${thisDate!.day}-${thisDate!.month}-${thisDate!.year} is full. Would you like to check slots for upcoming days?',
          widget.jobitem,
          nextPage,
        );
    }
    return slotsResult;
  }

  Future<Null> calculateDays() async {
    var dateMap;
    int month = 0;
    if (monthFilter == months[DateTime.now().month - 1]) {
      //if current month as selected monthfilter
      var lastDayDateTime = (DateTime.now().month < 12)
          ? new DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
          : new DateTime(DateTime.now().year + 1, 1, 0);
      dateMap = {
        "start": DateTime.now(),
        "end": lastDayDateTime,
      };
    } else {
      //not current month
      for (int i = 0; i < months.length; i++) {
        if (monthFilter.toLowerCase() == months[i].toLowerCase()) month = i + 1;
      }
      var lastDayDateTime = (month < 12)
          ? new DateTime(DateTime.now().year, month + 1, 0)
          : new DateTime(DateTime.now().year + 1, 1, 0);
      if (month < DateTime.now().month)
        lastDayDateTime = DateTime(DateTime.now().year + 1, month + 1, 0);
      dateMap = {
        "start": DateTime(
          month < DateTime.now().month
              ? DateTime.now().year + 1
              : DateTime.now().year,
          month,
        ),
        "end": lastDayDateTime,
      };
    }
    setState(() {
      days = calculateDaysInterval(dateMap);
      fullBookingDate = days!.first;
    });
  }

  List<DateTime?> calculateDaysInterval(dynamic dateMap) {
    var startDate;
    // check if current day time is after 3pm
    if (dateMap["start"].day == DateTime.now().day &&
        dateMap["start"].month == DateTime.now().month &&
        dateMap["start"].year == DateTime.now().year &&
        DateTime.now().hour >= 15) {
      startDate = dateMap["start"];
      startDate = DateTime(startDate.year, startDate.month, startDate.day + 1);
      print('${DateTime.now().hour} ---post 3pm');
    } else {
      startDate = dateMap["start"];
    }
    var endDate = dateMap["end"];
    // print(startDate.toString());
    // print(endDate.toString());

    List<DateTime?> days = [];
    //if current month as selected monthfilter
    if (monthFilter == months[DateTime.now().month - 1]) {
      //If before 3pm for current day------
      if (DateTime.now().hour < 15)
        for (int i = 0; i <= endDate.difference(startDate).inDays + 1; i++)
          days.add(startDate.add(Duration(days: i)));
      else
        //If after 3pm for current day, already remove frst day
        for (int i = 0; i <= endDate.difference(startDate).inDays; i++)
          days.add(startDate.add(Duration(days: i)));
    } else {
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++)
        days.add(startDate.add(Duration(days: i)));
    }
    setState(() {
      days = List.from(days);
    });
    return days;
  }

//Reschdeule Job
  Future<QueryResult> rescheduleJobMutation(DateTime? scheduleTime,
      String? bookingServiceItemId, String modificationReason) async {
    final MutationOptions _options = MutationOptions(
      document: gql(rescheduleJob),
      variables: <String, dynamic>{
        "scheduleTime": scheduleTime.toString(),
        "bookingServiceItemId": bookingServiceItemId,
        "modificationReason": modificationReason,
      },
    );
    setState(() {
      isLoading = true;
    });
    final QueryResult rescheduleJobResult =
        await globalGQLClient.value.mutate(_options);
    setState(() {
      isLoading = false;
    });
    print(rescheduleJobResult);
    if (rescheduleJobResult.hasException) {
      showCustomDialog(
          'Oops',
          '${rescheduleJobResult.exception!.graphqlErrors.first.message}',
          context,
          null);
      print(rescheduleJobResult.exception.toString());
    }
    if (rescheduleJobResult.data != null &&
        rescheduleJobResult.data!['rescheduleJob'] != null) {
      showCustomDialog(
          'Yay!',
          'Your request for job reschedule for the service  - ${widget.jobitem!.bookingServiceItem!.bookingService!.service!.name} for the new date - ${DateFormat("dd-MM-yyyy hh:mm a").format(scheduleTime!)} has been submitted successfully.\nYour request will be approved by the customer shortly.',
          context,
          Dashboard(
            index: 2,
          ));
      print('Reschedule job success!!!!!');
    }
    return rescheduleJobResult;
  }

  @override
  Widget build(BuildContext context) {
    bottom = MediaQuery.of(context).viewInsets.bottom;
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: zimkeyOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: zimkeyWhite,
                size: 18,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            title: Text(
              'Reschedule Job',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: zimkeyWhite,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              bottom: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: zimkeyBodyOrange,
                                  borderRadius: BorderRadius.circular(5)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Booking Service ',
                                          style: TextStyle(
                                            color:
                                                zimkeyDarkGrey.withOpacity(0.7),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${ReCase(widget.jobitem!.booking!.bookingService!.service!.name!).titleCase}',
                                        style: TextStyle(
                                          color: zimkeyDarkGrey.withOpacity(1),
                                          fontSize: 13,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Date & Time ',
                                          style: TextStyle(
                                            color:
                                                zimkeyDarkGrey.withOpacity(0.7),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${DateFormat("dd-MM-yyyy").format(widget.jobitem!.serviceDate!)}',
                                            style: TextStyle(
                                              color:
                                                  zimkeyDarkGrey.withOpacity(1),
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            '| ${widget.jobitem?.bookingServiceItem?.startDateTime != null ? DateFormat('HH:mm ').format(widget.jobitem!.bookingServiceItem!.startDateTime!) : ""} - ${widget.jobitem?.bookingServiceItem?.endDateTime != null ? DateFormat("HH:mm").format(widget.jobitem!.bookingServiceItem!.endDateTime!) : ""}',
                                            style: TextStyle(
                                              color:
                                                  zimkeyDarkGrey.withOpacity(1),
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Text(
                                'Select a booking date',
                                style: TextStyle(
                                  color: zimkeyDarkGrey.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Stack(
                              children: [
                                // if (showMonthList)
                                Container(
                                  height: 45,
                                  margin: EdgeInsets.only(left: 20),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (int i = 0; i < tempMonth.length; i++)
                                        InkWell(
                                          onTap: () async {
                                            setState(() {
                                              monthFilter = tempMonth[i];
                                              showMonthList = false;
                                              selectedDate = null;
                                              fullBookingDate = selectedDate;
                                            });
                                            await calculateDays();
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            constraints: BoxConstraints(
                                              minWidth: 70,
                                              maxWidth: 100,
                                            ),
                                            margin: EdgeInsets.only(
                                                right: 5, top: 3, bottom: 3),
                                            width: 75,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color:
                                                    monthFilter == tempMonth[i]
                                                        ? zimkeyOrange
                                                        : zimkeyLightGrey,
                                              ),
                                              color: monthFilter == tempMonth[i]
                                                  ? zimkeyBodyOrange
                                                  : zimkeyLightGrey,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0, vertical: 10),
                                            child: Text(
                                              '${tempMonth[i].toString().substring(0, 3)}',
                                              style: TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                              ),
                              height: 49,
                              child: days?.isEmpty == true
                                  ? Center(
                                      child: Text("No timeslot available"),
                                    )
                                  : ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        if (days != null)
                                          for (int i = 0; i < days!.length; i++)
                                            datePicker(i),
                                      ],
                                    ),
                            ),
                            if (timeHours.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      'Select a booking time slot',
                                      style: TextStyle(
                                        color: zimkeyDarkGrey.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    // color: zimkeyGreen,
                                    padding: const EdgeInsets.only(
                                      left: 15.0,
                                    ),
                                    child: timeHours.isNotEmpty &&
                                            timeHours.length > 3
                                        ? Column(
                                            children: [
                                              Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: ListView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  children: [
                                                    for (int i = 0;
                                                        i < timeHours.length;
                                                        i += 2)
                                                      bookingTimeSlot(i)
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: ListView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  children: [
                                                    for (int i = 1;
                                                        i < timeHours.length;
                                                        i += 2)
                                                      bookingTimeSlot(i),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i < timeHours.length;
                                                  i++)
                                                bookingTimeSlot(i),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Some additional comments',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: bottom),
                        child: Container(
                          decoration: BoxDecoration(
                            color: zimkeyLightGrey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _commentMsg,
                            focusNode: _commentMsgNode,
                            textCapitalization: TextCapitalization.sentences,
                            scrollPadding: EdgeInsets.only(bottom: bottom),
                            maxLength: 300,
                            maxLines: 5,
                            style: TextStyle(
                              color: zimkeyDarkGrey,
                              // fontSize: 14,
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              hintText: 'Enter your comments here',
                              hintStyle: TextStyle(
                                color: zimkeyDarkGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                  // SizedBox(
                  //   height: 40,
                  // ),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        if (fullBookingDate != null)
                          await rescheduleJobMutation(fullBookingDate,
                              widget.bookingItemId, _commentMsg.text);
                        else
                          showCustomDialog(
                              'Oops!',
                              "Kindly select a new date and time to reschedule",
                              context,
                              null);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width - 200,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: zimkeyOrange,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: zimkeyLightGrey.withOpacity(0.1),
                              blurRadius: 5.0, // soften the shadow
                              spreadRadius: 2.0, //extend the shadow
                              offset: Offset(
                                1.0, // Move to right 10  horizontally
                                1.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        child: Text(
                          'Reshedule',
                          style: TextStyle(
                            fontSize: 14,
                            color: zimkeyWhite,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: addheight
                        ? MediaQuery.of(context).size.height / 4.5
                        : 40,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Center(
            child: sharedLoadingIndicator(),
          ),
      ],
    );
  }

  Widget bookingTimeSlot(int index) {
    return InkWell(
      onTap: () {
        if (selectedDate != null) {
          setState(() {
            selectedTimeSlot = timeHours[index].toUpperCase();
          });
          String thisday;
          String selectedtime = selectedTimeSlot.split(' - ').first;
          String timeHr = selectedtime.split('.').first;
          String timeMin = selectedtime.split('.').last;
          String thisMon = selectedDate!.month.toString();
          if (thisMon.length < 2) thisMon = '0$thisMon';
          thisday = '${selectedDate!.day}';
          if (timeHr.length < 2) timeHr = '0$timeHr';
          thisday = '${selectedDate!.day}';
          if (timeMin.length < 2) timeMin = '0$timeMin';
          thisday = '${selectedDate!.day}';
          if (selectedDate!.day.toString().length < 2)
            thisday = '0${selectedDate!.day}';
          fullBookingDate =
              // DateTime.parse("2021-10-19 14:37:45");
              DateTime.parse(
                  '${selectedDate!.year}-$thisMon-$thisday $timeHr:$timeMin:00');
          print('selected slot ---- $fullBookingDate');
        } else {
          showCustomDialog(
            'Oops!',
            'Kindly select a new reschedule date first.',
            context,
            null,
          );
        }
      },
      child: Container(
        width: (MediaQuery.of(context).size.width / 4.0),
        constraints: BoxConstraints(
          maxWidth: (MediaQuery.of(context).size.width / 4.0),
          minWidth: 70,
        ),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
              color: selectedTimeSlot == timeHours[index].toUpperCase()
                  ? zimkeyOrange
                  : zimkeyLightGrey),
          color: selectedTimeSlot == timeHours[index].toUpperCase()
              ? zimkeyBodyOrange
              : zimkeyLightGrey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          timeHours[index].toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: zimkeyDarkGrey,
          ),
        ),
      ),
    );
  }

  Widget datePicker(int i) {
    return InkWell(
      onTap: () async {
        setState(() {
          selectedDate = days![i];
          fullBookingDate = selectedDate;
        });
        if (selectedTimeSlot != null && selectedTimeSlot.isNotEmpty) {
          String thisday;
          String selectedtime = selectedTimeSlot.split(' - ').first;
          String timeHr = selectedtime.split('.').first;
          if (timeHr.length < 2) timeHr = '0$timeHr';
          thisday = '${selectedDate!.day}';
          if (selectedDate!.day.toString().length < 2)
            thisday = '0${selectedDate!.day}';
          // fullBookingDate =
          //     // DateTime.parse("2021-10-19 14:37:45");
          //     DateTime.parse(
          //         '${selectedDate.year}-${selectedDate.month}-$thisday $timeHr:${selectedtime.split('.').last}:00');
          print('selected slot ---- $fullBookingDate');
        }
        await getBookingTimeSlots(
            widget.jobitem!.bookingServiceItem!.bookingService!
                .serviceBillingOptionId,
            fbState.partnerUser.value!.id,
            false,
            Dashboard(),
            isReschedule: true,
            bookingServiceItemId: widget.jobitem!.bookingServiceItemId);
      },
      child: Container(
        width: 50,
        constraints: BoxConstraints(
          maxWidth: 80,
          minWidth: 40,
        ),
        margin: EdgeInsets.only(right: 7),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedDate != null && selectedDate == days![i]
              ? zimkeyBodyOrange
              : zimkeyLightGrey,
          border: Border.all(
            color: selectedDate != null && selectedDate == days![i]
                ? zimkeyOrange
                : zimkeyLightGrey,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${formatDate(days![i]!, [d]).toUpperCase()}',
              style: TextStyle(
                color: zimkeyDarkGrey,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              '${formatDate(days![i]!, [D]).substring(0, 3).toUpperCase()}',
              style: TextStyle(
                color: zimkeyDarkGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  confirmationTimeSlotsMsg(
      String title, String msg, PartnerCalendarItem? jobItem, Widget nextPage) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                contentTextStyle: TextStyle(
                  color: zimkeyBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
                titlePadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                title: Container(
                  padding: EdgeInsets.only(left: 20, right: 15, top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$title',
                          style: TextStyle(
                            color: zimkeyBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: zimkeyDarkGrey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.clear,
                            color: zimkeyDarkGrey,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                content: Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$msg',
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: zimkeyOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  new InkWell(
                    onTap: () async {
                      // setState(() {
                      //   fullBookingDate =
                      //       fullBookingDate.add(new Duration(days: 1));
                      //   selectedDate = fullBookingDate;
                      // });
                      Get.back();
                      await getBookingTimeSlots(
                          jobItem!.bookingServiceItem!.bookingService!
                              .serviceBillingOptionId,
                          "",
                          true,
                          nextPage,
                          isReschedule: true,
                          bookingServiceItemId: jobItem.bookingServiceItemId);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: zimkeyOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 250),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {} as Widget Function(
            BuildContext, Animation<double>, Animation<double>));
  }
}
