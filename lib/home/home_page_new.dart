import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import '../fbState.dart';
import '../models/jobModel.dart';
import '../models/partnerModel.dart';
import '../models/serviceModel.dart';
import '../profile/walletHistory.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';
import 'dashboard.dart';
import 'homePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? currentPageValue = 0.0;
  double? fav_index = 0.0;
  double? banner_index = 0.0;
  bool isloading = false;
  // Outside build method
  PageController controller = PageController();
  PersistentBottomSheetController? _controller;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  List<String> projectStages = [
    'Requested',
    'Accepted',
    'Ongoing',
    'Completed'
  ];
  double taskStage = 2;
  List<HomeWidget> homeWidgetList = [];

  OverlayEntry? overlayEntry;
  bool showpincodeError = false;

  PageController fav_controller = PageController(
    initialPage: 0,
    viewportFraction: 1.0,
  );
  PageController grid_controller = PageController(
    initialPage: 0,
    viewportFraction: 1.0,
  );
  PageController banner_controller = PageController();
  final FbState fbState = Get.find();
  bool showSearch = false;

  Area selectedArea = Area();
  VoidCallback? _showPersistantBottomSheetCallBack;
  NumberFormat? format;

  PartnerUser? userDetails;
  List<String?> partnerServiceAreas = [];
  List<String?> partnerServices = [];

  List<PartnerCalendarItem> jobsCalendar = [];
  String? jobStatus;

  int completedJobs = 0;
  int inProgressJobs = 0;
  int cancelledJobs = 0;
  int pendingJobs = 0;
  int assignedJobs = 0;
  bool isPartnerAuthorized = false;
  String? partnerUserType;

  getDashboardDeatils() {
    // OPEN,
    // PARTNER_ASSIGNED,
    // PARTNER_APPROVAL_PENDING,
    // CUSTOMER_APPROVAL_PENDING,
    // PAYMENT_PENDING,
    // IN_PROGRESS,
    // CLOSED,
    // CANCELED

    //     enum PartnerCalendarStatusTypeEnum {
//   OPEN,
//   CANCELED_PARTNER,
//   CANCELED_CUSTOMER,
//   RESCHEDULED_PARTNER,
//   RESCHEDULED_CUSTOMER,
//   ADMIN_REASSIGNED,
//   DONE
// }
    for (PartnerCalendarItem jobitem in jobsCalendar) {
      jobStatus =
          jobitem.bookingServiceItem!.bookingServiceItemStatus.toString();
      if (jobStatus != null && jobStatus != 'null') {
        jobStatus = jobStatus!.split('.')[1];
        jobStatus = jobStatus!.toLowerCase();
      }
      switch (jobStatus) {
        case 'open':
          {
            if (jobitem.partnerCalendarStatus
                .toString()
                .toLowerCase()
                .contains('cancel'))
              cancelledJobs++;
            else
              inProgressJobs++;
            taskStage = 0;
            break;
          }
        case 'partner_assigned':
          {
            if (jobitem.partnerCalendarStatus
                .toString()
                .toLowerCase()
                .contains('cancel'))
              cancelledJobs++;
            else
              assignedJobs++;
            taskStage = 1;
            break;
          }
        case 'partner_approval_pending':
          {
            taskStage = 2;
            pendingJobs++;
            break;
          }
        case 'customer_approval_pending':
          {
            taskStage = 2;
            pendingJobs++;
            break;
          }
        case 'payment_pending':
          {
            taskStage = 2;
            pendingJobs++;
            break;
          }
        case 'in_progress':
          {
            taskStage = 2;
            inProgressJobs++;
            break;
          }
        case 'closed':
          {
            taskStage = 3;
            completedJobs++;
            break;
          }
        case 'CANCELED':
          {
            taskStage = 3;
            cancelledJobs++;
            break;
          }
      }
    }
    //home widget data init---------------
  }

  @override
  void initState() {
    homeWidgetList.add(HomeWidget(
      assignedJobs,
      'Assigned Jobs',
      'assets/images/icons/newIcons/pending.svg',
      false,
      Dashboard(
        index: 2,
      ),
    ));
    homeWidgetList.add(HomeWidget(
      completedJobs,
      'Completed',
      'assets/images/icons/newIcons/completed.svg',
      false,
      Dashboard(
        index: 2,
      ),
    ));
    homeWidgetList.add(HomeWidget(
      inProgressJobs,
      'In Progress Jobs',
      'assets/images/icons/newIcons/rework.svg',
      false,
      Dashboard(
        index: 2,
      ),
    ));
    homeWidgetList.add(HomeWidget(
      userDetails != null &&
              userDetails!.partnerDetails != null &&
              userDetails!.partnerDetails!.walletBalance != null &&
              userDetails!.partnerDetails!.walletBalance! > 0
          ? userDetails!.partnerDetails!.walletBalance
          : 0,
      'Wallet Balance',
      'assets/images/icons/rupee.svg',
      true,
      WalletHistory(),
    ));
    homeWidgetList.add(HomeWidget(
      pendingJobs,
      'Pending Jobs',
      'assets/images/icons/newIcons/pending.svg',
      false,
      Dashboard(
        index: 2,
      ),
    ));

    homeWidgetList.add(HomeWidget(
      cancelledJobs,
      'Cancelled Jobs',
      'assets/images/icons/newIcons/cancelled.svg',
      false,
      Dashboard(
        index: 2,
      ),
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: zimkeyWhite,
            body: Container(
              child: Stack(
                children: [
                  Query(
                      options: QueryOptions(
                        document: gql(getMe),
                        fetchPolicy: FetchPolicy.noCache,
                      ),
                      builder: (
                        QueryResult result, {
                        VoidCallback? refetch,
                        FetchMore? fetchMore,
                      }) {
                        if (result.isLoading)
                          return Center(child: sharedLoadingIndicator());
                        else if (result.data != null &&
                            result.data!['me'] != null) {
                          PartnerUser tempUser;
                          tempUser = PartnerUser.fromJson(result.data!['me']);
                          userDetails = tempUser;
                          fbState.setPartnerUser(userDetails);
                          if (userDetails!.partnerDetails != null) {
                            //Set Service areas
                            if (userDetails!.partnerDetails!.serviceAreas !=
                                    null &&
                                userDetails!
                                    .partnerDetails!.serviceAreas!.isNotEmpty) {
                              partnerServiceAreas.clear();
                              for (Area itemArea in userDetails!
                                  .partnerDetails!.serviceAreas!) {
                                partnerServiceAreas.add(itemArea.id);
                              }
                            }
                            //Set Partner Services
                            if (userDetails!.partnerDetails!.services != null &&
                                userDetails!
                                    .partnerDetails!.services!.isNotEmpty) {
                              partnerServices.clear();
                              for (AllServices serv
                                  in userDetails!.partnerDetails!.services!) {
                                partnerServices.add(serv.id);
                              }
                            }
                          }
                          //set to check partner status
                          partnerUserType = userDetails!.userType;
                          getCMSContentMutation();
                        } else if (result.hasException) {
                          print(result.exception);
                        }
                        return Query(
                            options: QueryOptions(
                              document: gql(getPartnerCalendar),
                              variables: {
                                "pageSize": 20,
                                "pageNumber": 1,
                              },
                              fetchPolicy: FetchPolicy.noCache,
                            ),
                            builder: (
                              QueryResult result2, {
                              VoidCallback? refetch,
                              FetchMore? fetchMore,
                            }) {
                              if (result2.isLoading)
                                return Center(child: sharedLoadingIndicator());
                              else if (result2.data != null &&
                                  result2.data!['getPartnerCalendarItems'] !=
                                      null) {
                                jobsCalendar.clear();
                                for (Map item in result2
                                    .data!['getPartnerCalendarItems']['data']) {
                                  PartnerCalendarItem temp;
                                  temp = PartnerCalendarItem.fromJson(
                                      item as Map<String, dynamic>);
                                  jobsCalendar.add(temp);
                                }
                                // filterOpenJobs();
                                completedJobs = 0;
                                inProgressJobs = 0;
                                cancelledJobs = 0;
                                pendingJobs = 0;
                                assignedJobs = 0;
                                homeWidgetList.clear();

                                fbState.setJobCalendarList(jobsCalendar);
                              } else if (result2.hasException) {
                                print('partner calendar EXCEPTION $result2!!');
                              }
                              return Container(
                                child: Column(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                1.5,
                                        minHeight:
                                            MediaQuery.of(context).size.height -
                                                300,
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              1.24,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          if (fbState.partnerUser != null &&
                                              fbState.partnerUser.value !=
                                                  null &&
                                              fbState.partnerUser.value!.name !=
                                                  null)
                                            Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 7),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    'Hey, ${fbState.partnerUser.value!.name}!',
                                                    style: TextStyle(
                                                      color: zimkeyDarkGrey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          // //show only those accepted
                                          // for (PartnerCalendarItem item
                                          //     in jobsCalendar)
                                          //   //Booking Detail Widget
                                          //   if (item.bookingServiceItem
                                          //           .bookingServiceItemStatus
                                          //           .toString() !=
                                          //       'BookingServiceItemStatusTypeEnum.OPEN')
                                          //     incomingBookingWidget(item),
                                          SizedBox(
                                            height: 0,
                                          ),
                                          Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 15),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: 10,
                                                runSpacing: 15,
                                                children: [
                                                  for (HomeWidget item
                                                      in homeWidgetList)
                                                    InkWell(
                                                      onTap: () =>
                                                          Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              item.targetPage,
                                                        ),
                                                      ),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 25),
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            25,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: zimkeyWhite,
                                                          border: Border.all(
                                                            color:
                                                                zimkeyBodyOrange,
                                                          ),
                                                          boxShadow: [
                                                            new BoxShadow(
                                                              color: zimkeyDarkGrey
                                                                  .withOpacity(
                                                                      0.2),
                                                              offset:
                                                                  new Offset(
                                                                      1.0, 3.0),
                                                              blurRadius: 5.0,
                                                            )
                                                          ],
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              '${item.icon}',
                                                              color:
                                                                  zimkeyOrange,
                                                              height: 30,
                                                            ),
                                                            SizedBox(width: 5),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Wrap(
                                                                  children: [
                                                                    if (item
                                                                        .isCurrency)
                                                                      Text(
                                                                        '₹',
                                                                        style: TextStyle(
                                                                            fontSize: 24,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            color: zimkeyDarkGrey.withOpacity(0.9)),
                                                                      ),
                                                                    Text(
                                                                      '${item.value}',
                                                                      style: TextStyle(
                                                                          fontSize: 26,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          color: zimkeyDarkGrey.withOpacity(0.9)),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 3,
                                                                ),
                                                                AutoSizeText(
                                                                  '${item.status}',
                                                                  minFontSize:
                                                                      12,
                                                                  maxFontSize:
                                                                      14,
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      color: zimkeyDarkGrey),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      }),
                ],
              ),
            ),
          ),
          if (isloading) Center(child: sharedLoadingIndicator()),
        ],
      ),
      // }),
    );
  }
}
