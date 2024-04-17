import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:instant/instant.dart' as ins;
import 'package:instant/instant.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:recase/recase.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../fbState.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';
import 'jobCalendarDetail.dart' as b;
import 'model/calendar_model.dart' as c;

class JobsCalendar extends StatefulWidget {
  final Function(int index)? updateTab;
  final int? pos;

  const JobsCalendar({
    Key? key,
    this.updateTab,
    this.pos,
  }) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<JobsCalendar>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final FbState fbState = Get.put(FbState());

  // PageController controller = PageController(
  //   initialPage: 0,
  //   viewportFraction: 1.0,
  // );

  bool isLoading = false;

  List<String> projectStages = [
    'Requested',
    'Accepted',
    'Ongoing',
    'Completed'
  ];
  double taskStage = 1;
  String? jobStatus;

  List _tabs = [
    'Open',
    // 'Cancelled',
    'In - Progress',
    'Completed',
  ];
  bool showJobCaledarDetail = false;

  // this will control the button clicks and tab changing
  TabController? _controller;

  // this will control the animation when a button changes from an off state to an on state
  late AnimationController _animationControllerOn;

  // this will control the animation when a button changes from an on state to an off state
  late AnimationController _animationControllerOff;

  // this will give the background color values of a button when it changes to an on state
  late Animation _colorTweenBackgroundOn;

  // Animation _colorTweenBackgroundOff;
  // this will give the foreground color values of a button when it changes to an on state
  Animation? _colorTweenForegroundOn;
  Animation? _colorTweenForegroundOff;

  // when swiping, the _controller.index value only changes after the animation, therefore, we need this to trigger the animations and save the current index
  ValueNotifier<int> _currentIndex = ValueNotifier(0);

  // saves the previous active tab
  int _prevControllerIndex = 0;

  // saves the value of the tab animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
  double _aniValue = 0.0;

  // saves the previous value of the tab animation. It's used to figure the direction of the animation
  double _prevAniValue = 0.0;
  ButtonStyle? flatButtonStyle;

  // active button's foreground color
  Color _foregroundOn = zimkeyDarkGrey;
  Color _foregroundOff = zimkeyDarkGrey.withOpacity(0.4);

  // active button's background color
  Color _backgroundOn = zimkeyBodyOrange;
  Color _backgroundOff = zimkeyWhite;

  // scroll controller for the TabBar
  // ScrollController _scrollController = new ScrollController();

  // this will save the keys for each Tab in the Tab Bar, so we can retrieve their position and size for the scroll controller
  List _keys = [];

  // regist if the the button was tapped
  bool _buttonTap = false;

  updateTab(int pos) {
    _currentIndex.value = pos;
    _currentIndex.notifyListeners();
    _controller?.animateTo(pos);
  }

  filterOpenJobs() {
    //     enum BookingServiceItemStatusTypeEnum {
    //   OPEN,
    //   PARTNER_ASSIGNED,
    //   PARTNER_APPROVAL_PENDING,
    //   CUSTOMER_APPROVAL_PENDING,
    //   PAYMENT_PENDING,
    //   IN_PROGRESS,
    //   CLOSED,
    //   CANCELED
    // }

//     enum PartnerCalendarStatusTypeEnum {
//   OPEN,
//   CANCELED_PARTNER,
//   CANCELED_CUSTOMER,
//   RESCHEDULED_PARTNER,
//   RESCHEDULED_CUSTOMER,
//   ADMIN_REASSIGNED,
//   DONE
// }
  }

  int pageNumber = 1;
  bool hasMore = true;

  @override
  void initState() {
    for (int index = 0; index < _tabs.length; index++) {
      // create a GlobalKey for each Tab
      _keys.add(new GlobalKey());
    }

    // this creates the controller with 6 tabs (in our case)
    _controller = TabController(vsync: this, length: _tabs.length);
    // this will execute the function every time there's a swipe animation
    _controller!.animation!.addListener(_handleTabAnimation);
    // this will execute the function every time the _controller.index value changes
    _controller!.addListener(_handleTabChange);

    _animationControllerOff =
        AnimationController(vsync: this, duration: Duration(milliseconds: 75));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOff.value = 1.0;
    // _colorTweenBackgroundOff =
    //     ColorTween(begin: _backgroundOn, end: _backgroundOff)
    //         .animate(_animationControllerOff);
    _colorTweenForegroundOff =
        ColorTween(begin: _foregroundOn, end: _foregroundOff)
            .animate(_animationControllerOff);

    _animationControllerOn =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOn.value = 1.0;
    _colorTweenBackgroundOn =
        ColorTween(begin: _backgroundOff, end: _backgroundOn)
            .animate(_animationControllerOn);
    _colorTweenForegroundOn =
        ColorTween(begin: _foregroundOff, end: _foregroundOn)
            .animate(_animationControllerOn);

    //button style
    flatButtonStyle = TextButton.styleFrom(
      // backgroundColor: zimkeyOrange,
      shape: const RoundedRectangleBorder(
          // borderRadius: BorderRadius.all(
          //     // Radius.circular(50.0),
          //     ),
          ),
    );
    print("Tab Posistion :${widget.pos}");
    if (widget.pos != null) {
      updateTab(widget.pos!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationControllerOff.dispose();
    _controller?.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: zimkeyOrange,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                child: Text(
                  'Your Jobs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: zimkeyWhite,
                  ),
                ),
              ),
            ),
            // centerTitle: false,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                // this is the TabBar
                // if (fbState.partnerUser.value.partnerDetails != null &&
                //     fbState.partnerUser.value.partnerDetails.approved != null &&
                //     fbState.partnerUser.value.partnerDetails.approved)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int index = 0; index < _tabs.length; index++)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _buttonTap = true;
                              // trigger the controller to change between Tab Views
                              _controller!.animateTo(index);
                              // set the current index
                              _setCurrentIndex(index);
                              // scroll to the tapped button (needed if we tap the active button and it's not on its position)
                              _scrollTo(index);
                            });
                          },
                          child: ValueListenableBuilder(
                              valueListenable: _currentIndex,
                              builder: (context, data, child) {
                                return AnimatedBuilder(
                                  animation: _colorTweenBackgroundOn,
                                  builder: (context, child) => Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    alignment: Alignment.center,
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                    key: _keys[index],
                                    child: Column(
                                      children: [
                                        AutoSizeText(
                                          _tabs[index],
                                          minFontSize: 12,
                                          maxFontSize: 14,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        CircleAvatar(
                                          radius: 3,
                                          backgroundColor: (index == data)
                                              ? zimkeyOrange
                                              : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                    ],
                    // },
                  ),
                ),
                // (fbState.partnerUser.value.partnerDetails != null &&
                //         fbState.partnerUser.value.partnerDetails.approved !=
                //             null &&
                //         fbState.partnerUser.value.partnerDetails.approved)
                //     ?
                Flexible(
                  child: TabBarView(
                    controller: _controller,
                    children: <Widget>[
                      // our Tab Views
                      BookingWidget(
                        status: PartnerBookingsStatusTypeEnum.OPEN,
                        updateTab: updateTab,
                      ),
                      BookingWidget(
                        status: PartnerBookingsStatusTypeEnum.IN_PROGRESS,
                        updateTab: updateTab,
                      ),
                      BookingWidget(
                        status: PartnerBookingsStatusTypeEnum.COMPLETED,
                        updateTab: widget.updateTab,
                      ),
                    ],
                  ),
                )
                // Query(
                //   options: QueryOptions(
                //     document: gql(getPartnerCalendar),
                //     fetchPolicy: FetchPolicy.noCache,
                //     cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
                //     variables: {
                //       "pageSize": 50,
                //       "pageNumber": 1,
                //     },
                //   ),
                //   builder: (
                //     QueryResult result2, {
                //     VoidCallback? refetch,
                //     FetchMore? fetchMore,
                //   }) {
                //     if (result2.isLoading)
                //       return Container(
                //           width: double.infinity,
                //           height: MediaQuery.of(context).size.height / 1.7,
                //           child: Center(child: sharedLoadingIndicator()));
                //     else if (result2.data != null &&
                //         result2.data!['getPartnerCalendarItems'] != null) {
                //       jobsCalendar.clear();
                //       openJobs.clear();
                //       progressJobs.clear();
                //       completedJobs.clear();
                //       for (Map item in result2.data!['getPartnerCalendarItems']
                //           ['data']) {
                //         PartnerCalendarItem temp;
                //         temp = PartnerCalendarItem.fromJson(
                //             item as Map<String, dynamic>);
                //         jobsCalendar.add(temp);
                //       }
                //       filterOpenJobs();
                //       fbState.setJobCalendarList(jobsCalendar);
                //     } else if (result2.hasException) {
                //       print('partner calendar EXCEPTION $result2!!');
                //     }
                //     QueryOptions _buildFetchMoreOptions(QueryResult result) {
                //       final lastDoc =
                //           result.data!['getPartnerCalendarItems']['data'].last;
                //       return QueryOptions(
                //         document: gql(getPartnerCalendar),
                //         fetchPolicy: FetchPolicy.noCache,
                //         variables: {
                //           "pageSize": 20,
                //           "pageNumber": pageNumber + 1,
                //           'lastDocId': lastDoc[
                //               'id'], // Assuming you have a unique ID field
                //         },
                //       );
                //     }
                //
                //
                //   },
                // )

                // : pendingJobWidegt(),
              ],
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

  Widget pendingJobWidegt() {
    return Container(
      height: MediaQuery.of(context).size.height - 300,
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
        // color: zimkeyBodyOrange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/icons/newIcons/information.svg'),
          SizedBox(
            height: 20,
          ),
          Text(
            'No jobs assigned for you yet!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '\n Kindly wait for your confirmation by the Zimkey team.',
              style: TextStyle(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget jobListItem(c.PartnerCalendarItemNew jobitem, Refetch? refetch) {
    String endHr;
    String endMin;
    DateTime serviceDate = jobitem.serviceDate;
    serviceDate = dateTimeToZone(zone: "IST", datetime: serviceDate);
    String hr = serviceDate.hour.toString();
    if (hr.length < 2) hr = '0$hr';
    String min = serviceDate.minute.toString();
    if (min.length < 2) min = '0$min';
    endMin = min;
    endHr = '${serviceDate.hour + 1}';
    if (endHr.toString().length < 2) endHr = '0$endHr';
//get areaname
    String? thisArea;

    thisArea = jobitem.booking.bookingAddress.area.name;
    /////
    String bookingStatus = jobitem.booking!.bookingStatus!;

    /////
    String calendarItemStatus = jobitem.partnerCalendarStatus.toString();
    if (calendarItemStatus != null &&
        calendarItemStatus.isNotEmpty &&
        calendarItemStatus != 'null' &&
        calendarItemStatus.contains('.')) {
      calendarItemStatus = calendarItemStatus.split('.')[1];
      if (calendarItemStatus.contains('_'))
        calendarItemStatus = calendarItemStatus.replaceAll('_', ' ');
    }
    ////
    jobStatus = jobitem.bookingServiceItem!.bookingServiceItemStatus.toString();
    if (jobStatus != null && jobStatus != 'null')
      jobStatus = jobStatus!.split('.')[1];
    switch (jobStatus) {
      case 'OPEN':
        {
          if (calendarItemStatus.toLowerCase().contains('canceled'))
            taskStage = 3;
          else
            taskStage = 0;
          break;
        }
      case 'PARTNER_ASSIGNED':
        {
          taskStage = 1;
          break;
        }
      case 'PARTNER_APPROVAL_PENDING':
        {
          taskStage = 1;
          break;
        }
      case 'CUSTOMER_APPROVAL_PENDING':
        {
          taskStage = 1;
          break;
        }
      case 'IN_PROGRESS':
        {
          taskStage = 2;
          break;
        }
      case 'CLOSED':
        {
          taskStage = 3;
          break;
        }
    }
    if (jobStatus != null &&
        jobStatus!.isNotEmpty &&
        jobStatus != 'null' &&
        jobStatus!.contains('_')) {
      jobStatus = jobStatus!.replaceAll('_', ' ');
    }
    // print('Status Item >>>> $jobStatus --- $taskStage');
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => JobCalendarDetail(
        //       jobitem: jobitem,
        //       bookingArea: thisArea,
        //       updateTab: widget.updateTab,
        //       // refetchJobs: refetch(),
        //     ),
        //   ),
        // );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          color: zimkeyWhite,
          // border: Border.all(
          //   color: zimkeyBodyOrange,
          // ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            new BoxShadow(
              color: zimkeyDarkGrey.withOpacity(0.1),
              offset: new Offset(0.0, 2.0),
              blurRadius: 5.0,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          'Booking ID: ',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${jobitem.booking!.userBookingNumber}',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (jobitem.booking?.bookingStatus?.toLowerCase() ==
                          "payment pending")
                        Container(
                          margin: EdgeInsets.only(bottom: 3),
                          child: Text(
                            '${jobitem.booking?.bookingStatus ?? ""}',
                            style: TextStyle(
                              color: zimkeyOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // if (jobStatus != null &&
                      //     jobStatus.isNotEmpty &&
                      //     jobStatus != "null" &&
                      //     jobStatus.contains('PENDING'))
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: zimkeyGreen.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          calendarItemStatus != null &&
                                  calendarItemStatus.isNotEmpty &&
                                  calendarItemStatus.contains('CANCELED')
                              ? '$calendarItemStatus'
                              : '$jobStatus',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${DateTime.parse('${jobitem.serviceDate}').day.toString().padLeft(2, '0')}-${DateTime.parse('${jobitem.serviceDate}').month.toString().padLeft(2, '0')}-${DateTime.parse('${jobitem.serviceDate}').year}  $hr:$min - $endHr:$endMin',
                      style: TextStyle(
                        color: zimkeyDarkGrey.withOpacity(1.0),
                        // fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (thisArea != null)
                    Text(
                      '$thisArea',
                      style: TextStyle(
                        color: zimkeyDarkGrey.withOpacity(1.0),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: zimkeyOrange,
                ),
                child: bookingServiceItem(
                    jobitem.booking!.bookingService!, jobitem.booking!),
              ),
            ),
            if (taskStage < 3)
              SizedBox(
                height: 25,
              ),
            if (taskStage < 3)
              Container(
                // color: zimkeyLightGrey,
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < projectStages.length; i++)
                      TimelineTile(
                        isFirst: i == 0 ? true : false,
                        isLast: i == projectStages.length - 1 ? true : false,
                        endChild: Container(
                          constraints: const BoxConstraints(
                            minWidth: 85,
                          ),
                        ),
                        indicatorStyle: IndicatorStyle(
                          color:
                              i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                          height: 19,
                          width: 19,
                          iconStyle: IconStyle(
                            iconData: Icons.circle_outlined,
                            color: zimkeyWhite,
                          ),
                        ),
                        axis: TimelineAxis.horizontal,
                        alignment: TimelineAlign.center,
                        afterLineStyle: LineStyle(
                          thickness: 2.5,
                          color:
                              i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                        ),
                        beforeLineStyle: LineStyle(
                          thickness: 3,
                          color:
                              i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                        ),
                        startChild: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            '${projectStages[i]}',
                            style: TextStyle(
                              fontSize: 13,
                              // fontWeight: FontWeight.bold,
                              color: i <= taskStage
                                  ? zimkeyOrange
                                  : zimkeyDarkGrey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget bookingServiceItem(c.BookingService bookingServ, c.Booking booking) {
    String? billingoption;
    List<c.BillingOption> allOptions = bookingServ.service.billingOptions;
    for (c.BillingOption op in allOptions) {
      if (op.id == bookingServ.serviceBillingOptionId) {
        billingoption = op.name;
      }
    }
    String? servIcon;
    servIcon = serviceImg + bookingServ.service.icon;
    bool isPng = false;
    if (servIcon != null && servIcon.contains('png')) isPng = true;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              color: zimkeyWhite.withOpacity(0.9),
              border: Border.all(
                color: zimkeyBodyOrange,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                servIcon == null || servIcon.isEmpty
                    ? SvgPicture.asset(
                        'assets/images/icons/img_icon.svg',
                        height: 30,
                        width: 30,
                      )
                    : (isPng)
                        ? Image.network(
                            servIcon,
                            height: 40,
                            width: 40,
                          )
                        : SvgPicture.network(
                            servIcon,
                            height: 30,
                            width: 30,
                          ),
                Container(
                  // width: 10,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: zimkeyOrange, width: 2),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bookingServ.service!.name}',
                        style: TextStyle(
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        '$billingoption',
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(1.0),
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
        ),
        Container(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Text(
            (booking.bookingPayments != null &&
                    booking.bookingPayments!.isNotEmpty &&
                    booking.bookingPayments!.first.amountPaid != null)
                ? '₹${booking.bookingPayments!.first.amountPaid}'
                : '₹0',
            style: TextStyle(
              color: zimkeyWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget emptyBookingWidget() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 200,
      // color: zimkeyBodyOrange,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No jobs in your calender.',
            style: TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Please check your ',
                    style: TextStyle(
                      fontSize: 15,
                      color: zimkeyBlack,
                    ),
                  ),
                  TextSpan(
                    text: 'Job Board ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: zimkeyOrange,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        widget.updateTab!(1);
                      },
                  ),
                  TextSpan(
                    text: 'tab for new incoming jobs.',
                    style: TextStyle(
                      fontSize: 15,
                      color: zimkeyBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          SvgPicture.asset(
            'assets/images/icons/newIcons/information.svg',
            // height: 100,
            // width: 100,
          ),
        ],
      ),
    );
  }

  // runs during the switching tabs animation
  _handleTabAnimation() {
    // gets the value of the animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
    _aniValue = _controller!.animation!.value;

    // if the button wasn't pressed, which means the user is swiping, and the amount swipped is less than 1 (this means that we're swiping through neighbor Tab Views)
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      // set the current tab index
      _setCurrentIndex(_aniValue.round());
    }

    // save the previous Animation Value
    _prevAniValue = _aniValue;
  }

  // runs when the displayed tab changes
  _handleTabChange() {
    // if a button was tapped, change the current index
    if (_buttonTap) _setCurrentIndex(_controller!.index);

    // this resets the button tap
    if ((_controller!.index == _prevControllerIndex) ||
        (_controller!.index == _aniValue.round())) _buttonTap = false;

    // save the previous controller index
    _prevControllerIndex = _controller!.index;
  }

  _setCurrentIndex(int index) {
    // if we're actually changing the index
    if (index != _currentIndex) {
      // setState(() {
      // change the index
      _currentIndex.value = index;
      _currentIndex.notifyListeners();
      // });

      // trigger the button animation
      _triggerAnimation();
      // scroll the TabBar to the correct position (if we have a scrollable bar)
      _scrollTo(index);
    }
  }

  _triggerAnimation() {
    // reset the animations so they're ready to go
    _animationControllerOn.reset();
    _animationControllerOff.reset();

    // run the animations!
    _animationControllerOn.forward();
    _animationControllerOff.forward();
  }

  _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    double screenWidth = MediaQuery.of(context).size.width;

    // get the button we want to scroll to
    RenderBox renderBox = _keys[index].currentContext.findRenderObject();
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(Offset.zero).dx;

    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      // get the first button
      renderBox = _keys[0].currentContext.findRenderObject();
      // get the position of the first button of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox = _keys[_tabs.length - 1].currentContext.findRenderObject();
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }

    //   // scroll the calculated ammount
    //   _scrollController.animateTo(offset + _scrollController.offset,
    //       duration: new Duration(milliseconds: 150), curve: Curves.easeInOut);
  }
}

class BookingWidget extends StatefulWidget {
  final PartnerBookingsStatusTypeEnum status;
  final Function(int index)? updateTab;

  const BookingWidget({super.key, required this.status, this.updateTab});

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  ValueNotifier<List<c.PartnerCalendarItemNew>> items = ValueNotifier([]);
  bool hasMore = false;
  int pageNo = 1;
  int totPage = 1;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Function? refetchlist;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    await refetchlist!();
    // setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  bool hasNextPage = false;

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User reached the end of the list
      if (!_isLoading) {}
    }
  }

  List<String> projectStages = [
    'Requested',
    'Accepted',
    'Ongoing',
    'Completed'
  ];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // refetchlist!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
          document: gql(getCalenerShort),
          variables: {
            'pageSize': 10,
            'pageNumber': pageNo,
            'status': widget.status.name.toUpperCase()
          },
          fetchPolicy: FetchPolicy.noCache),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        refetchlist = refetch;

        if (result.data != null &&
            result.data!['getPartnerCalendarItems'] != null) {
          items.value.addAll(List<c.PartnerCalendarItemNew>.from(result
              .data!['getPartnerCalendarItems']['data']
              .map((x) => c.PartnerCalendarItemNew.fromJson(x))));
          items.value = items.value.toSet().toList();
          print(result.data?['getPartnerCalendarItems']['data'].toString());
          if (result.data?['getPartnerCalendarItems']['pageInfo'] != null) {
            // pageNo = result.data!['getPartnerCalendarItems']['pageInfo']
            //     ['currentPage'];
            hasMore = result.data!['getPartnerCalendarItems']['pageInfo']
                ['hasNextPage'];
            totPage = result.data!['getPartnerCalendarItems']['pageInfo']
                ['totalPage'];
          }
        } else if (result.hasException) {
          print('partner calendar EXCEPTION $result!!');
        }

        return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                if (pageNo < totPage) {
                  pageNo++;
                  print("page no:$pageNo");
                  fetchMore!(FetchMoreOptions(
                    variables: {
                      'pageSize': 10,
                      'pageNumber': pageNo,
                      'status': widget.status.name.toUpperCase()
                    },
                    updateQuery: (previousResultData, fetchMoreResultData) {
                      // Update the existing data with new data
                      final List<dynamic> newData =
                          fetchMoreResultData!['getPartnerCalendarItems']
                              ['data'];
                      return {
                        'getPartnerCalendarItems': {
                          'data': [...newData]
                        }
                      };
                    },
                  ));
                }
              }
              return false;
            },
            child: ValueListenableBuilder(
              valueListenable: items,
              builder: (context, data, child) {
                return pageNo == 1 && result.isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : data.isEmpty
                        ? emptyBookingWidget()
                        : SmartRefresher(
                            enablePullDown: true,
                            footer: ClassicFooter(
                              loadStyle: LoadStyle.ShowWhenLoading,
                              completeDuration: Duration(milliseconds: 500),
                            ),
                            header: WaterDropHeader(),
                            controller: _refreshController,
                            onRefresh: _onRefresh,
                            onLoading: _onLoading,
                            child: ListView.builder(
                              itemCount: data.length + 1,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return index >= data.length
                                    ? pageNo < totPage
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : SizedBox()
                                    : jobListItem(data[index]);
                              },
                            ),
                          );
              },
            ));
      },
    );
  }

  Widget jobListItem(
    c.PartnerCalendarItemNew jobitem,
  ) {
    String endHr;
    String endMin;
    DateTime serviceDate = jobitem.serviceDate!;
    serviceDate = dateTimeToZone(zone: "IST", datetime: serviceDate);
    String hr = serviceDate.hour.toString();
    if (hr.length < 2) hr = '0$hr';
    String min = serviceDate.minute.toString();
    if (min.length < 2) min = '0$min';
    endMin = min;
    endHr = '${serviceDate.hour + 1}';
    if (endHr.toString().length < 2) endHr = '0$endHr';
//get areaname
    String? thisArea;
    DateTime servDateTime =
        ins.dateTimeToZone(zone: "IST", datetime: jobitem.serviceDate);
    /////
    int taskStage = 0;
    String bookingStatus = jobitem.booking!.bookingStatus!;
    if (bookingStatus.contains('_')) bookingStatus.replaceAll('_', ' ');
    bookingStatus = ReCase(bookingStatus).titleCase;
    /////
    String calendarItemStatus = jobitem.partnerCalendarStatus.toString();
    if (calendarItemStatus.isNotEmpty &&
        calendarItemStatus != 'null' &&
        calendarItemStatus.contains('.')) {
      calendarItemStatus = calendarItemStatus.split('.')[1];
      if (calendarItemStatus.contains('_'))
        calendarItemStatus = calendarItemStatus.replaceAll('_', ' ');
    }
    ////
    var jobStatus =
        jobitem.bookingServiceItem.bookingServiceItemStatus.toString();

    switch (jobStatus) {
      case 'OPEN':
        {
          if (calendarItemStatus.toLowerCase().contains('canceled'))
            taskStage = 3;
          else
            taskStage = 0;
          break;
        }
      case 'PARTNER_ASSIGNED':
        {
          taskStage = 1;
          break;
        }
      case 'PARTNER_APPROVAL_PENDING':
        {
          taskStage = 1;
          break;
        }
      case 'CUSTOMER_APPROVAL_PENDING':
        {
          taskStage = 1;
          break;
        }
      case 'IN_PROGRESS':
        {
          taskStage = 2;
          break;
        }
      case 'CLOSED':
        {
          taskStage = 3;
          break;
        }
    }
    if (jobStatus != null &&
        jobStatus!.isNotEmpty &&
        jobStatus != 'null' &&
        jobStatus!.contains('_')) {
      jobStatus = jobStatus!.replaceAll('_', ' ');
    }
    // print('Status Item >>>> $jobStatus --- $taskStage');
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => b.JobCalendarDetail(
              id: jobitem.id,
              bookingArea: thisArea,
              updateTab: widget.updateTab,
              // refetchJobs: refetch(),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          color: zimkeyWhite,
          // border: Border.all(
          //   color: zimkeyBodyOrange,
          // ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            new BoxShadow(
              color: zimkeyDarkGrey.withOpacity(0.1),
              offset: new Offset(0.0, 2.0),
              blurRadius: 5.0,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          'Booking ID: ',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${jobitem.booking!.userBookingNumber}',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (bookingStatus.toLowerCase() == "payment pending")
                        Container(
                          margin: EdgeInsets.only(bottom: 3),
                          child: Text(
                            '$bookingStatus',
                            style: TextStyle(
                              color: zimkeyOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // if (jobStatus != null &&
                      //     jobStatus.isNotEmpty &&
                      //     jobStatus != "null" &&
                      //     jobStatus.contains('PENDING'))
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: zimkeyGreen.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          calendarItemStatus.isNotEmpty &&
                                  calendarItemStatus.contains('CANCELED')
                              ? '$calendarItemStatus'
                              : '$jobStatus',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd-MM-yyyy HH:mm').format(
                          jobStatus == "CLOSED"
                              ? jobitem.bookingServiceItem.endDateTime!
                              : servDateTime),
                      style: TextStyle(
                        color: zimkeyDarkGrey.withOpacity(1.0),
                        // fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  jobitem.bookingServiceItem.bookingServiceItemType?.index == 1
                      ? Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: zimkeyOrange.withOpacity(0.6)),
                          child: Text("Rework"),
                        )
                      : SizedBox()
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: zimkeyOrange,
                ),
                child: bookingServiceItem(
                    jobitem.booking.bookingService, jobitem.booking),
              ),
            ),
            if (taskStage < 3)
              SizedBox(
                height: 25,
              ),
            if (taskStage < 3)
              Container(
                // color: zimkeyLightGrey,
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < projectStages.length; i++)
                      TimelineTile(
                        isFirst: i == 0 ? true : false,
                        isLast: i == projectStages.length - 1 ? true : false,
                        endChild: Container(
                          constraints: const BoxConstraints(
                            minWidth: 85,
                          ),
                        ),
                        indicatorStyle: IndicatorStyle(
                          color:
                              i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                          height: 19,
                          width: 19,
                          iconStyle: IconStyle(
                            iconData: Icons.circle_outlined,
                            color: zimkeyWhite,
                          ),
                        ),
                        axis: TimelineAxis.horizontal,
                        alignment: TimelineAlign.center,
                        afterLineStyle: LineStyle(
                          thickness: 2.5,
                          color:
                              i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                        ),
                        beforeLineStyle: LineStyle(
                          thickness: 3,
                          color:
                              i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                        ),
                        startChild: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            '${projectStages[i]}',
                            style: TextStyle(
                              fontSize: 13,
                              // fontWeight: FontWeight.bold,
                              color: i <= taskStage
                                  ? zimkeyOrange
                                  : zimkeyDarkGrey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget bookingServiceItem(c.BookingService bookingServ, c.Booking booking) {
    String? billingoption;
    List<c.BillingOption> allOptions = bookingServ.service.billingOptions;
    for (c.BillingOption op in allOptions) {
      if (op.id == bookingServ.serviceBillingOptionId) {
        billingoption = op.name;
      }
    }
    String? servIcon;
    servIcon = serviceImg + bookingServ.service.icon;
    bool isPng = false;
    if (servIcon != null && servIcon.contains('png')) isPng = true;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              color: zimkeyWhite.withOpacity(0.9),
              border: Border.all(
                color: zimkeyBodyOrange,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                servIcon == null || servIcon.isEmpty
                    ? SvgPicture.asset(
                        'assets/images/icons/img_icon.svg',
                        height: 30,
                        width: 30,
                      )
                    : (isPng)
                        ? Image.network(
                            servIcon,
                            height: 40,
                            width: 40,
                          )
                        : SvgPicture.network(
                            servIcon,
                            height: 30,
                            width: 30,
                          ),
                Container(
                  // width: 10,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: zimkeyOrange, width: 2),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bookingServ.service!.name}',
                        style: TextStyle(
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        '$billingoption',
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(1.0),
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
        ),
        Container(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Text(
            (booking.bookingPayments != null &&
                    booking.bookingPayments!.isNotEmpty &&
                    booking.bookingPayments!.first.amountPaid != null)
                ? '₹${booking.bookingPayments!.first.amountPaid}'
                : '₹0',
            style: TextStyle(
              color: zimkeyWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget emptyBookingWidget() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 200,
      // color: zimkeyBodyOrange,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No jobs in your calender.',
            style: TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Please check your ',
                    style: TextStyle(
                      fontSize: 15,
                      color: zimkeyBlack,
                    ),
                  ),
                  TextSpan(
                    text: 'Job Board ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: zimkeyOrange,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        widget.updateTab!(1);
                      },
                  ),
                  TextSpan(
                    text: 'tab for new incoming jobs.',
                    style: TextStyle(
                      fontSize: 15,
                      color: zimkeyBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          SvgPicture.asset(
            'assets/images/icons/newIcons/information.svg',
            // height: 100,
            // width: 100,
          ),
        ],
      ),
    );
  }
}
