import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:instant/instant.dart' as ins;

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/jobModel.dart';
import '../models/serviceModel.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';

class AddAdditionalwork extends StatefulWidget {
  final String? bookingItemId;
  final PartnerCalendarItem? jobtem;
  final ServiceBillingOption serviceBillingOption;

  AddAdditionalwork({
    Key? key,
    this.bookingItemId,
    this.jobtem,
    required this.serviceBillingOption,
  }) : super(key: key);

  @override
  _AddAdditionalworkState createState() => _AddAdditionalworkState();
}

class _AddAdditionalworkState extends State<AddAdditionalwork> {
  bool isLoading = false;
  List<Map<String, dynamic>> selectedAddons = [];
  DateTime? scheduleTime;
  List<String> timeHours = [];

  String monthFilter = months[DateTime.now().month - 1];
  var tempMonth = [];
  DateTime? selectedDate;
  DateTime? fullBookingDate;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  List<DateTime?>? days;
  String selectedTimeSlot = "";
  bool showMonthList = false;
  int? serviceUnit;
  int minServiceUnit = 0;
  int maxServiceUnit = 10;
  final FbState fbState = Get.find();

  TextEditingController _commentMsg = TextEditingController();
  final FocusNode _commentMsgNode = FocusNode();
  double bottom = 0;
  bool addheight = false;

  @override
  void initState() {
    minServiceUnit = widget.serviceBillingOption.additionalMinUnit ?? 1;
    print("minService unit $minServiceUnit");
    maxServiceUnit = widget.serviceBillingOption.additionalMaxUnit ?? 10;
    serviceUnit = 0;

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
    calculateDays();
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

  bool checked = false;

  //Get  booking time slots
  Future<QueryResult> getBookingTimeSlots(String? billingOption,
      String? partnerId, bool nextday, Widget refreshPage) async {
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
        "partnerId": partnerId
      },
    );
    setState(() {
      isLoading = true;
    });
    final QueryResult slotsResult =
        await globalGQLClient.value.mutate(_options);
    setState(() {
      isLoading = false;
    });
    print(slotsResult);
    if (slotsResult.hasException) {
      showCustomDialog(
          'Oops!', slotsResult.exception.toString(), context, null);
      print(slotsResult.exception.toString());
    }
    if (slotsResult.data != null &&
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
            print('time slots - $time');
            timeHours.add(time);
          }
        }
      }
      if (timeHours.isEmpty)
        confirmationMsgDialog(
          'Oops!',
          'All boooking time slots for the date ${thisDate!.day.toString().padLeft(2, '0')}-${thisDate!.month.toString().padLeft(2, '0')}-${thisDate!.year} is full. Would you like to check slots for upcoming days?',
          widget.jobtem,
          refreshPage,
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
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
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
  Future<QueryResult> addAddWorkMutation(String? bookingServiceItemId) async {
    final MutationOptions _options = MutationOptions(
      document: gql(addAdditionalWork),
      variables: <String, dynamic>{
        "addons": selectedAddons.isEmpty ? null : selectedAddons,
        "startDateTime":
            fullBookingDate == null ? null : fullBookingDate.toString(),
        "endDateTime": fullBookingDate == null
            ? null
            : fullBookingDate?.add(Duration(hours: 1)).toString(),
        "units": serviceUnit,
        "bookingServiceItemId": bookingServiceItemId,
        "modificationReason":
            _commentMsg.text.isEmpty ? null : _commentMsg.text,
      },
    );
    print({
      "addons": selectedAddons,
      "startDateTime": fullBookingDate.toString(),
      "units": serviceUnit,
      "bookingServiceItemId": bookingServiceItemId,
      "modificationReason": _commentMsg.text,
    });
    setState(() {
      isLoading = true;
    });
    final QueryResult addAddlWorkResult =
        await globalGQLClient.value.mutate(_options);
    setState(() {
      isLoading = false;
    });
    print(addAddlWorkResult);
    if (addAddlWorkResult.hasException) {
      if (addAddlWorkResult.exception!.linkException != null)
        showCustomDialog(
            'Oops!',
            '${addAddlWorkResult.exception!.linkException!.originalException}',
            context,
            null);
      else if (addAddlWorkResult.exception!.graphqlErrors.isNotEmpty)
        showCustomDialog(
            'Oops!',
            '${addAddlWorkResult.exception!.graphqlErrors.first.message}',
            context,
            null);
      else
        showCustomDialog(
            'Oops!',
            'Some error occured. Please try again after some time.',
            context,
            null);
      print(addAddlWorkResult.exception.toString());
    }

    if (addAddlWorkResult.data != null &&
        addAddlWorkResult.data!['addAdditionalWork'] != null) {
      showCustomDialog(
          'Done',
          'Additional work has been added successfully',
          context,
          Dashboard(
            index: 2,
            tabIndex: 0,
          ));
      print('Add Additional work success!!!!!');
    }
    return addAddlWorkResult;
  }

  @override
  Widget build(BuildContext context) {
    bottom = MediaQuery.of(context).viewInsets.bottom;
    return Stack(
      children: [
        Scaffold(
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
              'Add Additional Work',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: zimkeyWhite,
              ),
            ),
          ),
          body: Container(
            width: double.infinity,
            color: zimkeyWhite,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            'Select a new booking date',
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
                                            color: monthFilter == tempMonth[i]
                                                ? zimkeyOrange
                                                : zimkeyLightGrey,
                                          ),
                                          color: monthFilter == tempMonth[i]
                                              ? zimkeyBodyOrange
                                              : zimkeyLightGrey,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3.0, vertical: 10),
                                        child: Text(
                                            '${tempMonth[i].toString().substring(0, 3)}'),
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
                          child: ListView(
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
                                  'Select a new booking time slot',
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
                                              scrollDirection: Axis.horizontal,
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
                                              scrollDirection: Axis.horizontal,
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
                        SizedBox(
                          height: 20,
                        ),
                        unitsCalculator(),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select any Additional Work(s)',
                                style: TextStyle(
                                  color: zimkeyDarkGrey.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    checked = !checked;
                                  });
                                },
                                child: SvgPicture.asset(
                                  'assets/images/icons/newIcons/tick-circle.svg',
                                  color: checked
                                      ? zimkeyOrange
                                      : zimkeyDarkGrey.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        for (ServiceAddon addon in widget
                            .jobtem!
                            .bookingServiceItem!
                            .bookingService!
                            .service!
                            .addons!)
                          if (addon.type != null &&
                              addon.type
                                  .toString()
                                  .toLowerCase()
                                  .contains('partner') &&
                              checked)
                            AddonPicker(
                              addon: addon,
                              selectedAddons: selectedAddons,
                            ),
                        SizedBox(
                          height: 20,
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        selectedAddons
                            .removeWhere((element) => element['units'] == 0);
                        setState(() {});
                        if (selectedAddons.isNotEmpty || serviceUnit != 0)
                          await addAddWorkMutation(
                              widget.jobtem!.bookingServiceItemId);
                        else if (serviceUnit == null || serviceUnit == 0)
                          showCustomDialog(
                              'Oops!',
                              'You need to select the units of selected service - ${widget.jobtem!.bookingServiceItem!.bookingService!.service!.name}',
                              context,
                              null);
                        else if (selectedAddons.isEmpty)
                          showCustomDialog(
                              'Oops!',
                              'You need to select atleast one Addons.',
                              context,
                              null);
                      },
                      child: Container(
                        margin:
                            EdgeInsets.only(bottom: 30, left: 20, right: 20),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
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
                          'Add Work',
                          style: TextStyle(
                            fontSize: 16,
                            color: zimkeyWhite,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: addheight
                  //       // ? MediaQuery.of(context).size.height / 6.5
                  //       ? 100
                  //       : 40,
                  // ),
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

  Widget unitsCalculator() {
    String countUnit = '';
    if (widget.jobtem!.bookingServiceItem!.bookingService!.unit != null)
      countUnit =
          widget.jobtem!.bookingServiceItem!.bookingService!.unit.toString();
    if (countUnit.contains('.')) countUnit = countUnit.split('.')[1];
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'How many additional $countUnit(s)',
                    style: TextStyle(
                      color: zimkeyDarkGrey.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // TextSpan(
                  //   text: ReCase(
                  //           '${widget.jobtem.bookingServiceItem.bookingService.service.name}')
                  //       .titleCase,
                  //   style: TextStyle(
                  //     color: zimkeyDarkGrey,
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  TextSpan(
                    text: ' do you need? ',
                    style: TextStyle(
                      color: zimkeyDarkGrey.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              // color: zimkeyLightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (serviceUnit! > 0 && serviceUnit! > minServiceUnit)
                      setState(() {
                        serviceUnit = serviceUnit! - 1;
                      });
                    else
                      setState(() {
                        serviceUnit = 0;
                      });

                    // showCustomDialog(
                    //     'Oops!',
                    //     'The minimum allowed value is $minServiceUnit.',
                    //     context,
                    //     null);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    decoration: BoxDecoration(
                      color: zimkeyLightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                        'assets/images/icons/newIcons/minus.svg'),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '$serviceUnit',
                  style: TextStyle(
                    color: zimkeyDarkGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    if (serviceUnit != null && serviceUnit! < maxServiceUnit) {
                      setState(() {
                        var temp = serviceUnit! + 1;
                        if (temp < minServiceUnit) {
                          serviceUnit = minServiceUnit;
                        } else {
                          serviceUnit = temp;
                        }
                      });
                    } else
                      showCustomDialog(
                          'Oops!',
                          'The maximum allowed value is $maxServiceUnit.',
                          context,
                          null);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    decoration: BoxDecoration(
                      color: zimkeyLightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                        'assets/images/icons/newIcons/add.svg'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        await getBookingTimeSlots(
          widget.jobtem!.bookingServiceItem!.bookingService!
              .serviceBillingOptionId,
          fbState.partnerUser.value!.id,
          false,
          Dashboard(),
        );
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

  confirmationMsgDialog(
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
                      );
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

class AddonPicker extends StatefulWidget {
  final ServiceAddon? addon;
  final List<Map<String, dynamic>>? selectedAddons;

  AddonPicker({
    Key? key,
    this.addon,
    this.selectedAddons,
  }) : super(key: key);

  @override
  State<AddonPicker> createState() => _AddonPickerState();
}

class _AddonPickerState extends State<AddonPicker> {
  int? minUnit;
  int? maxUnit;
  int? thisUnit;
  ServiceAddon? selectedAddon;

  @override
  void initState() {
    minUnit = widget.addon!.minUnit;
    maxUnit = widget.addon!.maxUnit;
    thisUnit = 0;
    super.initState();
  }

  Widget build(BuildContext context) {
    return addonsTile(
      widget.addon!,
    );
  }

  Widget addonsTile(ServiceAddon addon) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: zimkeyLightGrey,
        border: Border.all(
          color: selectedAddon != null && selectedAddon!.id == addon.id
              ? zimkeyOrange.withOpacity(0.3)
              : zimkeyLightGrey,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/icons/newIcons/tick-circle.svg',
                  color: selectedAddon != null && selectedAddon!.id == addon.id
                      ? zimkeyOrange
                      : zimkeyDarkGrey.withOpacity(0.5),
                  height: 18,
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    var thisAddon = {
                      "addonId": addon.id,
                      "units": thisUnit!.toDouble(),
                    };
                    if (widget.selectedAddons!.isNotEmpty) {
                      for (Map<String, dynamic> thisAddons
                          in widget.selectedAddons!) {
                        if (thisAddons['addonId'] != thisAddon['addonId']) {
                          setState(() {
                            widget.selectedAddons!.add(thisAddon);
                            selectedAddon = addon;
                          });
                        } else {
                          setState(() {
                            widget.selectedAddons!.remove(thisAddon);
                            selectedAddon = null;
                          });
                        }
                      }
                    } else {
                      setState(() {
                        widget.selectedAddons!.add(thisAddon);
                        selectedAddon = addon;
                      });
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.name!,
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        addon.name!,
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(0.7),
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              // color: zimkeyLightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (thisUnit != null && minUnit != null) {
                      if (thisUnit! > minUnit!) {
                        setState(() {
                          thisUnit = thisUnit! - 1;
                        });
                      } else {
                        setState(() {
                          thisUnit = 0;
                        });
                        var thisAddon = {
                          "addonId": addon.id,
                          "units": thisUnit!.toDouble(),
                        };
                        if (thisUnit != 0) {
                          if (widget.selectedAddons!.isNotEmpty) {
                            var items = widget.selectedAddons?.where(
                                (element) => element['addonId'] == addon.id);
                            if (items?.isEmpty == true) {
                              widget.selectedAddons?.add(thisAddon);
                            } else {
                              widget.selectedAddons?.removeWhere(
                                  (element) => element['addonId'] == addon.id);
                              widget.selectedAddons?.add(thisAddon);
                            }
                            setState(() {});
                          } else {
                            setState(() {
                              widget.selectedAddons!.add(thisAddon);
                              selectedAddon = addon;
                            });
                          }
                        } else {
                          widget.selectedAddons?.removeWhere(
                              (element) => element['addonId'] == addon.id);
                          setState(() {});
                        }

                        // showCustomDialog(
                        //   'Oops!',
                        //   'The minimum allowed value is $minUnit.',
                        //   context,
                        //   null,
                        // );
                      }
                    } else {
                      // Handle the case when thisUnit or minUnit is null
                      // You may want to show an error message or handle it in some way
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    decoration: BoxDecoration(
                      color: zimkeyLightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                        'assets/images/icons/newIcons/minus.svg'),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '$thisUnit',
                  style: TextStyle(
                    color: zimkeyDarkGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    if (thisUnit! < maxUnit!) {
                      setState(() {
                        var temp = thisUnit! + 1;
                        if (temp < minUnit!) {
                          thisUnit = minUnit;
                        } else {
                          thisUnit = temp;
                        }
                      });
                      var thisAddon = {
                        "addonId": addon.id,
                        "units": thisUnit!.toDouble(),
                      };
                      if (thisUnit != 0) {
                        if (widget.selectedAddons!.isNotEmpty) {
                          var items = widget.selectedAddons?.where(
                              (element) => element['addonId'] == addon.id);
                          if (items?.isEmpty == true) {
                            widget.selectedAddons?.add(thisAddon);
                          } else {
                            widget.selectedAddons?.removeWhere(
                                (element) => element['addonId'] == addon.id);
                            widget.selectedAddons?.add(thisAddon);
                          }
                          setState(() {});
                        } else {
                          setState(() {
                            widget.selectedAddons!.add(thisAddon);
                            selectedAddon = addon;
                          });
                        }
                      } else {
                        widget.selectedAddons?.removeWhere(
                            (element) => element['addonId'] == addon.id);
                        setState(() {});
                      }
                    } else {
                      showCustomDialog(
                          'Oops!',
                          'The maximum allowed value is $maxUnit.',
                          context,
                          null);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    decoration: BoxDecoration(
                      color: zimkeyLightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                        'assets/images/icons/newIcons/add.svg'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
