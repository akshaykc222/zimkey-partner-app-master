import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:instant/instant.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:recase/recase.dart';
import 'package:zimkey_partner_app/jobBoard/models/job_board_model.dart';

import '../bookings/jobCalendarDetail.dart';
import '../fbState.dart';
import '../models/jobModel.dart';
import '../models/serviceModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';

class JobBoardPage extends StatefulWidget {
  final void Function(int index)? updateTab;

  JobBoardPage({Key? key, this.updateTab}) : super(key: key);

  @override
  _JobBoardState createState() => _JobBoardState();
}

class _JobBoardState extends State<JobBoardPage> with WidgetsBindingObserver {
  final FbState fbState = Get.find();
  bool showExpansion = false;
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<List<JobBoardNewModel>> jobBordList = ValueNotifier([]);
  Function? refetchlist;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    jobBordList.value.clear();
    await refetchlist!();
    jobBordList.notifyListeners();
    // setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  FetchMore? fetchMoreData;
  bool hasNextPage = false;
  int totalPage = 1;

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  int pageNo = 1;
  ScrollController scrollController = ScrollController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      refetchlist!();
    }
  }

  @override
  void initState() {
    // FirebaseMessaging.onMessage.listen((event) async {
    //   print("tyyttt" + event.data.toString());
    //   if (refetchlist != null) {
    //     await refetchlist!();
    //     await refetchlist!();
    //   }
    // });
    print("init state is calling");
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (totalPage > pageNo) {
          pageNo++;
          fetchMoreData!(FetchMoreOptions(
            variables: {
              'pageSize': 10,
              'pageNumber': pageNo,
            },
            updateQuery: (previousResultData, fetchMoreResultData) {
              // Update the existing data with new data
              final List<dynamic> newData =
                  fetchMoreResultData!['getJobBoard']['data'];
              return {
                'getJobBoard': {
                  'data': [...newData]
                }
              };
            },
          ));
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    jobBordList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Job Board',
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
        body: ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (context, data, child) {
              return data
                  ? Center(
                      child: sharedLoadingIndicator(),
                    )
                  : Query(
                      options: QueryOptions(
                          document: gql(getJobBoard),
                          variables: {
                            "pageSize": 20,
                            "pageNumber": pageNo,
                          },
                          fetchPolicy: FetchPolicy.noCache),
                      builder: (
                        QueryResult result2, {
                        VoidCallback? refetch,
                        FetchMore? fetchMore,
                      }) {
                        print(
                            " $pageNo job board result ${result2.data?['getJobBoard']['pageInfo']}");
                        refetchlist = refetch;
                        fetchMoreData = fetchMore;
                        if (result2.data != null &&
                            result2.data!['getJobBoard'] != null &&
                            result2.data!['getJobBoard']['data'] != null) {
                          // jobBordList.clear();

                          jobBordList.value.addAll(List<JobBoardNewModel>.from(
                              result2.data!['getJobBoard']['data']
                                  .map((x) => JobBoardNewModel.fromJson(x))));
                          jobBordList.value =
                              jobBordList.value.toSet().toList();
                          if (result2.data?['getJobBoard']['pageInfo'] !=
                              null) {
                            // pageNo = result2.data!['getJobBoard']['pageInfo']
                            //     ['currentPage'];
                            hasNextPage = result2.data!['getJobBoard']
                                ['pageInfo']['hasNextPage'];
                            totalPage = result2.data!['getJobBoard']['pageInfo']
                                ['totalPage'];
                          }
                          debugPrint("hasNextPage :$hasNextPage");
                        } else if (result2.hasException) {
                          print('job get EXCEPTION ${result2.exception}!!');
                        }
                        return ValueListenableBuilder(
                            valueListenable: jobBordList,
                            builder: (context, data, child) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: SmartRefresher(
                                  enablePullDown: true,
                                  footer: ClassicFooter(
                                    loadStyle: LoadStyle.ShowWhenLoading,
                                    completeDuration:
                                        Duration(milliseconds: 500),
                                  ),
                                  header: WaterDropHeader(),
                                  controller: _refreshController,
                                  onRefresh: _onRefresh,
                                  onLoading: _onLoading,
                                  child: pageNo == 1 && result2.isLoading
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : data.isEmpty
                                          ? emptyBookingWidget()
                                          : ListView.builder(
                                              // or use default physics
                                              controller: scrollController,
                                              itemCount: data.length + 1,
                                              physics: BouncingScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return index >= data.length
                                                    ? pageNo < totalPage
                                                        ? Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          )
                                                        : SizedBox()
                                                    : JobItemWidgetNew(
                                                        job: data[index],
                                                        callAssignMutation:
                                                            (List<String>?
                                                                teamId) async {
                                                          // isLoading.value =
                                                          //     true;
                                                          // isLoading
                                                          //     .notifyListeners();

                                                          // isLoading.value =
                                                          //     false;
                                                          // isLoading
                                                          //     .notifyListeners();
                                                        },
                                                        refecth: refetch!,
                                                      );
                                              },
                                            ),
                                ),
                              );
                            });
                      });
            }));
  }

  Widget pendingJobsWidegt() {
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
            'No new job requests yet!',
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
            'No new incoming jobs requests.',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'PULL TO REFRESH',
            style: TextStyle(
              fontSize: 12,
              color: zimkeyOrange.withOpacity(1),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
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

class JobItemWidgetNew extends StatefulWidget {
  final JobBoardNewModel? job;
  final Function refecth;
  final Function(List<String>? teamId)? callAssignMutation;

  const JobItemWidgetNew(
      {super.key, this.job, this.callAssignMutation, required this.refecth});

  @override
  State<JobItemWidgetNew> createState() => _JobItemWidgetNewState();
}

class _JobItemWidgetNewState extends State<JobItemWidgetNew> {
  String icon = "";
  String? thisBillingOptionId;
  String? thisBillingOption;
  ValueNotifier<bool> _showLoading = ValueNotifier(false);

  @override
  void initState() {
    // thisBillingOptionId = widget.job?.bookingService?.serviceBillingOptionId;
    // for (BillingOptions options in widget.job?.jobService?.billingOptions?) {
    //   if (options.id == thisBillingOptionId) {
    //     // setState(() {
    //     thisBillingOption = options.name;
    //     // });
    //   }
    // }
    if (widget.job!.bookingService != null &&
        widget.job!.bookingService!.service != null &&
        widget.job!.bookingService!.service!.icon != null) {
      icon = widget.job!.bookingService!.service!.icon != null &&
              widget.job!.bookingService!.service!.icon!.url != null
          ? serviceImg + widget.job!.bookingService!.service!.icon!.url!
          : "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 4, top: 4),
        padding: EdgeInsets.only(bottom: 4, top: 4),
        decoration: BoxDecoration(
          color: zimkeyWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            new BoxShadow(
              color: zimkeyDarkGrey.withOpacity(0.1),
              offset: new Offset(1.0, 3.0),
              blurRadius: 6.0,
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: zimkeyWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  icon == ""
                      ? SvgPicture.asset(
                          'assets/images/icons/img_icon.svg',
                          height: 30,
                          width: 30,
                        )
                      : Image.network(
                          icon,
                          height: 30,
                          width: 30,
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${ReCase(widget.job?.jobService?.name ?? "").titleCase}',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Wrap(
                          children: [
                            // Text(
                            //   '',
                            //   style: TextStyle(
                            //     color: zimkeyDarkGrey,
                            //     fontSize: 12,
                            //   ),
                            // ),
                            // if (billingQty != null)
                            //   Text(
                            //     ' - $billingQty ${billingUnit.toLowerCase()}',
                            //     style: TextStyle(
                            //       color: zimkeyDarkGrey,
                            //       fontSize: 12,
                            //     ),
                            //   ),
                          ],
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Text(
                          widget.job?.jobDate == null
                              ? ""
                              : DateFormat('dd / MM / y HH:mm')
                                  .format(widget.job!.jobDate!),
                          style: TextStyle(
                            color: zimkeyDarkGrey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${widget.job!.jobArea!.name}',
                          style: TextStyle(
                            color: zimkeyDarkGrey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      if (widget.job?.jobService?.isTeamService == true) {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15))),
                            builder: (context) => GetTeamsWidget(
                                  jobDate:
                                      widget.job?.jobDate ?? DateTime.now(),
                                  onTap: (item) async {
                                    // Navigator.pop(context);
                                    _showLoading.value = true;

                                    await assignJobMutation(widget.job?.id,
                                        false, context, item, widget.refecth);

                                    _showLoading.value = false;
                                  },
                                ));
                      } else {
                        _showLoading.value = true;

                        await assignJobMutation(widget.job?.id, false, context,
                            null, widget.refecth);

                        _showLoading.value = false;
                      }
                      //
                    },
                    child: ValueListenableBuilder(
                        valueListenable: _showLoading,
                        builder: (context, data, child) {
                          return data
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 0),
                                  child: Text(
                                    'ACCEPT JOB',
                                    style: TextStyle(
                                      color: zimkeyOrange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                        }),
                  ),
                ],
              ),
            ),
          ],
        )
        // child: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //         color: zimkeyWhite,
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       child: Row(
        //         children: [
        //           Expanded(
        //             child: Container(
        //               child: InkWell(
        //                 onTap: () {
        //                   showJobDetailDialog(
        //                     widget.job!,
        //                     context,
        //                     false,
        //                   );
        //                 },
        //                 child: jobBoardItem(),
        //               ),
        //             ),
        //           ),
        //           SizedBox(
        //             width: 10,
        //           ),
        //           InkWell(
        //             onTap: () async {
        //               widget.callAssignMutation!();
        //             },
        //             child: Container(
        //               padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        //               child: Text(
        //                 'ACCEPT JOB',
        //                 style: TextStyle(
        //                   color: zimkeyOrange,
        //                   fontSize: 12,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        );
  }
}

class JobItemWidget extends StatefulWidget {
  final JobBoard? job;
  final Function? callAssignMutation;
  final bool? isLoading;

  JobItemWidget({
    Key? key,
    this.job,
    this.callAssignMutation,
    this.isLoading,
  }) : super(key: key);

  @override
  _JobItemWidgetState createState() => _JobItemWidgetState();
}

class _JobItemWidgetState extends State<JobItemWidget> {
  bool showExpansion = false;
  String? thisBillingOptionId;
  String? thisBillingOption;
  String? servIcon;
  bool isPng = false;
  late String hr;
  late String min;
  int? billingQty;
  late String billingUnit;

  @override
  void initState() {
    // thisBillingOptionId = widget.job!.bookingService!.serviceBillingOptionId;
    for (BillingOptions options in widget.job!.jobService!.billingOptions!) {
      if (options.id == thisBillingOptionId) {
        // setState(() {
        thisBillingOption = options.name;
        // });
      }
    }
    //service qty
    // if (widget.job != null &&
    //     widget.job!.bookingService != null &&
    //     widget.job!.bookingService!.qty != null)
    //   billingQty = widget.job!.bookingService!.qty;
    // //service Unit
    // if (widget.job != null &&
    //     widget.job!.bookingService != null &&
    //     widget.job!.bookingService!.unit != null) {
    //   billingUnit = widget.job!.bookingService!.unit.toString();
    //   billingUnit = billingUnit.split('.')[1];
    // }
    //service icon
    if (widget.job!.bookingService != null &&
        widget.job!.bookingService!.service != null &&
        widget.job!.bookingService!.service!.icon != null) {
      servIcon = widget.job!.bookingService!.service!.icon != null &&
              widget.job!.bookingService!.service!.icon!.url != null
          ? serviceImg + widget.job!.bookingService!.service!.icon!.url!
          : "";
    }
    //--------------------
    hr = DateTime.parse('${widget.job!.jobDate}').hour.toString();
    if (hr.length == 1) hr = '0$hr';
    min = DateTime.parse('${widget.job!.jobDate}').minute.toString();
    if (min.length == 1) min = '0$min';

    //--------------------
    if (servIcon != null && servIcon!.contains('png')) isPng = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Container(
        margin: EdgeInsets.only(bottom: 10, top: 10),
        decoration: BoxDecoration(
          color: zimkeyWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            new BoxShadow(
              color: zimkeyDarkGrey.withOpacity(0.1),
              offset: new Offset(1.0, 3.0),
              blurRadius: 6.0,
            )
          ],
        ),
        child: Text("ITem"),
        // child: Column(
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //         color: zimkeyWhite,
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       child: Row(
        //         children: [
        //           Expanded(
        //             child: Container(
        //               child: InkWell(
        //                 onTap: () {
        //                   showJobDetailDialog(
        //                     widget.job!,
        //                     context,
        //                     widget.isLoading,
        //                   );
        //                 },
        //                 child: jobBoardItem(),
        //               ),
        //             ),
        //           ),
        //           SizedBox(
        //             width: 10,
        //           ),
        //           InkWell(
        //             onTap: () async {
        //               widget.callAssignMutation!();
        //             },
        //             child: Container(
        //               padding:
        //                   EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        //               child: Text(
        //                 'ACCEPT JOB',
        //                 style: TextStyle(
        //                   color: zimkeyOrange,
        //                   fontSize: 12,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Widget jobBoardItem() {
    String endHr;
    String endMin;
    DateTime jobDate;
    jobDate = dateTimeToZone(zone: "IST", datetime: widget.job!.jobDate!);
    String hr = jobDate.hour.toString();
    if (hr.length < 2) hr = '0$hr';
    String min = jobDate.minute.toString();
    if (min.length < 2) min = '0$min';
    endMin = min;
    endHr = '${jobDate.hour + 1}';
    if (endHr.toString().length < 2) endHr = '0$endHr';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      // width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          servIcon == null || servIcon!.isEmpty
              ? SvgPicture.asset(
                  'assets/images/icons/img_icon.svg',
                  height: 30,
                  width: 30,
                )
              : (isPng)
                  ? Image.network(
                      servIcon!,
                      height: 30,
                      width: 30,
                    )
                  : SvgPicture.network(
                      servIcon!,
                      height: 30,
                      width: 30,
                    ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${ReCase(widget.job!.jobService!.name!).titleCase}',
                  style: TextStyle(
                    color: zimkeyDarkGrey.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Wrap(
                  children: [
                    Text(
                      '${thisBillingOption!.toUpperCase()}',
                      style: TextStyle(
                        color: zimkeyDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                    if (billingQty != null)
                      Text(
                        ' - $billingQty ${billingUnit.toLowerCase()}',
                        style: TextStyle(
                          color: zimkeyDarkGrey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 0,
                ),
                Text(
                  '${DateTime.parse('${widget.job!.jobDate}').day.toString().padLeft(2, '0')}-${DateTime.parse('${widget.job!.jobDate}').month.toString().padLeft(2, '0')}-${DateTime.parse('${widget.job!.jobDate}').year}  $hr:$min - $endHr:$endMin',
                  style: TextStyle(
                    color: zimkeyDarkGrey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 0,
                ),
                Text(
                  '${widget.job!.jobArea!.name}',
                  style: TextStyle(
                    color: zimkeyDarkGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//   showJobDetailDialog(JobBoard job, BuildContext context, bool? isLoading) {
//     String? servIcon;
//     bool isPng = false;
//     String? thisBillingOptionId;
//     String? thisBillingOption;
//     String hr;
//     String min;
// //-----------
//     thisBillingOptionId = job.bookingService!.serviceBillingOptionId;
//     for (BillingOptions options in job.jobService!.billingOptions!) {
//       if (options.id == thisBillingOptionId) {
//         setState(() {
//           thisBillingOption = options.name;
//         });
//       }
//     }
//     //service qty
//     if (widget.job != null &&
//         widget.job!.bookingService != null &&
//         widget.job!.bookingService!.qty != null)
//       billingQty = widget.job!.bookingService!.qty;
//     //service Unit
//     if (widget.job != null &&
//         widget.job!.bookingService != null &&
//         widget.job!.bookingService!.unit != null) {
//       billingUnit = widget.job!.bookingService!.unit.toString();
//       billingUnit = billingUnit.split('.')[1];
//     }
//     //service icon
//     if (job.bookingService != null &&
//         job.bookingService!.service != null &&
//         job.bookingService!.service!.icon != null) {
//       servIcon = job.bookingService!.service!.icon != null &&
//               job.bookingService!.service!.icon!.url != null
//           ? serviceImg + job.bookingService!.service!.icon!.url!
//           : "";
//     }
//     if (servIcon != null && servIcon.contains('png')) isPng = true;
//     //--------------------
//     DateTime jobDate;
//     jobDate = dateTimeToZone(zone: "IST", datetime: job.jobDate!);
//     hr = DateTime.parse('$jobDate').hour.toString();
//     if (hr.length == 1) hr = '0$hr';
//     min = jobDate.minute.toString();
//     if (min.length == 1) min = '0$min';
//     String endHr;
//     String endMin;
//     endMin = min;
//     endHr = '${jobDate.hour + 1}';
//     if (endHr.toString().length < 2) endHr = '0$endHr';
//     //---------
//     String? bookNoteOther;
//     String? bookNoteAdditional;
//     if (job.booking!.bookingNote != null &&
//         job.booking!.bookingNote!.isNotEmpty &&
//         job.booking!.bookingNote!.split(' - ')[1].isNotEmpty)
//       bookNoteOther = job.booking!.bookingNote;
//     if (bookNoteOther != null) {
//       if (bookNoteOther.toLowerCase().contains('service details -'))
//         bookNoteOther =
//             bookNoteOther.toLowerCase().split('other service details - ')[1];
//       bookNoteAdditional = bookNoteOther;
//       if (bookNoteOther.toLowerCase().contains('additional comments -')) {
//         bookNoteOther =
//             bookNoteOther.toLowerCase().split('additional comments - ')[0];
//         bookNoteOther = bookNoteOther.replaceAll('\n', '');
//         bookNoteAdditional =
//             bookNoteAdditional.toLowerCase().split('additional comments - ')[1];
//       }
//     }
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//               backgroundColor: zimkeyWhite,
//               titleTextStyle: TextStyle(
//                 color: zimkeyDarkGrey,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//               contentTextStyle: TextStyle(
//                 color: zimkeyBlack,
//                 fontWeight: FontWeight.normal,
//                 fontSize: 15,
//               ),
//               titlePadding: EdgeInsets.symmetric(
//                 vertical: 0,
//                 horizontal: 0,
//               ),
//               contentPadding: EdgeInsets.only(
//                 bottom: 10,
//                 left: 15,
//                 right: 15,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(10.0),
//                 ),
//               ),
//               title: Container(
//                 padding:
//                     EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     servIcon == null || servIcon.isEmpty
//                         ? SvgPicture.asset(
//                             'assets/images/icons/img_icon.svg',
//                             height: 30,
//                             width: 30,
//                           )
//                         : (isPng)
//                             ? Image.network(
//                                 servIcon,
//                                 height: 30,
//                                 width: 30,
//                               )
//                             : SvgPicture.network(
//                                 servIcon,
//                                 height: 30,
//                                 width: 30,
//                               ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Expanded(
//                       child: Text(
//                         '${ReCase(job.jobService!.name!).titleCase}',
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Get.back();
//                       },
//                       child: Container(
//                         width: 30,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: zimkeyDarkGrey.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.clear,
//                           color: zimkeyDarkGrey,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               content: Container(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     if (thisBillingOption != null &&
//                         thisBillingOption!.isNotEmpty)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Billing Option',
//                             style: TextStyle(
//                               color: zimkeyDarkGrey.withOpacity(0.7),
//                               // fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 3,
//                           ),
//                           Wrap(
//                             children: [
//                               Text(
//                                 '${thisBillingOption!.toUpperCase()}',
//                                 style: TextStyle(
//                                   color: zimkeyDarkGrey,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               if (billingQty != null)
//                                 Text(
//                                   ' - $billingQty ${billingUnit.toLowerCase()}',
//                                   style: TextStyle(
//                                     color: zimkeyDarkGrey,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Booking Date & Time',
//                           style: TextStyle(
//                             color: zimkeyDarkGrey.withOpacity(0.7),
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                           textAlign: TextAlign.right,
//                         ),
//                         SizedBox(
//                           height: 3,
//                         ),
//                         Text(
//                           '${DateTime.parse('${job.jobDate}').day}-${DateTime.parse('${job.jobDate}').month}-${DateTime.parse('${job.jobDate}').year}   $hr:$min - $endHr:$endMin',
//                           style: TextStyle(
//                             color: zimkeyDarkGrey,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     if (job.booking != null &&
//                         job.booking!.bookingAddress != null)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (job.booking!.bookingAddress!.addressType != null)
//                             Text(
//                               '${job.booking!.bookingAddress!.addressType}',
//                               style: TextStyle(
//                                 color: zimkeyDarkGrey.withOpacity(0.7),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                               textAlign: TextAlign.right,
//                             ),
//                           SizedBox(
//                             height: 3,
//                           ),
//                           Wrap(
//                             alignment: WrapAlignment.start,
//                             children: [
//                               if (job.booking!.bookingAddress!.buildingName !=
//                                   null)
//                                 Text(
//                                   '${job.booking!.bookingAddress!.buildingName}, ',
//                                   style: TextStyle(
//                                     color: zimkeyDarkGrey.withOpacity(1),
//                                     // fontWeight: FontWeight.bold,
//                                     fontSize: 13,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               if (job.booking!.bookingAddress!.locality !=
//                                       null &&
//                                   job.booking!.bookingAddress!.locality!
//                                       .isNotEmpty)
//                                 Text(
//                                   '${job.booking!.bookingAddress!.locality}, ',
//                                   style: TextStyle(
//                                     color: zimkeyDarkGrey.withOpacity(1),
//                                     // fontWeight: FontWeight.bold,
//                                     fontSize: 13,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               if (job.booking!.bookingAddress!.landmark !=
//                                       null &&
//                                   job.booking!.bookingAddress!.landmark!
//                                       .isNotEmpty)
//                                 Text(
//                                   '${job.booking!.bookingAddress!.landmark}, ',
//                                   style: TextStyle(
//                                     color: zimkeyDarkGrey.withOpacity(1),
//                                     // fontWeight: FontWeight.bold,
//                                     fontSize: 13,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               if (job.jobArea!.name != null)
//                                 Text(
//                                   '${job.jobArea!.name}, ',
//                                   style: TextStyle(
//                                     color: zimkeyDarkGrey.withOpacity(1),
//                                     // fontWeight: FontWeight.bold,
//                                     fontSize: 13,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                             ],
//                           ),
//                           if (job.booking!.bookingAddress!.postalCode != null)
//                             Text(
//                               '${job.booking!.bookingAddress!.postalCode} - Kochi',
//                               style: TextStyle(
//                                 color: zimkeyDarkGrey.withOpacity(1),
//                                 // fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                               textAlign: TextAlign.right,
//                             ),
//                         ],
//                       ),
//                     if (job.bookingService != null &&
//                         job.bookingService!.serviceRequirements != null &&
//                         job.bookingService!.serviceRequirements!.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               'Booking Options Selected',
//                               style: TextStyle(
//                                 color: zimkeyDarkGrey.withOpacity(0.7),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             SizedBox(
//                               height: 5,
//                             ),
//                             Wrap(
//                               children: [
//                                 for (String requiremnts
//                                     in job.bookingService!.serviceRequirements!)
//                                   Container(
//                                     margin:
//                                         EdgeInsets.only(right: 7, bottom: 5),
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 7, vertical: 3),
//                                     decoration: BoxDecoration(
//                                       color: zimkeyBodyOrange,
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     child: Text(
//                                       '$requiremnts',
//                                       style: TextStyle(
//                                         color: zimkeyDarkGrey.withOpacity(1),
//                                         // fontWeight: FontWeight.bold,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     if (job.booking != null &&
//                         job.booking!.bookingNote != null &&
//                         job.booking!.bookingNote!.isNotEmpty &&
//                         job.booking!.bookingNote!.split(' - ')[1].isNotEmpty)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             'Booking Comments',
//                             style: TextStyle(
//                               color: zimkeyDarkGrey.withOpacity(0.7),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           if (bookNoteOther != null && bookNoteOther.isNotEmpty)
//                             Text(
//                               'Other Details - ${bookNoteOther.titleCase}',
//                               style: TextStyle(
//                                 color: zimkeyDarkGrey.withOpacity(1),
//                                 // fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           if (bookNoteAdditional != null &&
//                               bookNoteAdditional.isNotEmpty)
//                             Text(
//                               'Additional Comments - ${bookNoteAdditional.titleCase}',
//                               style: TextStyle(
//                                 color: zimkeyDarkGrey.withOpacity(1),
//                                 // fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                         ],
//                       ),
//                     SizedBox(height: 20),
//                     Center(
//                       child: InkWell(
//                         onTap: () async {
//                           setState(() {
//                             isLoading = true;
//                           });
//                           Get.back();
//                           await assignJobMutation(job.id, isLoading, context);
//                           setState(() {
//                             isLoading = false;
//                           });
//                         },
//                         child: Container(
//                           margin:
//                               EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                           alignment: Alignment.center,
//                           width: MediaQuery.of(context).size.width - 200,
//                           padding:
//                               EdgeInsets.symmetric(vertical: 13, horizontal: 0),
//                           decoration: BoxDecoration(
//                             color: zimkeyOrange,
//                             borderRadius: BorderRadius.circular(30),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: zimkeyLightGrey.withOpacity(0.1),
//                                 blurRadius: 5.0, // soften the shadow
//                                 spreadRadius: 2.0, //extend the shadow
//                                 offset: Offset(
//                                   1.0, // Move to right 10  horizontally
//                                   1.0, // Move to bottom 10 Vertically
//                                 ),
//                               )
//                             ],
//                           ),
//                           child: Text(
//                             'Accept Job',
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: zimkeyWhite,
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ));
//   }
}
