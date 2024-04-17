import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

//Global Graphql Client
var globalGQLClient;
Map<String, dynamic>? deviceApect;

String baseImgUrl = 'https://staging.api.zimkey.in/media-upload/';
//MEdia url-----------
String serviceImg = 'https://staging.api.zimkey.in/media-upload/';
//Upload url---------
String uploadURL = 'https://staging.api.zimkey.in/media-upload/profile-upload/';

showCustomDialog(
    String title, String msg, BuildContext context, Widget? backPage,
    {Function? addFunction}) {
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
        actions: [
          addFunction != null
              ? TextButton(
                  onPressed: () {
                    addFunction();
                    Get.back();
                  },
                  child: Text(
                    "Accept",
                    style: TextStyle(color: zimkeyOrange),
                  ))
              : SizedBox()
        ],
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
                  if (backPage != null)
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: backPage,
                        duration: Duration(milliseconds: 300),
                      ),
                    );
                  else
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
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        // actions: <Widget>[
        //   new InkWell(
        //     onTap: () {
        //       Get.back();
        //     },
        //     child: const Text(
        //       'Close',
        //       style: TextStyle(
        //         color: zimkeyOrange,
        //         fontWeight: FontWeight.bold,
        //         fontSize: 15,
        //       ),
        //     ),
        //   ),
        // ],
      );
    },
  );
}

//Launch URL
Future<void> launchURL(String _url) async {
  try {
    print("lauching url $_url ${await canLaunchUrl(Uri.parse(_url))}");
    await canLaunchUrl(Uri.parse(_url))
        ? await launchUrl(Uri.parse(_url))
        : throw 'Could not launch $_url';
  } catch (e) {}
}

//Pageview Bubble Indicators
Widget customPageViewIndicators(PageController controller, int count,
    bool isDots, double width, double height,
    {Color dotColor = zimkeyOrange}) {
  return SmoothPageIndicator(
    controller: controller, // PageController
    count: count,
    effect: isDots
        ? WormEffect(
            spacing: 3,
            dotHeight: height,
            dotWidth: width,
            dotColor: dotColor.withOpacity(0.5),
            activeDotColor: dotColor,
          )
        : ExpandingDotsEffect(
            dotHeight: height,
            dotWidth: width,
            dotColor: dotColor.withOpacity(0.5),
            activeDotColor: dotColor,
          ), // your preferred effect
  );
}

// FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
//     amount: 12345678.9012345,
//     settings: MoneyFormatterSettings(
//         symbol: 'IDR',
//         thousandSeparator: '.',
//         decimalSeparator: ',',
//         symbolAndNumberSeparator: ' ',
//         fractionDigits: 3,
//         compactFormatType: CompactFormatType.sort
//     )
// )

List<String> timeHours = [
  '8.00 - 8.30',
  '8.30 - 9.00',
  '9.00 - 9.30',
  '9.30 - 10.00',
  '10.00 - 10.30',
  '10.30 - 11.00',
  '11.00 - 11.30',
  '11.30 - 12.00',
  '12.00 - 12.30',
  '12.30 - 13.00',
  '13.00 - 13.30',
  '13.30 - 14.00',
  '14.00 - 14.30',
  '14.30 - 15.00',
  '15.00 - 15.30',
  '14.30 - 16.00',
  '16.00 - 16.30',
  '16.30 - 17.00',
  '17.00 - 17.30',
  '17.30 - 18.00',
  '18.00 - 18.30',
  '18.30 - 19.00',
  '19.00 - 19.30',
  '19.30 - 20.00',
  '20.00 - 20.30',
  '20.30 - 21.00',
];

List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

//Partner document types
enum DocumentTypeEnum {
  AADHAR,
  VOTER_ID,
  RATION_ID,
  PAN,
  DRIVING_LICENSE,
  BUSINESS_LICENSE,
  OTHER,
  PASSPORT,
}

Map<String, dynamic> docTypeMAp = {
  'Aadhar': 'AADHAR',
  'Voter Id': 'VOTER_ID',
  'Ration Card': 'RATION_ID',
  'PAN Card': 'PAN',
  'Driving License': 'DRIVING_LICENSE',
  'Business License': 'BUSINESS_LICENSE',
  'Other': 'OTHER',
  'Passport': 'PASSPORT',
};

List<String> docTypeList = [
  'Aadhar',
  'Voter Id',
  'Ration Card',
  'PAN Card',
  'Driving License',
  'Passport',
  'Other',
  'Business License'
];

List<String> allgenders = ['Female', 'Male'];

var dobDateMask = new MaskTextInputFormatter(
    mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

PackageInfo? packageInfo;

//Signup field validation---
bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(p);
  return regExp.hasMatch(em);
}

bool validateAccountNo(String value) {
  String pattern = r"[0-9]{9,18}";
  RegExp regExp = new RegExp(pattern);
  bool result = regExp.hasMatch(value);
  return result;
}

bool validateIFSC(String value) {
  String pattern = r"^[A-Z]{4}0[A-Z0-9]{6}$";
  RegExp regExp = new RegExp(pattern);
  bool result = regExp.hasMatch(value);
  return result;
}

Widget sharedLoadingIndicator() {
  return CircularProgressIndicator(
    backgroundColor: zimkeyOrange,
    valueColor: new AlwaysStoppedAnimation<Color>(
      Colors.white,
    ),
  );
}
