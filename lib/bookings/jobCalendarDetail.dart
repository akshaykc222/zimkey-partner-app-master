import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:instant/instant.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:recase/recase.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:zimkey_partner_app/models/team_model.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/GetServiceBookingSlot.dart';
import '../models/bookingsModel.dart' as b;
import '../models/jobModel.dart';
import '../models/serviceModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../shared/inputDone.dart';
import '../theme.dart';
import 'addAdditionalWork.dart';
import 'rescheduleJob.dart';

class JobCalendarDetail extends StatefulWidget {
  final String id;
  final String? bookingArea;
  final Function(int index)? updateTab;
  final Function? refetchJobs;
  final bool? isFromNotification;

  const JobCalendarDetail({
    Key? key,
    required this.id,
    this.bookingArea,
    this.updateTab,
    this.isFromNotification,
    this.refetchJobs,
  }) : super(key: key);

  @override
  _JobCalendarDetailState createState() => _JobCalendarDetailState();
}

class _JobCalendarDetailState extends State<JobCalendarDetail> {
  int serviceRating = -1;
  final FbState fbState = Get.find();
  TextEditingController _workCode = TextEditingController();
  TextEditingController _finishComments = TextEditingController();
  TextEditingController _unassignReason = TextEditingController();

  bool showClearIcon = false;

  List<String> projectStages = [
    'Requested',
    'Accepted',
    'Ongoing',
    'Completed'
  ];
  int taskStage = 2;
  String? jobStatus;
  bool isLoading = false;
  PartnerCalendarItem? i;

  //Finish query mutation-------
  Future<QueryResult> finishJobMutation(
      String? bookingServiceItemId, PartnerCalendarItem i) async {
    List<b.AdditionalPaymentRefundInput> additionalPaymentRefunds = [];
    for (BookingAdditionalPayment addl
        in i.bookingServiceItem!.bookingService!.bookingAdditionalPayments!) {
      if (addl.refundable!)
        additionalPaymentRefunds.add(b.AdditionalPaymentRefundInput(
            amount: double.parse(addl.itemPrice.toString()),
            bookingAdditionalPaymentId: addl.id));
    }
    final MutationOptions _options = MutationOptions(
      document: gql(finishJob),
      variables: <String, dynamic>{
        "bookingServiceItemId": bookingServiceItemId,
        "additionalPaymentRefunds": additionalPaymentRefunds,
        "note": _finishComments.text,
      },
    );
    setState(() {
      isLoading = true;
    });
    final QueryResult finishJobResult =
        await globalGQLClient.value.mutate(_options);
    setState(() {
      isLoading = false;
    });
    if (finishJobResult.hasException) {
      print(finishJobResult.exception.toString());
    }
    if (finishJobResult.data != null &&
        finishJobResult.data!['finishJob'] != null) {
      print('finish job success!!!!!');
    }
    return finishJobResult;
  }

  String filterTimeSlot(GetServiceBookingSlot serviceBookingSlot) {
    DateFormat format = DateFormat.Hm();
    String output =
        '${format.format(serviceBookingSlot.start.toLocal())} - ${format.format(serviceBookingSlot.end.toLocal())}';
    return output;
  }

//Uncommit Job
  Future<QueryResult> uncommitJobMutation(String? bookingServiceItemId) async {
    final MutationOptions _options = MutationOptions(
      document: gql(uncommitJob),
      variables: <String, dynamic>{
        "bookingServiceItemId": bookingServiceItemId,
      },
    );
    setState(() {
      isLoading = true;
    });
    final QueryResult uncommitJobResult =
        await globalGQLClient.value.mutate(_options);
    setState(() {
      isLoading = false;
    });
    if (uncommitJobResult.hasException) {
      showCustomDialog(
          'Oops',
          '${uncommitJobResult.exception!.graphqlErrors.first.message}',
          context,
          null);
      print(uncommitJobResult.exception.toString());
    }
    if (uncommitJobResult != null &&
        uncommitJobResult.data != null &&
        uncommitJobResult.data!['uncommitJob'] != null) {
      showCustomDialog(
          'Done',
          'The Zimkey job has been unassigned successfully.',
          context,
          Dashboard(
            index: 2,
          ));
      // await widget.refetchJobs;
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => JobsCalendar(),
      //   ),
      // );
      print('finish job success!!!!!');
    }
    return uncommitJobResult;
  }

  ValueNotifier<bool> loading = ValueNotifier(false);
  String? refId;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isFromNotification == true ? false : true,
      onPopInvoked: (val) {
        if (widget.isFromNotification == true) {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: Dashboard(
                index: 1,
              ),
              duration: Duration(milliseconds: 300),
            ),
          );
        } else {
          // Navigator.pop(context);
        }
      },
      child: Query(
          options: QueryOptions(
              document: gql(getPartnerCalendar),
              fetchPolicy: FetchPolicy.noCache,
              variables: {"id": widget.id}),
          builder: (
            QueryResult result, {
            VoidCallback? refetch,
            FetchMore? fetchMore,
          }) {
            if (result.isLoading) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (result.hasException ||
                result.data?['getPartnerCalendarItem'] == null) {
              print(result.exception.toString());
              return SizedBox();
            }
            // print(
            //     "resultItem ${result.data!['getPartnerCalendarItem']['bookingServiceItem']['bookingService']}");

            // print(refId);
            ServiceBillingOption billingOption = ServiceBillingOption.fromJson(
                result.data!['getPartnerCalendarItem']['bookingServiceItem']
                    ['bookingService']['serviceBillingOption']);
            i = PartnerCalendarItem.fromJson(
                result.data!['getPartnerCalendarItem']);
            PartnerCalendarItem item = PartnerCalendarItem.fromJson(
                result.data!['getPartnerCalendarItem']);
            // print(object)
            if (item.bookingServiceItem?.bookingServiceItemType?.index == 1) {
              refId = result.data?['getPartnerCalendarItem']
                      ['bookingServiceItem']['refBookingServiceItem']
                  ['activePartnerCalenderId'];
            }

            return result.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: [
                      Scaffold(
                        backgroundColor: zimkeyWhite,
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
                            'Job Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: zimkeyWhite,
                            ),
                          ),
                          // bottom: PreferredSize(
                          //   preferredSize: Size.fromHeight(35.0),
                          //   child: Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          //     width: double.infinity,
                          //     child: Text(
                          //       'Booking Detail',
                          //       style: TextStyle(
                          //         fontSize: 18,
                          //         fontWeight: FontWeight.bold,
                          //         color: zimkeyWhite,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                        body: Container(
                          color: zimkeyWhite,
                          // height: MediaQuery.of(context).size.height,
                          // child: SingleChildScrollView(
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (item.bookingServiceItem!
                                              .bookingServiceItemStatus ==
                                          BookingServiceItemStatusTypeEnum
                                              .PARTNER_APPROVAL_PENDING &&
                                      item.bookingServiceItem
                                              ?.pendingRescheduleByCustomer !=
                                          null)
                                  ? Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: zimkeyLightGrey,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Reschedule Request",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            item.bookingServiceItem
                                                        ?.pendingRescheduleByCustomer !=
                                                    null
                                                ? "Partner want to reschedule this work to \n${item.bookingServiceItem?.pendingRescheduleByCustomer!.startDateTime.day.toString().padLeft(2, '0')}-${item.bookingServiceItem?.pendingRescheduleByCustomer!.startDateTime.month.toString().padLeft(2, '0')}-${item.bookingServiceItem?.pendingRescheduleByCustomer!.startDateTime.year} | ${filterTimeSlot(GetServiceBookingSlot(start: item.bookingServiceItem!.pendingRescheduleByCustomer!.startDateTime, end: item.bookingServiceItem!.pendingRescheduleByCustomer!.endDateTime, available: true))}"
                                                : "",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () => jobOfferDialog(
                                                      "Decline",
                                                      "Are you sure you want to decline",
                                                      context, () async {
                                                    print("tapping");
                                                    QueryResult
                                                        apprveJobResult =
                                                        await approvePendingJob(
                                                            item.bookingServiceItemId,
                                                            false);
                                                    print(apprveJobResult);
                                                    if (apprveJobResult.data !=
                                                            null &&
                                                        apprveJobResult.data![
                                                                'approveJob'] !=
                                                            null) {
                                                      showCustomDialog(
                                                        'Yay!',
                                                        'You\'ve successfully declined this job.',
                                                        context,
                                                        Dashboard(
                                                          index: 2,
                                                        ),
                                                      );
                                                    } else if (apprveJobResult
                                                        .hasException) {
                                                      if (apprveJobResult
                                                                  .exception!
                                                                  .graphqlErrors !=
                                                              null &&
                                                          apprveJobResult
                                                              .exception!
                                                              .graphqlErrors
                                                              .isNotEmpty)
                                                        showCustomDialog(
                                                            'Ooops!',
                                                            '${apprveJobResult.exception!.graphqlErrors[0].message}',
                                                            context,
                                                            null);
                                                      else
                                                        showCustomDialog(
                                                            'Ooops!',
                                                            'Looks like something went wrong. Try again later.',
                                                            context,
                                                            null);
                                                      print(
                                                          'Approve JOB excpetion >> ${apprveJobResult.exception}');
                                                    }
                                                  }),
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                      color: zimkeyWhite,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: zimkeyDarkGrey
                                                              .withOpacity(0.1),
                                                          blurRadius:
                                                              5.0, // soften the shadow
                                                          spreadRadius:
                                                              1.0, //extend the shadow
                                                          offset: const Offset(
                                                            2.0,
                                                            // Move to right 10  horizontally
                                                            3.0, // Move to bottom 10 Vertically
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 13),
                                                    child: const Text(
                                                      'Decline',
                                                      style: TextStyle(
                                                        color: zimkeyRed,
                                                        // color: AppColors.zimkeyWhite,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () => jobOfferDialog(
                                                      "Accept",
                                                      "Are you sure you want to accept",
                                                      context, () async {
                                                    print("tapping");
                                                    QueryResult
                                                        apprveJobResult =
                                                        await approvePendingJob(
                                                            item.bookingServiceItemId,
                                                            true);
                                                    print(apprveJobResult);
                                                    if (apprveJobResult !=
                                                            null &&
                                                        apprveJobResult.data !=
                                                            null &&
                                                        apprveJobResult.data![
                                                                'approveJob'] !=
                                                            null) {
                                                      showCustomDialog(
                                                        'Yay!',
                                                        'You\'ve successfully approved this job.',
                                                        context,
                                                        Dashboard(
                                                          index: 2,
                                                        ),
                                                      );
                                                    } else if (apprveJobResult
                                                        .hasException) {
                                                      if (apprveJobResult
                                                                  .exception!
                                                                  .graphqlErrors !=
                                                              null &&
                                                          apprveJobResult
                                                              .exception!
                                                              .graphqlErrors
                                                              .isNotEmpty)
                                                        showCustomDialog(
                                                            'Ooops!',
                                                            '${apprveJobResult.exception!.graphqlErrors[0].message}',
                                                            context,
                                                            null);
                                                      else
                                                        showCustomDialog(
                                                            'Ooops!',
                                                            'Looks like something went wrong. Try again later.',
                                                            context,
                                                            null);
                                                      print(
                                                          'Approve JOB excpetion >> ${apprveJobResult.exception}');
                                                    }
                                                  }),
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                      color: zimkeyWhite,
                                                      // color: AppColors.buttonColor,
                                                      // border: Border.all(
                                                      //   color: zimkeyOrange.withOpacity(0.7),
                                                      // ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: zimkeyDarkGrey
                                                              .withOpacity(0.1),
                                                          blurRadius:
                                                              5.0, // soften the shadow
                                                          spreadRadius:
                                                              1.0, //extend the shadow
                                                          offset: const Offset(
                                                            2.0,
                                                            // Move to right 10  horizontally
                                                            3.0, // Move to bottom 10 Vertically
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 13),
                                                    child: const Text(
                                                      'Accept',
                                                      style: TextStyle(
                                                        color: zimkeyGreen,
                                                        // color: AppColors.zimkeyWhite,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                              Hero(
                                tag: 'tag${item.id}',
                                child: Material(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20, bottom: 5),
                                    child: detailBookingWidget(item),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                color: zimkeyWhite,
                                child: Column(
                                  children: [
                                    item
                                                    .bookingServiceItem
                                                    ?.bookingServiceItemType
                                                    ?.index ==
                                                1 &&
                                            item
                                                    .partnerCalendarStatus ==
                                                PartnerCalendarStatusTypeEnum
                                                    .REWORK_PENDING
                                        ? Container(
                                            margin: EdgeInsets.only(bottom: 15),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                //accept job
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      reworkJobDialog(
                                                          'Accept Job',
                                                          'Are you sure you want to accept this job.',
                                                          context,
                                                          null,
                                                          item,
                                                          true);
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15,
                                                              horizontal: 20),
                                                      decoration: BoxDecoration(
                                                        color: zimkeyOrange,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                zimkeyLightGrey
                                                                    .withOpacity(
                                                                        0.1),
                                                            blurRadius:
                                                                5.0, // soften the shadow
                                                            spreadRadius:
                                                                2.0, //extend the shadow
                                                            offset: Offset(
                                                              1.0,
                                                              // Move to right 10  horizontally
                                                              1.0, // Move to bottom 10 Vertically
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      child: Text(
                                                        'Accept',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: zimkeyWhite,
                                                          fontFamily: 'Inter',
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                //start job
                                                // Expanded(
                                                //   child: InkWell(
                                                //     onTap: () async {
                                                //       reworkJobDialog(
                                                //           'Reject Job',
                                                //           'Are you sure you want to Reject this job.',
                                                //           context,
                                                //           null,
                                                //           widget.jobitem,
                                                //           false);
                                                //     },
                                                //     child: Container(
                                                //       alignment: Alignment.center,
                                                //       padding: EdgeInsets.symmetric(
                                                //           vertical: 15, horizontal: 20),
                                                //       decoration: BoxDecoration(
                                                //         color: zimkeyOrange,
                                                //         borderRadius:
                                                //             BorderRadius.circular(30),
                                                //         boxShadow: [
                                                //           BoxShadow(
                                                //             color: zimkeyLightGrey
                                                //                 .withOpacity(0.1),
                                                //             blurRadius:
                                                //                 5.0, // soften the shadow
                                                //             spreadRadius:
                                                //                 2.0, //extend the shadow
                                                //             offset: Offset(
                                                //               1.0, // Move to right 10  horizontally
                                                //               1.0, // Move to bottom 10 Vertically
                                                //             ),
                                                //           )
                                                //         ],
                                                //       ),
                                                //       child: Text(
                                                //         'Reject',
                                                //         style: TextStyle(
                                                //           fontSize: 16,
                                                //           color: zimkeyWhite,
                                                //           fontFamily: 'Inter',
                                                //           // fontWeight: FontWeight.bold,
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          )
                                        : item.bookingServiceItem
                                                        ?.canStartJob ==
                                                    true ||
                                                item.bookingServiceItem
                                                            ?.canUncommit ==
                                                        true &&
                                                    (item.partnerCalendarStatus !=
                                                        PartnerCalendarStatusTypeEnum
                                                            .CANCELED_PARTNER) &&
                                                    (item.partnerCalendarStatus !=
                                                        PartnerCalendarStatusTypeEnum
                                                            .CANCELED_CUSTOMER)
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 15),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    //unassign job
                                                    item.bookingServiceItem
                                                                    ?.canUncommit ==
                                                                true &&
                                                            (item.partnerCalendarStatus !=
                                                                PartnerCalendarStatusTypeEnum
                                                                    .CANCELED_PARTNER) &&
                                                            (item.partnerCalendarStatus !=
                                                                PartnerCalendarStatusTypeEnum
                                                                    .CANCELED_CUSTOMER)
                                                        ? Expanded(
                                                            child: InkWell(
                                                              onTap: () async {
                                                                if (item.serviceDate!
                                                                        .difference(
                                                                            DateTime.now())
                                                                        .inHours <=
                                                                    3)
                                                                  unassignConfirmDialog(
                                                                      'Oops!',
                                                                      'Looks like your job is scheduled to start in 3 hours. Could you provide your reason for uncommiting the job?',
                                                                      context,
                                                                      false,
                                                                      item,
                                                                      "Unassign");
                                                                else
                                                                  await uncommitJobMutation(item
                                                                      .bookingServiceItem!
                                                                      .id);
                                                                widget
                                                                    .refetchJobs!();
                                                              },
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            15,
                                                                        horizontal:
                                                                            20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      zimkeyOrange,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: zimkeyLightGrey
                                                                          .withOpacity(
                                                                              0.1),
                                                                      blurRadius:
                                                                          5.0,
                                                                      // soften the shadow
                                                                      spreadRadius:
                                                                          2.0,
                                                                      //extend the shadow
                                                                      offset:
                                                                          Offset(
                                                                        1.0,
                                                                        // Move to right 10  horizontally
                                                                        1.0, // Move to bottom 10 Vertically
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                child: Text(
                                                                  'Unassign Job ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        zimkeyWhite,
                                                                    fontFamily:
                                                                        'Inter',
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    //start job
                                                    item.bookingServiceItem
                                                                    ?.canStartJob ==
                                                                true &&
                                                            (item.partnerCalendarStatus !=
                                                                PartnerCalendarStatusTypeEnum
                                                                    .CANCELED_PARTNER) &&
                                                            (item.partnerCalendarStatus !=
                                                                PartnerCalendarStatusTypeEnum
                                                                    .CANCELED_CUSTOMER)
                                                        ? Expanded(
                                                            child: InkWell(
                                                              onTap: () async {
                                                                _workCode
                                                                    .clear();
                                                                startJobDialog(
                                                                  'Verification',
                                                                  'Enter job work code for verification.',
                                                                  context,
                                                                  null,
                                                                  item,
                                                                );
                                                              },
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            15,
                                                                        horizontal:
                                                                            20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      zimkeyOrange,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: zimkeyLightGrey
                                                                          .withOpacity(
                                                                              0.1),
                                                                      blurRadius:
                                                                          5.0,
                                                                      // soften the shadow
                                                                      spreadRadius:
                                                                          2.0,
                                                                      //extend the shadow
                                                                      offset:
                                                                          Offset(
                                                                        1.0,
                                                                        // Move to right 10  horizontally
                                                                        1.0, // Move to bottom 10 Vertically
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                child: Text(
                                                                  'Start Job',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        zimkeyWhite,
                                                                    fontFamily:
                                                                        'Inter',
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(),
                                    if (jobStatus!.toLowerCase().contains(
                                            'partner approval pending') &&
                                        !(item
                                                    .bookingServiceItem
                                                    ?.bookingServiceItemType
                                                    ?.index ==
                                                1 &&
                                            item.partnerCalendarStatus ==
                                                PartnerCalendarStatusTypeEnum
                                                    .REWORK_PENDING))
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Expanded(
                                            //   child: InkWell(
                                            //     onTap: () async {
                                            //       await uncommitJobMutation(
                                            //           widget.jobitem.bookingServiceItem.id);
                                            //       await widget.refetchJobs;
                                            //     },
                                            //     child: Container(
                                            //       alignment: Alignment.center,
                                            //       // width: MediaQuery.of(context).size.width,
                                            //       padding: EdgeInsets.symmetric(
                                            //           vertical: 10, horizontal: 20),
                                            //       decoration: BoxDecoration(
                                            //         color: zimkeyBodyOrange,
                                            //         borderRadius: BorderRadius.circular(10),
                                            //         boxShadow: [
                                            //           BoxShadow(
                                            //             color:
                                            //                 zimkeyLightGrey.withOpacity(0.05),
                                            //             blurRadius: 3.0, // soften the shadow
                                            //             spreadRadius: 3.0, //extend the shadow
                                            //             offset: Offset(
                                            //               1.0, // Move to right 10  horizontally
                                            //               3.0, // Move to bottom 10 Vertically
                                            //             ),
                                            //           )
                                            //         ],
                                            //       ),
                                            //       child: Text(
                                            //         'Reject',
                                            //         style: TextStyle(
                                            //           fontSize: 16,
                                            //           color: zimkeyOrange,
                                            //           fontFamily: 'Inter',
                                            //           // fontWeight: FontWeight.bold,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                            // SizedBox(
                                            //   width: 20,
                                            // ),
                                          ],
                                        ),
                                      ),
                                    if (item.bookingServiceItem != null &&
                                        item.bookingServiceItem!
                                                .canReschedule !=
                                            null &&
                                        item.bookingServiceItem!
                                            .canReschedule! &&
                                        !(item
                                                    .bookingServiceItem
                                                    ?.bookingServiceItemType
                                                    ?.index ==
                                                1 &&
                                            item.partnerCalendarStatus ==
                                                PartnerCalendarStatusTypeEnum
                                                    .REWORK_PENDING) &&
                                        (item.partnerCalendarStatus !=
                                            PartnerCalendarStatusTypeEnum
                                                .CANCELED_CUSTOMER) &&
                                        (item.partnerCalendarStatus !=
                                            PartnerCalendarStatusTypeEnum
                                                .CANCELED_PARTNER))
                                      Column(
                                        children: [
                                          //reschedule job-----------
                                          InkWell(
                                            onTap: () async {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeft,
                                                  child: RescheduleJobpage(
                                                    bookingItemId: item
                                                        .bookingServiceItem!.id,
                                                    jobitem: item,
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 5),
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15, horizontal: 20),
                                              decoration: BoxDecoration(
                                                color: zimkeyWhite,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: zimkeyLightGrey
                                                        .withOpacity(0.1),
                                                    blurRadius:
                                                        5.0, // soften the shadow
                                                    spreadRadius:
                                                        2.0, //extend the shadow
                                                    offset: Offset(
                                                      1.0,
                                                      // Move to right 10  horizontally
                                                      1.0, // Move to bottom 10 Vertically
                                                    ),
                                                  )
                                                ],
                                              ),
                                              child: Text(
                                                'Reschedule Job',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: zimkeyDarkGrey,
                                                  fontFamily: 'Inter',
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          //add sope of work
                                          // if (widget.jobitem!.bookingServiceItem!
                                          //             .bookingService !=
                                          //         null &&
                                          //     widget.jobitem!.bookingServiceItem!
                                          //             .bookingService!.service !=
                                          //         null &&
                                          //     widget.jobitem!.bookingServiceItem!
                                          //             .bookingService!.service!.addons !=
                                          //         null &&
                                          //     widget
                                          //         .jobitem!
                                          //         .bookingServiceItem!
                                          //         .bookingService!
                                          //         .service!
                                          //         .addons!
                                          //         .isNotEmpty)
                                          //   InkWell(
                                          //     onTap: () {
                                          //       Navigator.push(
                                          //         context,
                                          //         PageTransition(
                                          //           type: PageTransitionType.rightToLeft,
                                          //           child: AddScope(
                                          //             bookingServiceItemId: widget
                                          //                 .jobitem!.bookingServiceItem!.id,
                                          //             jobItem: widget.jobitem,
                                          //           ),
                                          //           duration: Duration(milliseconds: 300),
                                          //         ),
                                          //       );
                                          //     },
                                          //     // child: Expanded(
                                          //     child: Container(
                                          //       width: MediaQuery.of(context).size.width,
                                          //       margin: EdgeInsets.only(
                                          //           bottom: 15, left: 15, right: 15),
                                          //       alignment: Alignment.center,
                                          //       // width: (MediaQuery.of(context).size.width) - 200,
                                          //       padding: EdgeInsets.symmetric(
                                          //           vertical: 15, horizontal: 20),
                                          //       decoration: BoxDecoration(
                                          //         color: zimkeyWhite,
                                          //         borderRadius: BorderRadius.circular(30),
                                          //         boxShadow: [
                                          //           BoxShadow(
                                          //             color: zimkeyLightGrey.withOpacity(0.1),
                                          //             blurRadius: 5.0, // soften the shadow
                                          //             spreadRadius: 2.0, //extend the shadow
                                          //             offset: Offset(
                                          //               1.0, // Move to right 10  horizontally
                                          //               1.0, // Move to bottom 10 Vertically
                                          //             ),
                                          //           )
                                          //         ],
                                          //       ),
                                          //       child: Text(
                                          //         'Add Scope of Work',
                                          //         style: TextStyle(
                                          //           fontSize: 16,
                                          //           color: zimkeyDarkGrey,
                                          //           fontFamily: 'Inter',
                                          //           // fontWeight: FontWeight.bold,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //     // ),
                                          //   ),
                                          //Uncommit job ------
                                        ],
                                      ),

                                    //finish job
                                    if (taskStage == 2)
                                      InkWell(
                                        onTap: () async {
                                          // FocusNode.
                                          print("test");
                                          FocusScope.of(context).unfocus();
                                          finishJobDialog(
                                              'Finish Job',
                                              'Add your finishing comments.',
                                              context,
                                              null,
                                              item);
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(
                                              bottom: 15, left: 20, right: 20),
                                          alignment: Alignment.center,
                                          // width: (MediaQuery.of(context).size.width) - 240,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: zimkeyOrange,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: zimkeyLightGrey
                                                    .withOpacity(0.1),
                                                blurRadius:
                                                    5.0, // soften the shadow
                                                spreadRadius:
                                                    2.0, //extend the shadow
                                                offset: Offset(
                                                  1.0,
                                                  // Move to right 10  horizontally
                                                  1.0, // Move to bottom 10 Vertically
                                                ),
                                              )
                                            ],
                                          ),
                                          child: Text(
                                            'Finish Job',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: zimkeyWhite,
                                              fontFamily: 'Inter',
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    //Add Additional work------------------
                                    if (item.bookingServiceItem!
                                                .bookingService !=
                                            null &&
                                        item.bookingServiceItem!.bookingService!
                                                .service !=
                                            null &&
                                        jobStatus != 'CLOSED' &&
                                        !(item
                                                    .bookingServiceItem
                                                    ?.bookingServiceItemType
                                                    ?.index ==
                                                1 &&
                                            item.partnerCalendarStatus ==
                                                PartnerCalendarStatusTypeEnum
                                                    .REWORK_PENDING) &&
                                        (item.partnerCalendarStatus !=
                                            PartnerCalendarStatusTypeEnum
                                                .CANCELED_PARTNER) &&
                                        (item.partnerCalendarStatus !=
                                            PartnerCalendarStatusTypeEnum
                                                .CANCELED_CUSTOMER) &&
                                        item
                                                .bookingServiceItem
                                                ?.bookingServiceItemType
                                                ?.index !=
                                            1 &&
                                        item
                                                .bookingServiceItem
                                                ?.bookingServiceItemType
                                                ?.index !=
                                            2)
                                      InkWell(
                                        onTap: () async {
                                          billingOption;
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: AddAdditionalwork(
                                                serviceBillingOption:
                                                    billingOption,
                                                bookingItemId:
                                                    item.bookingServiceItem!.id,
                                                jobtem: item,
                                              ),
                                              duration:
                                                  Duration(milliseconds: 300),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(
                                              bottom: 30, left: 20, right: 20),
                                          alignment: Alignment.center,
                                          // width: (MediaQuery.of(context).size.width) - 240,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: zimkeyOrange,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: zimkeyLightGrey
                                                    .withOpacity(0.1),
                                                blurRadius:
                                                    5.0, // soften the shadow
                                                spreadRadius:
                                                    2.0, //extend the shadow
                                                offset: Offset(
                                                  1.0,
                                                  // Move to right 10  horizontally
                                                  1.0, // Move to bottom 10 Vertically
                                                ),
                                              )
                                            ],
                                          ),
                                          child: Text(
                                            'Add Additional Work',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: zimkeyWhite,
                                              fontFamily: 'Inter',
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              item.bookingServiceItem?.additionalWork.isEmpty ==
                                      true
                                  ? const SizedBox()
                                  : const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 20.0, top: 8),
                                          child: Text(
                                            'Additional Works',
                                            style: TextStyle(
                                              color: zimkeyDarkGrey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        SizedBox()
                                      ],
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              item.bookingServiceItem?.additionalWork.isEmpty ==
                                      true
                                  ? const SizedBox()
                                  : Column(
                                      children: [
                                        ListView.builder(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: item.bookingServiceItem
                                                ?.additionalWork.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) =>
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: zimkeyLightGrey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 10),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          HelperWidgets
                                                              .buildText(
                                                                  text:
                                                                      "Status",
                                                                  fontSize: 13),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: zimkeyGreen
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                            ),
                                                            child: HelperWidgets
                                                                .buildText(
                                                              text: item
                                                                      .bookingServiceItem
                                                                      ?.additionalWork[
                                                                          index]
                                                                      .bookingAdditionalWorkStatus ??
                                                                  "",
                                                              color:
                                                                  zimkeyDarkGrey,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      item
                                                                  .bookingServiceItem
                                                                  ?.additionalWork[
                                                                      index]
                                                                  .bookingAddons
                                                                  .isNotEmpty ==
                                                              true
                                                          ? Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: HelperWidgets.buildText(
                                                                  text:
                                                                      "Booking Addons",
                                                                  color:
                                                                      zimkeyDarkGrey,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          : SizedBox(),
                                                      ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount: item
                                                              .bookingServiceItem
                                                              ?.additionalWork[
                                                                  index]
                                                              .bookingAddons
                                                              .length,
                                                          itemBuilder:
                                                              (context, i) =>
                                                                  ListTile(
                                                                    title: Text(item
                                                                            .bookingServiceItem
                                                                            ?.additionalWork[index]
                                                                            .bookingAddons[i]
                                                                            .name ??
                                                                        ""),
                                                                    subtitle: Text(
                                                                        "${item.bookingServiceItem?.additionalWork[index].bookingAddons[i].units}  ${item.bookingServiceItem?.additionalWork[index].bookingAddons[i].unit}"),
                                                                    trailing: Text(
                                                                        "₹${item.bookingServiceItem?.additionalWork[index].bookingAddons[i].amount.grandTotal}"),
                                                                  )),
                                                      item
                                                                  .bookingServiceItem
                                                                  ?.additionalWork[
                                                                      index]
                                                                  .bookingAddons
                                                                  .isEmpty ==
                                                              true
                                                          ? const SizedBox()
                                                          : const SizedBox(
                                                              height: 5,
                                                            ),
                                                      item
                                                                  .bookingServiceItem
                                                                  ?.additionalWork[
                                                                      index]
                                                                  .modificationReason ==
                                                              null
                                                          ? const SizedBox()
                                                          : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                HelperWidgets
                                                                    .buildText(
                                                                        text:
                                                                            "Modification Reason",
                                                                        fontSize:
                                                                            13),
                                                                HelperWidgets
                                                                    .buildText(
                                                                  text: item
                                                                          .bookingServiceItem
                                                                          ?.additionalWork[
                                                                              index]
                                                                          .modificationReason ??
                                                                      "",
                                                                  color:
                                                                      zimkeyDarkGrey,
                                                                  fontSize: 13,
                                                                ),
                                                              ],
                                                            ),
                                                      SizedBox(
                                                        height: item
                                                                    .bookingServiceItem
                                                                    ?.additionalWork[
                                                                        index]
                                                                    .modificationReason ==
                                                                null
                                                            ? 0
                                                            : 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          HelperWidgets.buildText(
                                                              text:
                                                                  "Additional Work Hr(s)",
                                                              fontSize: 13),
                                                          HelperWidgets
                                                              .buildText(
                                                            text: item
                                                                    .bookingServiceItem
                                                                    ?.additionalWork[
                                                                        index]
                                                                    .additionalHoursUnits
                                                                    .toString() ??
                                                                "",
                                                            color:
                                                                zimkeyDarkGrey,
                                                            fontSize: 13,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          HelperWidgets.buildText(
                                                              text:
                                                                  "Additional Hr Total",
                                                              fontSize: 13),
                                                          HelperWidgets
                                                              .buildText(
                                                            text:
                                                                "₹${item.bookingServiceItem?.additionalWork[index].additionalHoursAmount?.grandTotal?.toStringAsFixed(2) ?? 0}",
                                                            color:
                                                                zimkeyDarkGrey,
                                                            fontSize: 13,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          HelperWidgets.buildText(
                                                              text:
                                                                  "Grand Total",
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: zimkeyOrange
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                            ),
                                                            child: HelperWidgets.buildText(
                                                                text:
                                                                    "₹${item.bookingServiceItem?.additionalWork[index].totalAdditionalWork?.grandTotal}" ??
                                                                        "",
                                                                color:
                                                                    zimkeyDarkGrey,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )),
                                      ],
                                    ),
                              SizedBox(
                                height: 200,
                              ),
                            ],
                          ),
                          // ),
                        ),
                      ),
                      if (taskStage >= 1 && taskStage <= 2)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                confirmCallDialog(
                                    'Call Request',
                                    'A request will be sent to your Zimkey customer. You will receive a call from them soon.',
                                    context,
                                    true,
                                    i,
                                    'Request Call');
                              },
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: zimkeyBodyOrange,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: zimkeyDarkGrey.withOpacity(0.1),
                                        blurRadius: 5.0, // soften the shadow
                                        spreadRadius: 1.0, //extend the shadow
                                        offset: Offset(
                                          3.0, // Move to right 10  horizontally
                                          3.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.call,
                                    color: zimkeyOrange,
                                  )),
                            ),
                          ),
                        ),
                      if (isLoading) Center(child: sharedLoadingIndicator()),
                    ],
                  );
          }),
    );
  }

  unassignConfirmDialog(String title, String msg, BuildContext context,
      bool isRefresh, PartnerCalendarItem? jobItem, String buttonText) {
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
                  padding: EdgeInsets.only(left: 20, right: 15, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$title',
                          style: TextStyle(
                            color: zimkeyBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _unassignReason.clear();
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
                        style: TextStyle(
                          fontSize: 13,
                          color: zimkeyDarkGrey,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: zimkeyLightGrey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color: zimkeyDarkGrey,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLength: 300,
                                maxLines: 4,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: _unassignReason,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  counterText: '',
                                  fillColor: zimkeyOrange,
                                  border: InputBorder.none,
                                  hintText: 'Tell us what happened',
                                  hintStyle: TextStyle(
                                    color: zimkeyDarkGrey.withOpacity(0.7),
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (_unassignReason.text.isNotEmpty)
                                    setState(() {
                                      showClearIcon = true;
                                    });
                                  else
                                    setState(() {
                                      showClearIcon = false;
                                    });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            if (showClearIcon)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _unassignReason.clear();
                                    showClearIcon = false;
                                  });
                                },
                                child: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: zimkeyDarkGrey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: zimkeyWhite,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: zimkeyDarkGrey.withOpacity(0.1),
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
                                    offset: Offset(
                                      2.0, // Move to right 10  horizontally
                                      3.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: new InkWell(
                                onTap: () async {
                                  _unassignReason.clear();
                                  Get.back();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: zimkeyOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: zimkeyOrange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: zimkeyDarkGrey.withOpacity(0.1),
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
                                    offset: Offset(
                                      2.0, // Move to right 10  horizontally
                                      3.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: new InkWell(
                                onTap: () async {
                                  Get.back();
                                  await uncommitJobMutation(
                                      jobItem!.bookingServiceItem!.id);
                                },
                                child: Text(
                                  '$buttonText',
                                  style: TextStyle(
                                    color: zimkeyWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // actions: <Widget>[],
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

  confirmCallDialog(String title, String msg, BuildContext context,
      bool isRefresh, PartnerCalendarItem? jobItem, String buttonText) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                          fontSize: 16,
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
                      style: TextStyle(
                        fontSize: 13,
                        color: zimkeyDarkGrey,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: zimkeyOrange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: zimkeyDarkGrey.withOpacity(0.1),
                              blurRadius: 5.0, // soften the shadow
                              spreadRadius: 1.0, //extend the shadow
                              offset: Offset(
                                2.0, // Move to right 10  horizontally
                                3.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: new InkWell(
                          onTap: () async {
                            QueryResult callPartnerResult =
                                await callPartnerMutation(
                                    jobItem!.bookingServiceItemId);
                            Fluttertoast.showToast(
                                msg: "Connecting to your Zimkey customer...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: zimkeyBodyOrange,
                                textColor: zimkeyDarkGrey,
                                fontSize: 13.0);
                            Get.back();
                            if (callPartnerResult.hasException) {
                              if (callPartnerResult.exception != null &&
                                  callPartnerResult.exception!.graphqlErrors !=
                                      null &&
                                  callPartnerResult
                                      .exception!.graphqlErrors.isNotEmpty &&
                                  callPartnerResult.exception!.graphqlErrors[0]
                                          .message !=
                                      null)
                                showCustomDialog(
                                    'Oops!',
                                    '${callPartnerResult.exception!.graphqlErrors[0].message}',
                                    context,
                                    null);
                              print(
                                  'callPartnerResult Excption >>>>> ${callPartnerResult.exception.toString()}');
                            }
                            if (callPartnerResult != null &&
                                callPartnerResult.data != null &&
                                callPartnerResult
                                        .data!['callPartnerCustomer'] !=
                                    null &&
                                callPartnerResult
                                    .data!['callPartnerCustomer']) {
                              showCustomDialog(
                                  'Done',
                                  'A call Request has been sent to your assigned partner.',
                                  context,
                                  null);
                              print('call Partner  success!!!!! ');
                            }
                          },
                          child: Text(
                            '$buttonText',
                            style: TextStyle(
                              color: zimkeyWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // actions: <Widget>[],
            ));
  }

  Widget subBookingItem(b.BookingServiceItems subBookings) {
    String? itemStatus;
    if (subBookings.bookingServiceItemStatus != null)
      itemStatus = subBookings.bookingServiceItemStatus.toString();
    if (itemStatus != null) {
      if (itemStatus.contains('.')) itemStatus = itemStatus.split('.')[1];
      if (itemStatus.contains('_'))
        itemStatus = itemStatus.replaceAll('_', ' ');
    }
    //-----------
    DateTime startDate;
    startDate =
        dateTimeToZone(zone: "IST", datetime: subBookings.startDateTime!);
    String hr = startDate.hour.toString();
    if (hr.length < 2) hr = '0$hr';
    String endHr;
    String endMin;
    String min = startDate.minute.toString();
    if (min.length < 2) min = '0$min';
    endMin = min;
    endHr = '${startDate.hour + 1}';
    if (endHr.toString().length < 2) endHr = '0$endHr';
    //-------------
    String? bookingType;
    if (subBookings.bookingServiceItemType != null) {
      bookingType = subBookings.bookingServiceItemType.toString();
      bookingType =
          bookingType.contains('.') ? bookingType.split('.')[1] : bookingType;
    }
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
          // color: zimkeyWhite.withOpacity(0.5),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subBookings.bookingServiceItemType != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${bookingType!.toUpperCase()}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: zimkeyDarkGrey.withOpacity(0.7)),
                            ),
                          ),
                          if (subBookings.bookingServiceItemStatus != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: zimkeyGreen.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$itemStatus',
                                style: TextStyle(
                                  fontSize: 11,
                                  // fontWeight: FontWeight.bold,
                                  color: zimkeyDarkGrey.withOpacity(1),
                                ),
                              ),
                            ),
                        ],
                      ),
                    SizedBox(
                      height: 2,
                    ),
                    if (subBookings.startDateTime != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Job Date & Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: zimkeyDarkGrey.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${subBookings.startDateTime!.day.toString().padLeft(2, '0')}-${subBookings.startDateTime!.month.toString().padLeft(2, '0')}-${subBookings.startDateTime!.year} | $hr:$min - $endHr:$endMin',
                            style: TextStyle(
                              fontSize: 12,
                              color: zimkeyDarkGrey,
                            ),
                          ),
                        ],
                      ),
                    if (subBookings.modificationReason != null &&
                        subBookings.modificationReason!.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: 12,
                                color: zimkeyDarkGrey.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${subBookings.modificationReason}',
                            style: TextStyle(
                              fontSize: 12,
                              color: zimkeyDarkGrey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          // if (subBookings.modificationReason != null &&
          //     subBookings.modificationReason!.isNotEmpty)
          //   Text(
          //     'Comments - ${ReCase(subBookings.modificationReason!).sentenceCase}',
          //     style: TextStyle(
          //       fontSize: 12,
          //       color: zimkeyDarkGrey.withOpacity(1),
          //     ),
          //   ),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }

  Future<QueryResult> changeTeams(
      List<String> teams, PartnerCalendarItem i) async {
    final MutationOptions _options = MutationOptions(
      document: gql(changeTeam),
      variables: <String, dynamic>{
        "partnerCalendarId": i.id,
        "teamIds": teams,
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
    if (rescheduleJobResult != null &&
        rescheduleJobResult.data != null &&
        rescheduleJobResult.data!['changeJobTeam'] != null) {
      showCustomDialog('Yay!', 'Team change successfully.', context, null);
      print('Reschedule job success!!!!!');
    }
    return rescheduleJobResult;
  }

  Widget detailBookingWidget(PartnerCalendarItem jobitem) {
    print('bookingiten Id ... ${jobitem.bookingServiceItemId}');
    DateTime servDateTime = jobitem.serviceDate!;
    String endHr;
    String endMin;
    String hr = servDateTime.hour.toString();
    if (hr.length < 2) hr = '0$hr';
    String min = servDateTime.minute.toString();
    if (min.length < 2) min = '0$min';
    endMin = min;
    endHr = '${servDateTime.hour + 1}';
    if (endHr.toString().length < 2) endHr = '0$endHr';
    /////////
    String? thisBookingoption;
    for (BillingOptions op
        in jobitem.booking!.bookingService!.service!.billingOptions!) {
      if (jobitem.booking!.bookingService!.serviceBillingOptionId == op.id)
        thisBookingoption = op.name;
    }
    ////////
    List<String?> serviceRequirements = [];
    for (ServiceRequirement req
        in jobitem.booking!.bookingService!.service!.requirements!) {
      if (jobitem.booking!.bookingService!.serviceRequirements != null)
        for (String reqIds
            in jobitem.booking!.bookingService!.serviceRequirements!) {
          if (reqIds == req.id) {
            serviceRequirements.add(req.title);
          }
        }
    }
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
    if (jobStatus!.contains('.')) jobStatus = jobStatus!.split('.')[1];
    switch (jobStatus) {
      case 'OPEN':
        {
          if (calendarItemStatus != null &&
              calendarItemStatus.isNotEmpty &&
              calendarItemStatus.toLowerCase().contains('canceled'))
            taskStage = 3;
          else
            taskStage = 0;
          break;
        }
      case 'PARTNER_ASSIGNED':
        {
          if (calendarItemStatus != null &&
              calendarItemStatus.isNotEmpty &&
              calendarItemStatus.toLowerCase().contains('canceled'))
            taskStage = 3;
          else
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
      case 'PAYMENT_PENDING':
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
      case 'CANCELED':
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
    print('Status Item >>>> $jobStatus --- $taskStage');
    /////
    String bookingStatus = jobitem.booking!.bookingStatus!;
    if (bookingStatus.contains('_')) bookingStatus.replaceAll('_', ' ');
    bookingStatus = ReCase(bookingStatus).titleCase;
    /////////
    String? servIcon;
    if (jobitem != null &&
        jobitem.bookingServiceItem != null &&
        jobitem.bookingServiceItem!.bookingService != null &&
        jobitem.bookingServiceItem!.bookingService!.service != null &&
        jobitem.bookingServiceItem!.bookingService!.service!.icon != null) {
      servIcon = jobitem.bookingServiceItem!.bookingService!.service!.icon !=
                  null &&
              jobitem.bookingServiceItem!.bookingService!.service!.icon!.url !=
                  null
          ? serviceImg +
              jobitem.bookingServiceItem!.bookingService!.service!.icon!.url!
          : "";
    }
    bool isPng = false;
    if (servIcon != null && servIcon.contains('png')) isPng = true;
    //service qty
    String billingUnit;
    int? billingQty;
    if (jobitem != null &&
        jobitem.bookingServiceItem != null &&
        jobitem.bookingServiceItem!.bookingService != null &&
        jobitem.bookingServiceItem!.bookingService!.qty != null)
      billingQty = jobitem.bookingServiceItem!.bookingService!.qty;
    //service Unit
    if (jobitem != null &&
        jobitem.bookingServiceItem != null &&
        jobitem.bookingServiceItem!.bookingService != null &&
        jobitem.bookingServiceItem!.bookingService!.unit != null) {
      billingUnit = jobitem.bookingServiceItem!.bookingService!.unit.toString();
      billingUnit = billingUnit.split('.')[1];
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: BoxDecoration(
        color: zimkeyWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          new BoxShadow(
            color: zimkeyDarkGrey.withOpacity(0.2),
            offset: new Offset(1.0, 3.0),
            blurRadius: 5.0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking ID: ${jobitem.booking!.userBookingNumber}',
                        style: TextStyle(
                          color: zimkeyOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      jobitem.bookingServiceItem?.bookingServiceItemType
                                  ?.index ==
                              1
                          ? InkWell(
                              onTap: () {
                                if (refId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobCalendarDetail(
                                        id: refId!,
                                        // bookingArea: thisArea,
                                        updateTab: widget.updateTab,
                                        // refetchJobs: refetch(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Go to main booking',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // if (bookingStatus.toLowerCase() == "payment pending")
                    //   Container(
                    //     margin: EdgeInsets.only(bottom: 3),
                    //     child: Text(
                    //       '$bookingStatus',
                    //       style: TextStyle(
                    //         color: zimkeyOrange,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // if (jobStatus != null &&
                    //     jobStatus.isNotEmpty &&
                    //     jobStatus != "null" &&
                    //     jobStatus.contains('PENDING'))
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: zimkeyGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        calendarItemStatus != null &&
                                calendarItemStatus.isNotEmpty &&
                                calendarItemStatus.contains('CANCELED')
                            ? '$calendarItemStatus'
                            : '$jobStatus',
                        //  '$jobStatus',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    jobitem.bookingServiceItem?.bookingServiceItemType?.index ==
                            1
                        ? Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: zimkeyOrange.withOpacity(0.6)),
                            child: Text("Rework"),
                          )
                        : SizedBox(),
                    jobitem.bookingServiceItem?.bookingServiceItemType?.index ==
                            2
                        ? Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: zimkeyOrange.withOpacity(0.6)),
                            child: Text("Additional"),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          if (jobitem != null &&
              jobitem.bookingServiceItem != null &&
              jobitem.bookingServiceItem!.bookingService != null &&
              jobitem.bookingServiceItem!.bookingService!.serviceRequirements !=
                  null &&
              jobitem.bookingServiceItem!.bookingService!.serviceRequirements!
                  .isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Booking Options Selected',
                    style: TextStyle(
                      color: zimkeyDarkGrey.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Wrap(
                    children: [
                      for (String requiremnts in jobitem.bookingServiceItem!
                          .bookingService!.serviceRequirements!)
                        Container(
                          margin: EdgeInsets.only(right: 7, bottom: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: zimkeyBodyOrange,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$requiremnts',
                            style: TextStyle(
                              color: zimkeyDarkGrey.withOpacity(1),
                              // fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Job Date - ',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${DateTime.parse('${jobitem.serviceDate}').day.toString().padLeft(2, '0')}-${DateTime.parse('${jobitem.serviceDate}').month.toString().padLeft(2, '0')}-${DateTime.parse('${jobitem.serviceDate}').year}',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(1),
                            // fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        Text(
                          'Job Time - ',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$hr:$min - $endHr:$endMin',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(1),
                            // fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                jobitem.team == null || jobitem.team?.isEmpty == true
                    ? SizedBox()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Teams',
                            style: TextStyle(
                              color: zimkeyDarkGrey.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          taskStage == 1
                              ? ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(15),
                                                topLeft: Radius.circular(15))),
                                        builder: (context) => GetTeamsWidget(
                                              onTap: (teamId) async {
                                                var data = await changeTeams(
                                                    teamId, i!);
                                                var teams =
                                                    data.data!['changeJobTeam']
                                                        ['teams'];
                                                var t = List<Team>.from(
                                                    teams.map((e) =>
                                                        Team.fromJson(e)));
                                                setState(() {
                                                  i?.team?.clear();
                                                  i?.team?.addAll(t);
                                                });
                                              },
                                              jobDate: i?.bookingServiceItem
                                                      ?.startDateTime ??
                                                  DateTime.now(),
                                              selectedTeams: i?.team
                                                  ?.map((e) => (e.id ?? ""))
                                                  .toList(),
                                            ));
                                  },
                                  child: Text("Change"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: zimkeyOrange,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                )
                              : SizedBox()
                        ],
                      ),
                i?.team == null || i?.team?.isEmpty == true
                    ? SizedBox()
                    : SizedBox(
                        height: 40,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: i?.team?.length,
                            itemBuilder: (context, index) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Center(
                                      child: Text(
                                    i!.team![index].name,
                                    style: TextStyle(color: zimkeyOrange),
                                  )),
                                )),
                      ),
                SizedBox(
                  height: i?.team == null ? 0 : 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: zimkeyLightGrey,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (jobitem.booking != null &&
                          jobitem.booking!.user != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Details',
                              style: TextStyle(
                                color: zimkeyDarkGrey.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            if (jobitem.booking != null &&
                                jobitem.booking!.user != null &&
                                jobitem.booking!.user!.name != null)
                              Text(
                                '${ReCase(jobitem.booking!.user!.name!).titleCase}',
                                style: TextStyle(
                                  color: zimkeyDarkGrey.withOpacity(1),
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            SizedBox(
                              height: 2,
                            ),
                            if (jobitem.booking != null &&
                                jobitem.booking!.user != null &&
                                jobitem.booking!.user!.phone != null)
                              Text(
                                '${jobitem.booking!.user!.phone}',
                                style: TextStyle(
                                  color: zimkeyDarkGrey.withOpacity(1),
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        ),
                      SizedBox(
                        width: 10,
                      ),
                      if (jobitem.booking != null &&
                          jobitem.booking!.bookingAddress != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (jobitem
                                      .booking!.bookingAddress!.addressType !=
                                  null)
                                Text(
                                  '${jobitem.booking!.bookingAddress!.addressType}',
                                  style: TextStyle(
                                    color: zimkeyDarkGrey.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              SizedBox(
                                height: 5,
                              ),
                              Wrap(
                                alignment: WrapAlignment.end,
                                children: [
                                  if (jobitem.booking!.bookingAddress!
                                              .buildingName !=
                                          null &&
                                      jobitem.booking!.bookingAddress!
                                          .buildingName!.isNotEmpty)
                                    Text(
                                      '${jobitem.booking!.bookingAddress!.buildingName},',
                                      style: TextStyle(
                                        color: zimkeyDarkGrey.withOpacity(1),
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  if (jobitem.booking!.bookingAddress!
                                              .locality !=
                                          null &&
                                      jobitem.booking!.bookingAddress!.locality!
                                          .isNotEmpty)
                                    Text(
                                      ' ${jobitem.booking!.bookingAddress!.locality},',
                                      style: TextStyle(
                                        color: zimkeyDarkGrey.withOpacity(1),
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  if (jobitem.booking!.bookingAddress!
                                              .landmark !=
                                          null &&
                                      jobitem.booking!.bookingAddress!.landmark!
                                          .isNotEmpty)
                                    Text(
                                      ' ${jobitem.booking!.bookingAddress!.landmark},',
                                      style: TextStyle(
                                        color: zimkeyDarkGrey.withOpacity(1),
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  if (widget.bookingArea != null &&
                                      widget.bookingArea!.isNotEmpty)
                                    Text(
                                      ' ${widget.bookingArea}',
                                      style: TextStyle(
                                        color: zimkeyDarkGrey.withOpacity(1),
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                ],
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    '${jobitem.booking!.bookingAddress!.postalCode}',
                                    style: TextStyle(
                                      color: zimkeyDarkGrey.withOpacity(1),
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  Text(
                                    ' - Kochi',
                                    style: TextStyle(
                                      color: zimkeyDarkGrey.withOpacity(1),
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: zimkeyOrange,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                right:
                                    BorderSide(color: zimkeyOrange, width: 2),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${jobitem.booking!.bookingService!.service!.name}',
                                  style: TextStyle(
                                    color: zimkeyDarkGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (thisBookingoption != null &&
                                    thisBookingoption.isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    child: Text(
                                      '${jobitem.bookingServiceItem?.unit ?? 0} ${thisBookingoption.toUpperCase()}',
                                      // n$billingQty ${billingUnit.toLowerCase()}',
                                      style: TextStyle(
                                        color: zimkeyDarkGrey.withOpacity(1.0),
                                        fontSize: 13,
                                        // fontWeight: FontWeight.bold,
                                      ),
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
                  if (jobitem.bookingServiceItem?.changePrice != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(
                        '₹${jobitem.bookingServiceItem!.changePrice!.grandTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: zimkeyWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            // color: zimkeyLightGrey,
            height: 70,
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
                      color: i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
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
                      color: i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                    ),
                    beforeLineStyle: LineStyle(
                      thickness: 3,
                      color: i <= taskStage ? zimkeyOrange : zimkeyDarkGrey2,
                    ),
                    startChild: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${projectStages[i]}',
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                          color:
                              // i <= taskStage ? zimkeyOrange :
                              zimkeyDarkGrey2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (jobitem.booking != null &&
              jobitem.booking!.pendingAmount != null &&
              jobitem.booking!.pendingAmount!.amount != null &&
              jobitem.booking!.pendingAmount!.amount! > 0 &&
              jobitem.bookingServiceItem?.bookingServiceItemType?.index != 2 &&
              jobitem.bookingServiceItem?.bookingServiceItemType?.index != 1)
            Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pending Payment',
                      style: TextStyle(
                        color: zimkeyDarkGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '₹${jobitem.booking!.pendingAmount!.amount!.roundToDouble()}',
                    style: TextStyle(
                      color: zimkeyDarkGrey,
                      // fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          // if (jobitem.bookingServiceItem != null &&
          //     jobitem.bookingServiceItem!.bookingAddons != null &&
          //     jobitem.bookingServiceItem!.bookingAddons!.isNotEmpty)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 15),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Booking Addons',
          //           style: TextStyle(
          //             color: zimkeyDarkGrey,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 15,
          //           ),
          //         ),
          //         SizedBox(
          //           height: 5,
          //         ),
          //         for (BookingAddons addons
          //             in jobitem.bookingServiceItem!.bookingAddons!)
          //           bookingAddonsSection(jobitem, addons),
          //       ],
          //     ),
          //   ),
          //Booking Comments-----
          if (jobitem.booking!.bookingNote != null &&
              jobitem.booking!.bookingNote!.isNotEmpty &&
              jobitem.booking!.bookingNote!.split(' - ').isNotEmpty)
            bookingCommentsSection(jobitem),
          //Reschedules--------
          if (i!.bookingServiceItem!.reschedules != null &&
              i!.bookingServiceItem!.reschedules!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: zimkeyLightGrey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reschedule Requests',
                    style: TextStyle(
                      color: zimkeyDarkGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  for (BookingServiceItemReschedules reschedules
                      in i!.bookingServiceItem!.reschedules!)
                    reschedulesItem(reschedules),
                ],
              ),
            ),
          //Subbookings--------
          if (i!.bookingServiceItem!.subBookings != null &&
              i!.bookingServiceItem!.subBookings!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: zimkeyLightGrey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sub-Bookings / Additional Works',
                    style: TextStyle(
                      color: zimkeyDarkGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  for (b.BookingServiceItems subBookings
                      in i!.bookingServiceItem!.subBookings!)
                    subBookingItem(subBookings),
                ],
              ),
            ),
        ],
      ),
    );
  }

  startJobFun(PartnerCalendarItem jobItem) async {
    if (_workCode.text.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 50), () {
        Navigator.pop(context);
      });

      setState(() {
        isLoading = true;
      });
      QueryResult startJobResult = await startJobMutation(
        jobItem.bookingServiceItem!.id,
        _workCode.text,
      );
      setState(() {
        isLoading = false;
      });

      if (startJobResult != null &&
          startJobResult.data != null &&
          startJobResult.data!['startJob'] != null) {
        print('start job success!!!!!');
        showCustomDialog(
          'Yay!',
          'Your job has started successfully. Kindly check the in-progress tab for all ongoing job details.',
          context,
          Dashboard(
            index: 2,
            tabIndex: 1,
          ),
        );
      }
      if (startJobResult.hasException) {
        if (startJobResult.exception!.graphqlErrors.isNotEmpty)
          showCustomDialog(
              'Oops',
              '${startJobResult.exception!.graphqlErrors.first.message}',
              context,
              null);

        if (startJobResult.exception!.linkException != null)
          showCustomDialog(
              'Oops',
              '${startJobResult.exception!.linkException.toString()}',
              context,
              null);
      }
    }
  }

  Widget reschedulesItem(BookingServiceItemReschedules reschedules) {
    //-----------
    DateTime startDate;
    startDate = dateTimeToZone(zone: "IST", datetime: reschedules.oldTime!);
    String hr = startDate.hour.toString();
    if (hr.length < 2) hr = '0$hr';
    String endHr;
    String endMin;
    String min = startDate.minute.toString();
    if (min.length < 2) min = '0$min';
    endMin = min;
    endHr = '${startDate.hour + 1}';
    if (endHr.toString().length < 2) endHr = '0$endHr';
    return Container(
      margin: EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reschedules.rescheduledBy != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rescheduled By',
                    style: TextStyle(fontSize: 12, color: zimkeyDarkGrey),
                  ),
                ),
                Text(
                  '${reschedules.rescheduledBy!.toUpperCase()}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: zimkeyDarkGrey.withOpacity(0.7)),
                ),
              ],
            ),
          SizedBox(
            height: 3,
          ),
          if (reschedules.oldTime != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Old Job Date & Time',
                    style: TextStyle(
                      fontSize: 12,
                      // fontWeight: FontWeight.bold,
                      color: zimkeyDarkGrey.withOpacity(1),
                    ),
                  ),
                ),
                Text(
                  '${reschedules.oldTime!.day.toString().padLeft(2, '0')}-${reschedules.oldTime!.month.toString().padLeft(2, '0')}-${reschedules.oldTime!.year} | $hr:$min - $endHr:$endMin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: zimkeyDarkGrey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget bookingCommentsSection(PartnerCalendarItem job) {
    String? bookNoteOther;
    String? bookNoteAdditional;
    if (job.booking!.bookingNote != null &&
        job.booking!.bookingNote!.isNotEmpty &&
        job.booking!.bookingNote!.split(' - ').isNotEmpty)
      bookNoteOther = job.booking!.bookingNote;
    if (bookNoteOther != null) {
      if (bookNoteOther.toLowerCase().contains('service details -'))
        bookNoteOther =
            bookNoteOther.toLowerCase().split('other service details - ')[1];
      bookNoteAdditional = bookNoteOther;
      if (bookNoteOther.toLowerCase().contains('additional comments -')) {
        bookNoteOther =
            bookNoteOther.toLowerCase().split('additional comments - ')[0];
        bookNoteOther = bookNoteOther.replaceAll('\n', '');
        bookNoteAdditional =
            bookNoteAdditional.toLowerCase().split('additional comments - ')[1];
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Comments',
            style: TextStyle(
              color: zimkeyDarkGrey.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          // if (bookNoteOther != null && bookNoteOther.isNotEmpty)
          //   Text(
          //     'Other Details - ${bookNoteOther.titleCase}',
          //     style: TextStyle(
          //       color: zimkeyDarkGrey,
          //       fontSize: 13,
          //     ),
          //   ),
          if (bookNoteAdditional != null && bookNoteAdditional.isNotEmpty)
            Text(
              '${job.booking!.bookingNote}',
              style: TextStyle(
                color: zimkeyDarkGrey,
                fontSize: 13,
              ),
            ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Widget bookingAddonsSection(
      PartnerCalendarItem jobitem, BookingAddons addons) {
    String unit;
    unit = addons.unit.toString();
    unit = unit.split('.')[1];
    double total = 0;
    total = (addons.units! * (addons.unitPrice ?? 0)).toDouble();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: zimkeyWhite.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${addons.name}',
                style: TextStyle(
                  color: zimkeyDarkGrey.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quantity',
                  style: TextStyle(
                    color: zimkeyDarkGrey,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${addons.units} $unit',
                style: TextStyle(
                  color: zimkeyDarkGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Addon Price',
                  style: TextStyle(
                    color: zimkeyDarkGrey,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '₹$total',
                style: TextStyle(
                  color: zimkeyDarkGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 7,
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    // Parse the duration string

    // Calculate days, hours, and remaining minutes
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;

    // Build the formatted string
    String formattedString = '';
    if (days > 0) formattedString += '$days day(s) ';
    if (hours > 0) formattedString += '$hours hr(s) ';
    if (minutes > 0) formattedString += '$minutes min(s)';

    return formattedString.trim();
  }

  finishJobDialog(String title, String msg, BuildContext context,
      Widget? backPage, PartnerCalendarItem jobitem) {
    /////////----------
    print("booked data${jobitem.bookingServiceItem?.actualStartDateTime}");
    try {
      String hr = DateTime.parse('${jobitem.serviceDate}').hour.toString();
      if (hr.length < 2) hr = '0$hr';
      String endHr;
      String endMin;
      String min = DateTime.parse('${jobitem.serviceDate}').minute.toString();
      if (min.length < 2) min = '0$min';
      endMin = min;
      endHr = '${DateTime.parse('${jobitem.serviceDate}').hour + 1}';
      if (endHr.toString().length < 2) endHr = '0$endHr';
      var diff = DateTime.now().difference(
          jobitem.bookingServiceItem?.actualStartDateTime == null
              ? jobitem.bookingServiceItem!.startDateTime!
              : jobitem.bookingServiceItem!.actualStartDateTime!);

      // int jobdurationHrs = (diff.inHours % 24).abs();
      // int jobdurationDays = diff.inDays.abs();
      /////////----------
      // print("opening  $diff $jobdurationDays $jobdurationHrs");
      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (c, d) {
          return AlertDialog(
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
                      _finishComments.clear();
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
                  // Start job date time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date & Time',
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        '${jobitem.serviceDate!.day.toString().padLeft(2, '0')}-${jobitem.serviceDate!.month.toString().padLeft(2, '0')}-${jobitem.serviceDate!.year} | ${hr.padLeft(2, '0')}:${min.padLeft(2, '0')} - ${endHr.padLeft(2, '0')}:${endMin.padLeft(2, '0')}',
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(1),
                          // fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //End job date time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date & Time',
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year} | ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(1),
                          // fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //End job date time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Duration',
                        style: TextStyle(
                          color: zimkeyDarkGrey.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Wrap(
                        children: [
                          Text(
                            formatDuration(diff),
                            style: TextStyle(
                              color: zimkeyDarkGrey.withOpacity(1),
                              // fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: zimkeyLightGrey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    // width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(
                              color: zimkeyDarkGrey,
                              // fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLength: 300,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.characters,
                            controller: _finishComments,
                            decoration: InputDecoration(
                              counterText: '',
                              fillColor: zimkeyOrange,
                              border: InputBorder.none,
                              hintText: 'Any comments or feedback',
                              hintStyle: TextStyle(
                                color: zimkeyDarkGrey.withOpacity(0.7),
                                // fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onChanged: (value) {
                              if (_finishComments.text.isNotEmpty)
                                setState(() {
                                  showClearIcon = true;
                                });
                              else
                                setState(() {
                                  showClearIcon = false;
                                });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        if (showClearIcon)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _finishComments.clear();
                                showClearIcon = false;
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: zimkeyDarkGrey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  isLoading
                      ? SizedBox(
                          width: 50,
                          height: 50,
                        )
                      : InkWell(
                          onTap: () async {
                            Get.back();
                            // if (_finishComments.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });
                            QueryResult finishJobResult =
                                await finishJobMutation(
                                    jobitem.bookingServiceItem!.id, i!);
                            setState(() {
                              isLoading = false;
                            });

                            if (finishJobResult != null &&
                                finishJobResult.data != null &&
                                finishJobResult.data!['finishJob'] != null) {
                              print('finish job success!!!!!');
                              try {
                                widget.refetchJobs!();
                              } catch (e) {}

                              showCustomDialog(
                                  'Done!',
                                  'You have successfully completed your Zimkey job in ${formatDuration(diff)} . All your completed jobs will be available under "Completed" tab.',
                                  context,
                                  Dashboard(
                                    index: 2,
                                    tabIndex: 2,
                                  ));
                            }
                            if (finishJobResult.hasException) {
                              if (finishJobResult.exception!.graphqlErrors !=
                                      null &&
                                  finishJobResult
                                      .exception!.graphqlErrors.isNotEmpty)
                                showCustomDialog(
                                    'Oops',
                                    '${finishJobResult.exception!.graphqlErrors.first.message}',
                                    context,
                                    null);

                              if (finishJobResult.exception!.linkException !=
                                  null)
                                showCustomDialog(
                                    'Oops',
                                    '${finishJobResult.exception!.linkException.toString()}',
                                    context,
                                    null);
                            }
                            // }
                          },
                          child: Center(
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width / 2,
                              padding: EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 10),
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
                              child: const Text(
                                'Finish',
                                style: TextStyle(
                                  color: zimkeyWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  startJobDialog(String title, String msg, BuildContext context,
      Widget? backPage, PartnerCalendarItem? jobitem) {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, state) {
              debugPrint(
                  'Work Code - ${jobitem!.bookingServiceItem!.workCode} (For testing only)');
              return AlertDialog(
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
                  padding: EdgeInsets.only(left: 20, right: 20, top: 15),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$msg',
                        style: TextStyle(
                          color: zimkeyDarkGrey,
                          fontSize: 14,
                        ),
                      ),
                      // Text(
                      //   'Work Code - ${jobitem!.bookingServiceItem!.workCode} (For testing only)',
                      //   style: TextStyle(
                      //     color: zimkeyOrange,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: zimkeyLightGrey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 0, bottom: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/newIcons/privacy.svg',
                              color: zimkeyDarkGrey,
                              width: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color: zimkeyDarkGrey,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLength: 4,
                                textCapitalization:
                                    TextCapitalization.characters,
                                controller: _workCode,
                                decoration: InputDecoration(
                                  counterText: '',
                                  fillColor: zimkeyOrange,
                                  border: InputBorder.none,
                                  hintText: 'Enter job verification code',
                                  hintStyle: TextStyle(
                                    color: zimkeyDarkGrey.withOpacity(0.7),
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (_workCode.text.isNotEmpty)
                                    setState(() {
                                      showClearIcon = true;
                                    });
                                  else
                                    setState(() {
                                      showClearIcon = false;
                                    });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            if (showClearIcon)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _workCode.clear();
                                    showClearIcon = false;
                                  });
                                },
                                child: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: zimkeyDarkGrey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : InkWell(
                              onTap: () => startJobFun(jobitem!),
                              child: Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width / 2,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 13, horizontal: 10),
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
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: zimkeyWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            }));
  }

  jobOfferDialog(
      String title, String msg, BuildContext context, Function function) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                padding: EdgeInsets.only(left: 20, right: 20, top: 15),
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
                      style: TextStyle(
                        color: zimkeyDarkGrey,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: zimkeyOrange,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            onPressed: () => function(),
                            child: Text(title)),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  reworkJobDialog(String title, String msg, BuildContext context,
      Widget? backPage, PartnerCalendarItem? jobitem, bool sts) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
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
                padding: EdgeInsets.only(left: 20, right: 20, top: 15),
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
              content: StatefulBuilder(builder: (c, d) {
                return Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$msg',
                        style: TextStyle(
                          color: zimkeyDarkGrey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : InkWell(
                              onTap: () async {
                                // Future.delayed(Duration(milliseconds: 100), () {
                                Get.back();
                                // });

                                print("resilt strt");
                                setState(() {
                                  isLoading = true;
                                });
                                QueryResult startJobResult =
                                    await reworkMutation(
                                  jobitem?.bookingServiceItem?.id ?? "",
                                  true,
                                );
                                print("resilt");
                                print(startJobResult);
                                setState(() {
                                  isLoading = false;
                                });

                                if (startJobResult.data != null) {
                                  print('start job success!!!!!');
                                  showCustomDialog(
                                    'Yay!',
                                    'Your job has ${sts ? 'Accepted' : 'Rejected'} successfully.',
                                    context,
                                    Dashboard(
                                      index: 2,
                                      tabIndex: 0,
                                    ),
                                  );
                                }
                                if (startJobResult.hasException) {
                                  if (startJobResult
                                      .exception!.graphqlErrors.isNotEmpty)
                                    showCustomDialog(
                                        'Oops',
                                        '${startJobResult.exception!.graphqlErrors.first.message}',
                                        context,
                                        null);

                                  if (startJobResult.exception!.linkException !=
                                      null)
                                    showCustomDialog(
                                        'Oops',
                                        '${startJobResult.exception!.linkException.toString()}',
                                        context,
                                        null);
                                }
                              },
                              child: Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width / 2,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 13, horizontal: 10),
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
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: zimkeyWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              }),
            ));
  }
}

class GetTeamsWidget extends StatefulWidget {
  final Function(List<String>) onTap;
  final List<String>? selectedTeams;
  final DateTime jobDate;

  const GetTeamsWidget(
      {super.key,
      required this.onTap,
      this.selectedTeams,
      required this.jobDate});

  @override
  State<GetTeamsWidget> createState() => _GetTeamsWidgetState();
}

class _GetTeamsWidgetState extends State<GetTeamsWidget> {
  ValueNotifier<List<String>> teamIds = ValueNotifier([]);

  @override
  void initState() {
    teamIds.value.addAll(widget.selectedTeams ?? []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql("""
            query GetTeams(\$pageNumber: Int, \$pageSize: Int,\$jobDate:DateTime) {
              getTeams(
                filters: {}
                jobDate:\$jobDate
                pagination: { pageNumber: \$pageNumber, pageSize: \$pageSize }
              ) {
                data {
                  id
                  uid
                  name
                  partnerId
                  strength
                  members {
                    id
                    name
                    uid
                    phone
                    rank
                    isActive
                  }
                  isActive
                  partner {
                    id
                    name
                    email
                    phone
                    dob
                    gender
                    uid
                  }
                }
              }
            }
          """),
        variables: {
          'pageNumber': 1,
          'pageSize': 20,
          'jobDate': widget.jobDate.toIso8601String()
        }, // Adjust values as needed
      ),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          print(result.exception);
        }

        if (result.isLoading) {
          return SizedBox(
              width: 20,
              height: 20,
              child: Center(child: CircularProgressIndicator()));
        }

        final List<TeamModel> teams = List<TeamModel>.from(
            result.data?['getTeams']['data'].map((x) => TeamModel.fromJson(x)));

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              // fetchMore!(FetchMoreOptions(
              //   variables: {
              //     'pageSize': 10,
              //     'pageNumber':
              //         result.data!['getTeams']['data'].length ~/ 10 + 1,
              //   },
              //   updateQuery: (previousResultData, fetchMoreResultData) {
              //     // Update the existing data with new data
              //     final List<dynamic> newData =
              //         fetchMoreResultData!['getTeams']['data'];
              //     return {
              //       'getTeams': {
              //         'data': [...newData]
              //       }
              //     };
              //   },
              // ));
            }
            return false;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Select Team.",
                  style: TextStyle(
                    color: zimkeyBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: teamIds,
                    builder: (context, data, child) {
                      return ListView.builder(
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];

                          // Build your ListTile or custom widget here
                          return Column(
                            children: [
                              ListTile(
                                title: Text(team.name),
                                trailing: data.contains(team.id)
                                    ? OutlinedButton(
                                        onPressed: () {
                                          if (data.contains(team.id)) {
                                            teamIds.value.remove(team.id);
                                          } else {
                                            teamIds.value.add(team.id);
                                          }
                                          teamIds.notifyListeners();
                                        },
                                        child: Text("DeSelect"),
                                        style: OutlinedButton.styleFrom(),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: zimkeyOrange,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15))),
                                        onPressed: () {
                                          if (data.contains(team.id)) {
                                            teamIds.value.remove(team.id);
                                          } else {
                                            teamIds.value.add(team.id);
                                          }
                                          teamIds.notifyListeners();
                                        },
                                        child: Text("Select"),
                                      ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Total Members : ${team.strength}"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 35,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: team.members.length,
                                          itemBuilder: (context, index) =>
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Center(
                                                    child: Text(
                                                  team.members[index].name,
                                                  style: TextStyle(
                                                      color: zimkeyOrange),
                                                )),
                                              )),
                                    )
                                  ],
                                ),
                                // Add more details as needed
                              ),
                              Divider()
                            ],
                          );
                        },
                      );
                    }),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: zimkeyOrange),
                      onPressed: () {
                        if (teamIds.value.isEmpty) {
                          Get.snackbar(
                              "Error", "Please select at-least one team",
                              backgroundColor: Colors.black,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM);
                        } else {
                          Future.delayed(Duration(milliseconds: 100), () {
                            Navigator.pop(context);
                          });

                          widget.onTap(teamIds.value);
                        }
                      },
                      child: Text("Done")))
            ],
          ),
        );
      },
    );
  }
}
