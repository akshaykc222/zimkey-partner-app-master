import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zimkey_partner_app/notification.dart';

import '../fbState.dart';
import '../login/login.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../signup/signUpDetails.dart';
import '../theme.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  AnimationController? _controller;

  //Initialise the object for FbState
  final FbState fbState = Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool? isRegistered;
  bool? isLoggedin;
  String? tokenId;
  List<Area> arealist = [];
  bool callGetMe = false;
  var duration = new Duration(seconds: 5);
  PartnerUser? partnerUser;
  List<PartnerPendingTaskEnum> partnerProgressStage = [];
  BuildContext? thiscontext;

  navigateTo() async {
    final RemoteMessage? _message =
        await FirebaseMessaging.instance.getInitialMessage();
    print('inside navigate!! isLogin $isLoggedin registerd $isRegistered');
    if (_message != null) {
      NotificationService.handleNavigation(_message, context, () async {
        if (isLoggedin != null && isLoggedin!) {
          if (isRegistered != null) {
            if (isRegistered!) {
              fbState.setIsRegistered('true');
              //Register device ID----------
              await getDeviceInfo();
              await setupMessaging();
              await getUser(context);
            } else
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SignUpDetails(
                      fbstate: fbState,
                    ),
                    duration: Duration(milliseconds: 400),
                  ));
          } else {
            fbState.setIsRegistered('false');
            print('isregisteres is null!!!');
            Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: Login(),
                  duration: Duration(milliseconds: 400),
                ));
          }
        } else {
          Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: Login(),
                duration: Duration(milliseconds: 400),
              ));
        }
      });
    } else {
      if (isLoggedin != null && isLoggedin!) {
        if (isRegistered != null) {
          if (isRegistered!) {
            fbState.setIsRegistered('true');
            //Register device ID----------
            await getDeviceInfo();
            await setupMessaging();
            await getUser(context);
          } else
            Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: SignUpDetails(
                    fbstate: fbState,
                  ),
                  duration: Duration(milliseconds: 400),
                ));
        } else {
          fbState.setIsRegistered('false');
          print('isregisteres is null!!!');
          Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: Login(),
                duration: Duration(milliseconds: 400),
              ));
        }
      } else {
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: Login(),
              duration: Duration(milliseconds: 400),
            ));
      }
    }
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    getToken();
    Timer(duration, () {
      _initPackageInfo();
      navigateTo();
    });
    super.initState();
  }

  getToken() {
    GetStorage storage = GetStorage();
    String? token = storage.read('token');
    if (token != null) {
      isLoggedin = true;
      print("TOKEN $token");
      fbState.setToken(token);
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    packageInfo = info;
  }

  @override
  Widget build(BuildContext context) {
    thiscontext = context;
    deviceApect = calculateAspectRatioFit(1080, 1920,
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    // print('deviceApect >>>>>===== $deviceApect');
    return Scaffold(
        body: Query(
      options: QueryOptions(
        document: gql(getMe),
      ),
      builder: (
        QueryResult result, {
        VoidCallback? refetch,
        FetchMore? fetchMore,
      }) {
        if (result.isLoading)
          // return Center(child: sharedLoadingIndicator());
          return splashContent();
        else if (result.data != null && result.data!['me'] != null) {
          PartnerUser temp;
          temp = PartnerUser.fromJson(result.data!['me']);
          fbState.setPartnerUser(temp);
          if (result.data!['me']['isPartnerRegistered']) {
            isRegistered = true;
            isLoggedin = true;
            print('user has token and is  registered. ---> go to dashboard');
          } else {
            isRegistered = false;
            isLoggedin=false;
          }
        } else {
          print('else part of query!!');
          isRegistered = false;
          isLoggedin=false;
        }
        fbState.setIsRegistered(isRegistered.toString());
        return Query(
            options: QueryOptions(
              document: gql(getAreas),
            ),
            builder: (
              QueryResult result, {
              VoidCallback? refetch,
              FetchMore? fetchMore,
            }) {
              if (result.isLoading)
                return splashContent();
              // return Center(child: sharedLoadingIndicator());
              else if (result.data != null &&
                  result.data!['getAreas'] != null) {
                arealist.clear();
                for (Map area in result.data!['getAreas']) {
                  Area temp;
                  temp = Area.fromJson(area as Map<String, dynamic>);
                  arealist.add(temp);
                }
                fbState.setAreaList(arealist);
              }
              //Splash Content
              return splashContent();
            });
      },
    ));
  }

  Widget splashContent() {
    final scaleVal =
        (1.2 * MediaQuery.of(context).size.height) / 781.0909090909091;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        color: zimkeyWhite,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SvgPicture.asset(
          'assets/images/graphics/zimkeyLogo.svg',
        ),
        // Stack(
        //   alignment: Alignment.center,
        //   children: [
        //     Transform(
        //       transform: new Matrix4.identity()..scale(scaleVal, scaleVal),
        //       alignment: FractionalOffset.center,
        //       child: Lottie.asset(
        //         'assets/images/graphics/zimkeySplash.json',
        //         repeat: true,
        //         fit: BoxFit.fitWidth,
        //         width: MediaQuery.of(context).size.width,
        //         controller: _controller,
        //         onLoaded: (composition) {
        //           // Configure the AnimationController with the duration of the
        //           // Lottie file and start the animation.
        //           _controller
        //             ..duration = composition.duration
        //             ..forward();
        //         },
        //       ),
        //     )
        //   ],
      ),
    );
  }

  calculateAspectRatioFit(srcWidth, srcHeight, maxWidth, maxHeight) {
    double ratio = min(maxWidth / srcWidth, maxHeight / srcHeight);
    return {'width': srcWidth * ratio, 'height': srcHeight * ratio};
  }

  Widget signupButton(
      BuildContext context, String buttontext, Color bgColor, Color textcol) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width / 1.3,
      padding: EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
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
        buttontext,
        style: TextStyle(
          fontSize: 16,
          color: textcol,
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
