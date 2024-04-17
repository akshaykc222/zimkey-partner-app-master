import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recase/recase.dart';
import 'package:zimkey_partner_app/shared/webview_page.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/jobModel.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';
import 'customer_support.dart';
import 'editBankAccnt.dart';
import 'editProfile.dart';
import 'updateAreas.dart';
import 'updateAvailability.dart';
import 'updateServices.dart';
import 'walletHistory.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool loading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FbState fbState = Get.find();
  bool? showdilog;
  bool? open;
  PartnerUser? userdetails;
  late String userInitials;
  String? profilepic;

  List<PartnerCalendarItem> jobsCalendar = [];
  String? jobStatus;
  List<Area>? partnerAreas = [];

  int completedJobs = 0;
  int inProgressJobs = 0;
  int cancelledJobs = 0;
  int pendingJobs = 0;
  double totalEarned = 0;
  int assignedJobs = 0;
  bool isPng = false;

  @override
  void initState() {
    if (fbState.partnerUser != null &&
        fbState.partnerUser.value != null &&
        fbState.partnerUser.value!.name != null) {
      userInitials = fbState.partnerUser.value!.name![0].toUpperCase();
      if (fbState.partnerUser.value!.name!.contains(' ')) {
        String? lastName;
        if (fbState.partnerUser.value!.name!.split(' ')[1] != null &&
            fbState.partnerUser.value!.name!.split(' ')[1].isNotEmpty &&
            fbState.partnerUser.value!.name!.split(' ')[1][0] != null)
          lastName = fbState.partnerUser.value!.name!.split(' ')[1][0];
        if (lastName != null && lastName.isNotEmpty)
          userInitials = userInitials + '' + lastName.toUpperCase();
      }
    }
    getCMSContentMutation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: zimkeyWhite,
            elevation: 0,
            centerTitle: false,
            title: Text(
              'Profile',
              style: TextStyle(
                // fontSize: 24,
                fontWeight: FontWeight.bold,
                color: zimkeyDarkGrey,
              ),
            ),
          ),
          body: Query(
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
                else if (result.isNotLoading &&
                    result.data != null &&
                    result.data!['me'] != null) {
                  PartnerUser temp;
                  temp = PartnerUser.fromJson(result.data!['me']);
                  userdetails = temp;
                  fbState.setPartnerUser(temp);
                  open = userdetails!.partnerDetails!.isAvailable;
                  //User Profile pic----------
                  if (userdetails != null &&
                      userdetails!.partnerDetails != null &&
                      userdetails!.partnerDetails!.photo != null &&
                      userdetails!.partnerDetails!.photo!.url != null) {
                    profilepic =
                        baseImgUrl + userdetails!.partnerDetails!.photo!.url!;
                    if (serviceImg.contains('png')) isPng = true;
                  }
                  if (userdetails != null &&
                      userdetails!.partnerDetails != null &&
                      userdetails!.partnerDetails!.serviceAreas != null)
                    partnerAreas = userdetails!.partnerDetails!.serviceAreas;
                }
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: zimkeyWhite,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      (profilepic != null &&
                                              profilepic!.isNotEmpty)
                                          ? Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: zimkeyLightGrey,
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: new NetworkImage(
                                                      profilepic!),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              alignment: Alignment.center,
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: zimkeyLightGrey,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '$userInitials',
                                                style: TextStyle(
                                                    fontSize: 40,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ReCase(userdetails?.name ?? "")
                                                .titleCase,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          userdetails?.partnerDetails
                                                      ?.isZimkeyPartner ==
                                                  true
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                      color: zimkeyOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    "Zimky Partner",
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            userdetails?.phone ?? "",
                                            style: TextStyle(
                                              fontSize: 12,
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: open == true
                                                    ? zimkeyGreen
                                                        .withOpacity(0.3)
                                                    : zimkeyDarkGrey
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              userdetails != null &&
                                                      userdetails!
                                                              .partnerDetails !=
                                                          null &&
                                                      userdetails!
                                                              .partnerDetails!
                                                              .isAvailable !=
                                                          null &&
                                                      userdetails!
                                                          .partnerDetails!
                                                          .isAvailable!
                                                  ? 'Open'
                                                  : 'Not available',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: open==true
                                                    ? Colors.green[900]
                                                    : zimkeyDarkGrey
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Query(
                                  options: QueryOptions(
                                    document: gql(getDashBoard),
                                    fetchPolicy: FetchPolicy.cacheAndNetwork,
                                  ),
                                  builder: (
                                    QueryResult result, {
                                    VoidCallback? refetch,
                                    FetchMore? fetchMore,
                                  }) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0),
                                      decoration: BoxDecoration(
                                        color: zimkeyGreen.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          overviewTiles(
                                            'Assigned',
                                            result.data!['getPartnerDashboard']
                                                    ['assigned_jobs']
                                                .toString(),
                                            Dashboard(
                                              index: 2,
                                            ),
                                          ),
                                          overviewTiles(
                                            'Pending',
                                            result.data!['getPartnerDashboard']
                                                    ['pending_jobs']
                                                .toString(),
                                            Dashboard(
                                              index: 2,
                                            ),
                                          ),
                                          overviewTiles(
                                            'In - Progress',
                                            result.data!['getPartnerDashboard']
                                                    ['in_progress']
                                                .toString(),
                                            Dashboard(
                                              index: 2,
                                            ),
                                          ),
                                          overviewTiles(
                                            'Completed',
                                            result.data!['getPartnerDashboard']
                                                    ['completed_jobs']
                                                .toString(),
                                            Dashboard(
                                              index: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      await getServiceCategoriesMutation();
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateServices(
                                            fbState: fbState,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: zimkeyWhite,
                                        boxShadow: [
                                          BoxShadow(
                                            color: zimkeyLightGrey
                                                .withOpacity(0.1),
                                            blurRadius:
                                                5.0, // soften the shadow
                                            spreadRadius:
                                                1.0, //extend the shadow
                                            offset: Offset(
                                              2.0, // Move to right 10  horizontally
                                              3.0, // Move to bottom 10 Vertically
                                            ),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        'Update Services',
                                        style: TextStyle(
                                          color: zimkeyDarkGrey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateServiceAreas(
                                            fbState: fbState,
                                            partnerAreas: partnerAreas,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: zimkeyWhite,
                                        boxShadow: [
                                          BoxShadow(
                                            color: zimkeyLightGrey
                                                .withOpacity(0.1),
                                            blurRadius:
                                                5.0, // soften the shadow
                                            spreadRadius:
                                                1.0, //extend the shadow
                                            offset: Offset(
                                              2.0, // Move to right 10  horizontally
                                              3.0, // Move to bottom 10 Vertically
                                            ),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        'Update Areas',
                                        style: TextStyle(
                                          color: zimkeyDarkGrey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              (fbState.isLoggedIn.value == "true" ||
                                      fbState.isLoggedIn.isEmpty)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'General',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: zimkeyDarkGrey,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        profileMenuitem(
                                          'Edit Profile',
                                          'assets/images/icons/newIcons/user.svg',
                                          context,
                                          EditProfile(),
                                        ),
                                        profileMenuitem(
                                            'Edit Bank Details',
                                            'assets/images/icons/newIcons/account.svg',
                                            context,
                                            EditBankAccount(
                                              userDetails: userdetails,
                                            )),
                                        profileMenuitem(
                                          'Edit Availability',
                                          'assets/images/icons/newIcons/user.svg',
                                          context,
                                          EditAvailability(),
                                        ),
                                        // profileMenuitem(
                                        //   'Payment Information',
                                        //   'assets/images/icons/rupee.svg',
                                        //   context,
                                        //   null,
                                        // ),
                                        profileMenuitem(
                                          'Wallet Balance & History',
                                          'assets/images/icons/newIcons/empty-wallet.svg',
                                          context,
                                          WalletHistory(),
                                        ),
                                        profileMenuitem(
                                          'Customer Support',
                                          'assets/images/icons/newIcons/support.svg',
                                          context,
                                          CustomerSupport(),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Login or Register ',
                                              style: TextStyle(
                                                color: zimkeyBlack,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Kindly register to access all the profile benefits',
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              Get.offAllNamed('/login');
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 100,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 10),
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
                                                    1.0, // Move to right 10  horizontally
                                                    1.0, // Move to bottom 10 Vertically
                                                  ),
                                                )
                                              ],
                                            ),
                                            child: Text(
                                              'Register',
                                              style: TextStyle(
                                                color: zimkeyWhite,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: zimkeyDarkGrey,
                                ),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              profileMenuitem(
                                  'Terms of Service',
                                  'assets/images/icons/newIcons/terms.svg',
                                  context,
                                  null, function: () {
                                print(fbState.cmsConetent.value.toJson());
                                Get.to(WebViewPage(
                                    url: fbState.cmsConetent.value
                                            .termsConditions ??
                                        "",
                                    title: 'Terms of Service'));
                              }),
                              profileMenuitem(
                                  'Privacy Policy',
                                  'assets/images/icons/newIcons/privacy.svg',
                                  context,
                                  null, function: () {
                                Get.to(WebViewPage(
                                    url: fbState
                                            .cmsConetent.value.privacyPolicy ??
                                        "",
                                    title: 'Privacy Policy'));
                              }),
                              profileMenuitem(
                                  'Safety Policy',
                                  'assets/images/icons/newIcons/safety.svg',
                                  context,
                                  null, function: () {
                                Get.to(WebViewPage(
                                    url: fbState
                                            .cmsConetent.value.safetyPolicy ??
                                        "",
                                    title: 'Safety Policy'));
                              }),
                              profileMenuitem(
                                  'About Us',
                                  'assets/images/icons/newIcons/informationProfile.svg',
                                  context,
                                  null, function: () {
                                Get.to(WebViewPage(
                                    url:
                                        fbState.cmsConetent.value.aboutUs ?? "",
                                    title: 'About Us'));
                              }),
                              if (fbState.isLoggedIn.value == "true" ||
                                  fbState.isLoggedIn.isEmpty)
                                SizedBox(
                                  height: 20,
                                ),
                              if (fbState.isLoggedIn.value == "true" ||
                                  fbState.isLoggedIn.isEmpty)
                                InkWell(
                                  onTap: () {
                                    print("tapping");

                                    showLogoutDialog(
                                        'Confirm',
                                        "Are you sure you want to signout from the app?",
                                        context,
                                        true);
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
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: double.infinity,
                          color: zimkeyLightGrey,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (packageInfo != null)
                                Text(
                                  'App Version ${packageInfo!.version}.${packageInfo!.buildNumber}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: zimkeyDarkGrey,
                                  ),
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Update available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: zimkeyOrange,
                                ),
                              ),
                              // SizedBox(
                              //   height: 10,
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
        if (loading) Center(child: sharedLoadingIndicator()),
      ],
    );
  }

  Widget profileMenuitem(
      String menuTitle, String icon, BuildContext context, Widget? page,
      {Function? function}) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        } else {
          if (function != null) {
            function!();
          }
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.symmetric(vertical: 10),
        // color: zimkeyGreen,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuTitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: zimkeyBlack,
                    ),
                  ),
                  if (menuTitle.toLowerCase().contains('wallet') &&
                      userdetails!.partnerDetails != null &&
                      userdetails!.partnerDetails!.walletBalance != null &&
                      userdetails!.partnerDetails!.walletBalance! > 0)
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: zimkeyOrange,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        'Redeem',
                        style: TextStyle(fontSize: 12, color: zimkeyWhite),
                      ),
                    ),
                ],
              ),
            ),
            SvgPicture.asset(
              icon,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget overviewTiles(String title, String value, Widget route) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => route,
                ),
              );
            },
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: zimkeyGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  showLogoutDialog(
      String title, String msg, BuildContext context, bool isRefresh) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
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
                  onTap: () async {
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
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            loading
                ? CircularProgressIndicator()
                : InkWell(
                    onTap: () async {
                      print("tapping__");
                      setState(() {
                        loading = true;
                      });
                      //unregister devide ID
                      await unsetFCMToken(context, fbState.deviceId.value);
                      fbState.setUserLoggedIn('false');
                      fbState.setToken('');
                      auth.signOut().then((value) {
                        setState(() {
                          loading = false;
                        });
                        Get.toNamed('/login');
                      });
                      print('Logged out!!!!!!');
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                      decoration: BoxDecoration(
                        color: zimkeyOrange,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: zimkeyLightGrey.withOpacity(0.1),
                            blurRadius: 5.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                            offset: Offset(
                              2.0, // Move to right 10  horizontally
                              3.0, // Move to bottom 10 Vertically
                            ),
                          )
                        ],
                      ),
                      child: Text(
                        'Signout',
                        style: TextStyle(
                          color: zimkeyWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
