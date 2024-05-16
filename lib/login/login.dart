import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../fbState.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../shared/inputDone.dart';
import '../signup/signUpDetails.dart';
import '../theme.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late bool checked;
  late bool isFilled;
  bool isLoading = false;
  OverlayEntry? overlayEntry;

  //Login Page variables
  TextEditingController _mobile = new TextEditingController();
  final FocusNode _mobileNode = FocusNode();
  String _countryCode = "+91";
  FirebaseAuth auth = FirebaseAuth.instance;
  String verifyId = "";
  bool showErrorAlert = false;
  String errorAlertMsg = "";
  final FbState fbState = Get.find();
  bool isNavigated = false;
  bool showResend = false;
  PartnerUser? partnerUser;

  //OTP variables
  bool showOtpPage = false;
  final TextEditingController _otp = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  int levelClock = 120;
  final FocusNode _otpNode = FocusNode();
  bool enableOtp = true;
  bool hasOtpExpired = false;

  @override
  void initState() {
    super.initState();

    checked = false;
    isFilled = false;
    _mobileNode.addListener(() {
      bool hasFocus = _mobileNode.hasFocus;
      if (hasFocus)
        showOverlay(context);
      else
        removeOverlay();
    });
    //OTP animation controller
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
          seconds: 90,
        ) // gameData.levelClock is a user entered number elsewhere in the applciation
        );
    _controller.forward();

    //otp field listener
    _otpNode.addListener(() async {
      bool hasFocus = _otpNode.hasFocus;
      if (hasFocus)
        showOverlay(context);
      else
        removeOverlay();
      //--------Navigate to next page when filled
      if (_otp.text.length == 6) {
        removeOverlay();
        // if (!hasOtpExpired) {
        // }
        // // await signInWithPhoneNumber();
        // else {
        //   _otp.clear();
        //   // showCustomDialog(
        //   //     'Oops!',
        //   //     'OTP has expired. Please resend or change number.',
        //   //     context,
        //   //     null);
        // }
      }
    });
  }

  Future<QueryResult> loginWithPhone(String phoneNumber) async {
    final MutationOptions _options = MutationOptions(
      document: gql(login),
      variables: <String, dynamic>{
        "data": {
          "phoneNumber": phoneNumber,
          "os": Platform.operatingSystem,
          "os_version": Platform.operatingSystemVersion
        }
      },
    );
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

    if (addAddlWorkResult.data != null) {
      setState(() {
        isLoading = false;
        showOtpPage = true;
      });
    }
    return addAddlWorkResult;
  }

  bool hasError = false;

  verifyOtpService(String otp) async {
    print("verifing");
    setState(() {
      isLoading = true;
    });
    final firebaseMessaging = FirebaseMessaging.instance;
    var token = await firebaseMessaging.getToken();

    var d;
    var da;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        d = androidInfo.model;
        print('Running on ${androidInfo.model}');
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        da = iosInfo.utsname.machine;
      }
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    print({
      "phoneNumber": "+91${_mobile.text}",
      "otp": otp,
      "token": token,
      "deviceId": Platform.isAndroid ? d : da,
      "device": Platform.isAndroid ? "ANDROID" : "IOS",
    });
    final MutationOptions _options = MutationOptions(
      document: gql(verifyOtp),
      variables: <String, dynamic>{
        "data": {
          "phoneNumber": "+91${_mobile.text}",
          "otp": otp,
          "token": token,
          "deviceId": Platform.isAndroid ? d : d,
          "device": Platform.isAndroid ? "ANDROID" : "IOS",
          "app": "PARTNER"
        }
      },
    );
    setState(() {
      isLoading = true;
    });
    print("working upto here");
    final QueryResult addAddlWorkResult =
        await globalGQLClient.value.mutate(_options);
    print("result $addAddlWorkResult");
    setState(() {
      isLoading = false;
    });
    print("as ${addAddlWorkResult.hasException}");
    if (addAddlWorkResult.hasException) {
      print("as ${addAddlWorkResult.hasException}");
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
    print(addAddlWorkResult.data);
    if (addAddlWorkResult.data?['verifyOtp'] != null) {
      print("noy ");

      print("token");

      fbState.setToken(addAddlWorkResult.data!['verifyOtp']['data']['token']);
      fbState.setUserLoggedIn('true');
      print("working upto here");
      if (addAddlWorkResult.data!['verifyOtp']['data']['isPartnerRegistered']) {
        await getUser(context);
      } else {
        setState(() {
          isLoading = true;
        });
        print("else");
        await checkUser();
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: SignUpDetails(
                fbstate: fbState,
              ),
              duration: Duration(milliseconds: 400),
            ));
        setState(() {
          isLoading = false;
          showOtpPage = true;
        });
      }
      // Get.toNamed('/signup');
    } else {
      print("else part0");
    }
    return addAddlWorkResult;
  }

  // Future signInWithPhoneNumber() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   print('isLoading $isLoading');
  //   try {
  //     final AuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verifyId,
  //       smsCode: _otp.text,
  //     );
  //     final User user = (await auth.signInWithCredential(credential)).user!;
  //     print('current userid ${auth.currentUser!.uid}');
  //     print("Successfully signed in UID: ${user.uid}");
  //     print('is UID equal ?? ${auth.currentUser!.uid == user.uid}');
  //     setState(() {
  //       isLoading = false;
  //       isNavigated = true;
  //       hasOtpExpired = false;
  //     });
  //     String tokenId = await auth.currentUser?.getIdToken() ?? "";
  //     fbState.setToken(tokenId);
  //     fbState.setUserLoggedIn('true');
  //     if (auth.currentUser!.uid == user.uid ||
  //         fbState.isRegistered.value == 'true') {
  //       await getUser(context);
  //     } else
  //       // Get.toNamed('/signup');
  //       Navigator.push(
  //           context,
  //           PageTransition(
  //             type: PageTransitionType.rightToLeft,
  //             child: SignUpDetails(
  //               fbstate: fbState,
  //             ),
  //             duration: Duration(milliseconds: 400),
  //           ));
  //   } catch (e) {
  //     print('Signin exception >>>> $e');
  //     setState(() {
  //       isLoading = false;
  //       isNavigated = false;
  //     });
  //     _otp.clear(); //clear on error
  //     if (!isNavigated) {
  //       if (e is FirebaseAuthException) {
  //         if (e.code == "invalid-verification-code") {
  //           print('Code entered is wrong');
  //           showCustomDialog('Oops!', 'OTP entered is wrong', context, null);
  //         } else if (e.code == "session-expired") {
  //           print('Session-expired');
  //           showCustomDialog(
  //               'Oops!',
  //               'The SMS code has expired. Please re-send the verification code to try again.',
  //               context,
  //               null);
  //         } else {
  //           showCustomDialog(
  //               'Oops!', 'Failed to sign in:  ${e.toString()}', context, null);
  //           print("Failed to sign in: " + e.toString());
  //         }
  //       }
  //     }
  //   }
  // }

  showOverlay(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        right: 0.0,
        left: 0.0,
        child: InputDoneView(),
      );
    });

    overlayState.insert(overlayEntry!);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  // @override
  // void dispose() {
  //   // _otp.dispose();
  //   super.dispose();
  // }

  late double bottom;

  @override
  Widget build(BuildContext context) {
    bottom = MediaQuery.of(context).viewInsets.bottom;
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: zimkeyWhite,
            body: SingleChildScrollView(
              child: SafeArea(
                bottom: true,
                child: !showOtpPage
                    // Login Page
                    ? loginSection()
                    : otpSection(),
              ),
            ),
          ),
          if (isLoading)
            Positioned(
              left: MediaQuery.of(context).size.width / 2.2,
              right: MediaQuery.of(context).size.width / 2.2,
              // left: 200,
              top: MediaQuery.of(context).size.height / 1.7,
              child: sharedLoadingIndicator(),
            ),
        ],
      ),
    );
  }

  Widget loginSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      color: zimkeyWhite,
      height: MediaQuery.of(context).size.height / 1.06,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Text(
                  //   'Welcome to ',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     color: zimkeyBlack,
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  // ),

                  SvgPicture.asset(
                    'assets/images/graphics/logo_without.svg',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),

              // Text(
              //   'Please enter your phone number to continue.',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: zimkeyDarkGrey.withOpacity(0.6),
              //   ),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              // Container(
              //   decoration: BoxDecoration(
              //     border: Border(
              //       bottom: BorderSide(
              //         color: zimkeyDarkGrey.withOpacity(0.3),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: zimkeyDarkGrey.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // CountryCodePicker(
                    //   textStyle: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //     color: zimkeyDarkGrey,
                    //   ),
                    //   padding: EdgeInsets.only(bottom: 0),
                    //   onChanged: print,
                    //   // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                    //   initialSelection: 'IN',
                    //   favorite: ['+91', 'IN'],
                    //   // countryFilter: ['IT', 'FR'],
                    //   showFlagDialog: true,
                    //   comparator: (a, b) => b.name.compareTo(a.name),
                    //   //Get the country information relevant to the initial selection
                    //   onInit: (code) {
                    //     // setState(() {
                    //     _countryCode = code.dialCode;
                    //     // });
                    //     print("on init $_countryCode");
                    //   },
                    // ),
                    SvgPicture.asset(
                      'assets/images/icons/indiaFlag.svg',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      '$_countryCode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextFormField(
                        focusNode: _mobileNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        controller: _mobile,
                        onChanged: (value) {
                          setState(() {
                            if (_mobile.text.length > 0)
                              isFilled = true;
                            else
                              isFilled = false;
                          });
                        },
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          errorMaxLines: 2,
                          counterText: '',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            // color: Colors.red,
                            color: zimkeyDarkGrey.withOpacity(0.3),
                            fontWeight: FontWeight.normal,
                          ),
                          hintText: 'Enter your phone no.',
                          hintMaxLines: 2,
                          fillColor: zimkeyOrange,
                          focusColor: zimkeyOrange,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isFilled ? zimkeyBlack : zimkeyWhite,
                          size: 16,
                        ),
                        onPressed: () {
                          _mobile.clear();
                          setState(() {
                            isFilled = false;
                          });
                        })
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        checked = !checked;
                        print('checked ... $checked');
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: checked ? zimkeyOrange : Colors.transparent,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: zimkeyOrange,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: 'By registering, you agree to the',
                              style: TextStyle(
                                fontSize: 12,
                                color: zimkeyBlack,
                              )),
                          TextSpan(
                            text: ' Terms of Service ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: zimkeyBlack,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchURL('https://zimkey.in/page-terms');
                                print('Terms tapped!!');
                              },
                          ),
                          TextSpan(
                              text: 'and ',
                              style: TextStyle(
                                fontSize: 12,
                                color: zimkeyBlack,
                              )),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              fontSize: 12,
                              color: zimkeyBlack,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchURL('https://zimkey.in/privacy-policy');
                                print('Terms tapped!!');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // await check().then((internet) async {
                      // if (internet != null && internet) {
                      // Internet Present Case
                      if (isFilled && _mobile.text.length == 10 && checked) {
                        // _otp.dispose();
                        setState(() {
                          isLoading = true;
                        });
                        loginWithPhone("+91${_mobile.text}");
                        // await auth.verifyPhoneNumber(
                        //   phoneNumber: '$_countryCode ${_mobile.text}',
                        //   verificationCompleted: //This handler will only be called on Android devices which support automatic SMS code resolution.
                        //       (PhoneAuthCredential credential) async {
                        //     await auth.signInWithCredential(credential);
                        //     setState(() {
                        //       isLoading = false;
                        //     });
                        //   },
                        //   timeout: const Duration(
                        //     seconds: 90,
                        //   ),
                        //   verificationFailed: //Only for android
                        //       (FirebaseAuthException e) {
                        //     setState(() {
                        //       isLoading = false;
                        //     });
                        //     print('${_otp.isBlank}');
                        //     print('Exception $e');
                        //     if (e.code == 'invalid-phone-number') {
                        //       print('The provided phone number is not valid.');
                        //       showCustomDialog(
                        //           'Oops!!',
                        //           'The provided phone number is not valid.',
                        //           context,
                        //           null);
                        //     } else if (e.code == "too-many-requests") {
                        //       showCustomDialog(
                        //           'Oops!!',
                        //           'Too many requests from this number. Please try again after sometime.',
                        //           context,
                        //           null);
                        //     } else {
                        //       showCustomDialog(
                        //           'Oops!!', '${e.message}', context, null);
                        //     }
                        //   },
                        //   codeSent:
                        //       (String verificationId, int? resendToken) async {
                        //     setState(() {
                        //       isLoading = false;
                        //       verifyId = verificationId;
                        //       showOtpPage = true;
                        //     });
                        //   },
                        //   codeAutoRetrievalTimeout: (String verificationId) {
                        //     if (isNavigated) {
                        //       setState(() {
                        //         isLoading = false;
                        //         enableOtp = false;
                        //         verifyId = verificationId;
                        //         hasOtpExpired = true;
                        //       });
                        //
                        //       showCustomDialog(
                        //           'Oops!!!',
                        //           'The SMS code has expired. Please re-send the verification code to try again.',
                        //           context,
                        //           null);
                        //     }
                        //   },
                        // );
                      } else if (!isFilled) {
                        showCustomDialog('Oops!!!',
                            'Please enter valid mobile number', context, null);

                        // setState(() {
                        //   showErrorAlert = true;
                        //   errorAlertMsg = 'Please enter valid mobile number';
                        // });
                      } else if (_mobile.text.length < 10) {
                        setState(() {
                          showErrorAlert = true;
                          errorAlertMsg =
                              'The provided phone number length is not valid.';
                        });
                      }
                      // }
                      // }
                      // No-Internet Case
                      // else {
                      //   print('Internet Connectivity Issue!!!!!');
                      //   setState(() {
                      //     showDialog(
                      //       context: context,
                      //       builder: (context) {
                      //         return showCustomDialog(
                      //           'Oops!!',
                      //           'Check your device connection.',
                      //         );
                      //       },
                      //     );
                      //   });
                      // }
                      // });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 190,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isFilled && _mobile.text.length == 10 && checked
                            ? zimkeyOrange
                            : zimkeyWhite,
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
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isFilled && _mobile.text.length == 10 && checked
                                  ? Colors.white
                                  : zimkeyBlack,
                          fontFamily: 'Inter',
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget otpSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      // color: zimkeyGreen,
      height: MediaQuery.of(context).size.height / 1.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 24,
                  color: zimkeyBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Enter the 6 digit code sent to',
                            style: TextStyle(
                              fontSize: 14,
                              color: zimkeyDarkGrey.withOpacity(0.6),
                            ),
                          ),
                          TextSpan(
                            text: ' ${_mobile.text} ',
                            style: TextStyle(
                              fontSize: 14,
                              color: zimkeyDarkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              GestureDetector(
                onTap: () {
                  _otp.clear();
                  _mobile.clear();
                  setState(() {
                    showOtpPage = false;
                  });
                  print('The Change button is clicked!');
                },
                child: Text(
                  'Change number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: zimkeyOrange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 5,
            ),
            alignment: Alignment.topCenter,
            height: MediaQuery.of(context).size.height / 2,
            // color: Colors.grey,
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: PinCodeTextField(
                    autoDisposeControllers: false,
                    autoFocus: true,
                    enabled: enableOtp,
                    focusNode: _otpNode,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: zimkeyDarkGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    length: 6,
                    obscureText: false,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: zimkeyDarkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: zimkeyWhite,
                      activeColor: zimkeyDarkGrey,
                      inactiveFillColor: zimkeyLightGrey,
                      selectedFillColor: zimkeyWhite,
                      selectedColor: zimkeyDarkGrey,
                      borderWidth: 1,
                      inactiveColor: zimkeyLightGrey,
                      disabledColor: zimkeyLightGrey,
                    ),
                    cursorColor: zimkeyOrange,
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: zimkeyWhite,
                    enableActiveFill: true,
                    animationType: AnimationType.scale,
                    // errorAnimationController: errorController,
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    onCompleted: (v) {
                      verifyOtpService(v);
                    },
                    // onTap: () {
                    //   print("Pressed");
                    // },
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        // currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      print("Paste code $text ?");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                CountDownTimer(
                  isNavigated: isNavigated,
                  auth: auth,
                  mobile: '$_countryCode ${_mobile.text}',
                  resetOtp: () {
                    // setState(() {
                    //   enableOtp = val;
                    // });
                    hasOtpExpired = false;
                    loginWithPhone("+91${_mobile.text}");
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Otp sent...")));
                  },
                  setExpiry: (bool val) {
                    hasOtpExpired = val;
                  },
                  loaderDisplay: (bool val) {
                    setState(() {
                      isLoading = val;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

//Countdown Timer
class CountDownTimer extends StatefulWidget {
  final FirebaseAuth? auth;
  final String? mobile;
  final Function? resetOtp;
  final Function? loaderDisplay;
  final bool? isNavigated;
  final Function? setExpiry;

  const CountDownTimer({
    Key? key,
    this.auth,
    this.mobile,
    this.resetOtp,
    this.loaderDisplay,
    this.isNavigated,
    this.setExpiry,
  }) : super(key: key);

  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Duration duration;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 90,
      ),
    );
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
  }

  String get timerString {
    duration = controller.duration! * controller.value;
    String val =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    if (val == '0:00')
      widget.setExpiry!(true);
    else {
      widget.setExpiry!(false);
    }
    return val;
  }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          if (timerString == '0:00')
            return GestureDetector(
              onTap: () => widget.resetOtp!(),
              child: Text(
                'Resend Code',
                style: TextStyle(
                  fontSize: 18,
                  color: zimkeyOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          else
            return Text(
              timerString,
              style: TextStyle(
                fontSize: 16.0,
                color: zimkeyDarkGrey,
                // fontWeight: FontWeight.w700,
              ),
            );
        });
  }
}
