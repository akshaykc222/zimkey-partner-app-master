import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../bookings/jobsCalendar.dart';
import '../fbState.dart';
import '../jobBoard/jobBoard.dart';
import '../models/partnerModel.dart';
import '../models/serviceModel.dart';
import '../notification.dart';
import '../profile/profile.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';
import 'homePage.dart';

class Dashboard extends StatefulWidget {
  final int? index;
  final int? tabIndex;

  const Dashboard({
    Key? key,
    this.index,
    this.tabIndex,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ValueNotifier<int> _currentIndex = ValueNotifier(0);
  bool showSearch = false;
  final FbState fbState = Get.find();
  PartnerUser? userDetails;
  bool isPartnerAuthorized = false;
  String? partnerUserType;
  List<String?> partnerServiceAreas = [];
  List<String?> partnerServices = [];
  bool loading = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  void onTabTapped(int index) {
    print('currentindex $index');
    _currentIndex.value = index;
    _currentIndex.notifyListeners();
  }

  @override
  void initState() {
    _currentIndex.value = widget.index ?? 0;
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      NotificationService.handleNavigation(event, context, () {});
    });

    super.initState();
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: zimkeyOrange,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Query(
            options: QueryOptions(
                document: gql(getMe), fetchPolicy: FetchPolicy.noCache),
            builder: (
              QueryResult result, {
              VoidCallback? refetch,
              FetchMore? fetchMore,
            }) {
              if (result.isLoading)
                return Center(child: sharedLoadingIndicator());
              else if (result.data != null && result.data!['me'] != null) {
                PartnerUser tempUser;
                tempUser = PartnerUser.fromJson(result.data!['me']);
                userDetails = tempUser;
                fbState.setPartnerUser(userDetails);
                if (userDetails!.partnerDetails != null) {
                  //Set Service areas
                  if (userDetails!.partnerDetails!.serviceAreas != null &&
                      userDetails!.partnerDetails!.serviceAreas!.isNotEmpty) {
                    partnerServiceAreas.clear();
                    for (Area itemArea
                        in userDetails!.partnerDetails!.serviceAreas!) {
                      partnerServiceAreas.add(itemArea.id);
                    }
                  }
                  //Set Partner Services
                  if (userDetails!.partnerDetails!.services != null &&
                      userDetails!.partnerDetails!.services!.isNotEmpty) {
                    partnerServices.clear();
                    for (AllServices serv
                        in userDetails!.partnerDetails!.services!) {
                      partnerServices.add(serv.id);
                    }
                  }
                }
                //set to check partner status
                partnerUserType = userDetails!.userType;
                if (partnerUserType != null &&
                    partnerUserType == 'PENDING_PARTNER')
                  isPartnerAuthorized = false;
                else if (partnerUserType != null &&
                    partnerUserType == 'PARTNER') isPartnerAuthorized = true;
              } else if (result.hasException) {
                print(result.exception);
              }
              print(
                  'item data : ${userDetails?.partnerDetails?.disableAccount == false} autherized ${isPartnerAuthorized}');
              if (isPartnerAuthorized &&
                  (userDetails?.partnerDetails?.disableAccount == false))
                return ValueListenableBuilder(
                    valueListenable: _currentIndex,
                    builder: (context, data, child) {
                      return IndexedStack(
                        sizing: StackFit.expand,
                        index: data,
                        children: [
                          Home(
                            updateTab: onTabTapped,
                          ),
                          JobBoardPage(
                            updateTab: onTabTapped,
                          ),
                          JobsCalendar(
                            updateTab: onTabTapped,
                            pos: widget.tabIndex,
                          ),
                          Profile(),
                        ],
                      );
                    });
              else if (userDetails?.partnerDetails?.disableAccount == true)
                return disableAccount();
              else
                return pendingStatusWidegt();
            }),
        bottomNavigationBar: customBottomNav(),
      ),
    );
  }

  Widget pendingStatusWidegt() {
    return Center(
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height / 1,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
          color: zimkeyBodyOrange.withOpacity(0.2),
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
              'Admin Approval Pending!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'You have not yet been approved.\n Kindly wait for your confirmation by the Zimkey team.',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            if (fbState.isLoggedIn.value == "true" ||
                fbState.isLoggedIn.isEmpty)
              GestureDetector(
                onTap: () async {
                  setState(() {
                    loading = true;
                  });
                  fbState.setUserLoggedIn('false');
                  fbState.setToken('');
                  await auth.signOut().then((value) {
                    setState(() {
                      loading = false;
                    });
                  });
                  //unregister devide ID
                  if (fbState.deviceId != null &&
                      fbState.deviceId.value != null) {
                    await unsetFCMToken(context, fbState.deviceId.value);
                  }
                  print('Logged out!!!!!!');
                  Get.toNamed('/login');
                },
                child: Text(
                  'Signout',
                  style: TextStyle(
                    fontSize: 15,
                    color: zimkeyOrange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget disableAccount() {
    return Center(
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height / 1,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
          color: zimkeyBodyOrange.withOpacity(0.2),
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
              'Account has been disabled by the zimkey team!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Your account has been disabled by the zimkey team.if any queries please contact us',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            if (fbState.isLoggedIn.value == "true" ||
                fbState.isLoggedIn.isEmpty)
              GestureDetector(
                onTap: () async {
                  setState(() {
                    loading = true;
                  });
                  fbState.setUserLoggedIn('false');
                  fbState.setToken('');
                  await auth.signOut().then((value) {
                    setState(() {
                      loading = false;
                    });
                  });
                  //unregister devide ID
                  if (fbState.deviceId != null &&
                      fbState.deviceId.value != null) {
                    await unsetFCMToken(context, fbState.deviceId.value);
                  }
                  print('Logged out!!!!!!');
                  Get.toNamed('/login');
                },
                child: Text(
                  'Signout',
                  style: TextStyle(
                    fontSize: 15,
                    color: zimkeyOrange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget customBottomNav() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: zimkeyBottomnavGrey,
        boxShadow: [
          new BoxShadow(
            color: zimkeyLightGrey,
            offset: new Offset(2.0, -3.0),
            blurRadius: 5.0,
          )
        ],
      ),
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bottomNavButton(
            // 'assets/images/icons/newIcons/logoNoFill.svg',
            'assets/images/icons/newIcons/logo.svg',
            0,
          ),
          bottomNavButton(
            'assets/images/icons/newIcons/jobCalendar.svg',
            1,
          ),
          bottomNavButton(
            'assets/images/icons/newIcons/bookings.svg',
            2,
          ),
          bottomNavButton(
            'assets/images/icons/newIcons/profile.svg',
            3,
          ),
        ],
      ),
    );
    // else
    //   return Container(
    //     height: 0,
    //     width: double.infinity,
    //   );
  }

  Widget bottomNavButton(String icon, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        style: flatButtonStyle,
        onPressed: () {
          _currentIndex.value = index;
          _currentIndex.notifyListeners();
        },
        child: ValueListenableBuilder(
            valueListenable: _currentIndex,
            builder: (context, data, child) {
              return SvgPicture.asset(
                icon,
                height: index == 0 ? 29 : 24,
                color: data == index ? zimkeyOrange : zimkeyDarkGrey,
              );
            }),
      ),
    );
  }
}
