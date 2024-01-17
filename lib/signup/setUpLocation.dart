import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globals.dart';
import '../theme.dart';
import 'searchLocation.dart';

class SetupLocation extends StatefulWidget {
  final String? name;
  final String? aadhar;
  final String? streetAddr;
  final List<String>? areas;
  final String? city;
  final String? postal;
  final String? accNo;
  final String? ifscCode;
  const SetupLocation({
    Key? key,
    this.name,
    this.aadhar,
    this.streetAddr,
    this.areas,
    this.city,
    this.postal,
    this.accNo,
    this.ifscCode,
  }) : super(key: key);

  @override
  _SetupLocationState createState() => _SetupLocationState();
}

class _SetupLocationState extends State<SetupLocation> {
  bool isLoading = false;
  Area selectedArea = Area();
  final FbState fbState = Get.find();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: zimkeyWhite,
            elevation: 0,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            color: zimkeyWhite,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Where are you located?',
                    style: TextStyle(
                      fontSize: 24,
                      color: zimkeyBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Update your location to improve your \nexperience on Zimkey Partner',
                    style: TextStyle(
                      fontSize: 14,
                      color: zimkeyBlack,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    // color: Colors.blueGrey,
                    height: MediaQuery.of(context).size.height / 1.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Region',
                            style: TextStyle(
                              color: zimkeyBlack.withOpacity(0.3),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //region
                        Container(
                          decoration: BoxDecoration(
                            color: zimkeyLightGrey,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(
                            'Cochin',
                            style: TextStyle(
                              color: zimkeyBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Area',
                            style: TextStyle(
                              color: zimkeyDarkGrey.withOpacity(0.3),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: SearchLocation(
                                  areaList: fbState.areaList,
                                  updateSearchArea: (Area area) {
                                    setState(() {
                                      selectedArea = area;
                                      fbState.setUserLoc(area.name!);
                                    });
                                  }),
                              duration: Duration(milliseconds: 300),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: zimkeyLightGrey,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                left: 20, right: 20, top: 13, bottom: 13),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedArea != null &&
                                            selectedArea.name != null
                                        ? '${fbState.areaLoc.value}'
                                        : "Select your area",
                                    style: TextStyle(
                                      color: zimkeyDarkGrey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard()),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 190,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                          ),
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
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => Dashboard()),
                        //   );
                        // },
                        child: Container(
                          alignment: Alignment.center,
                          width: 100,
                          // width: MediaQuery.of(context).size.width / 2.5,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: zimkeyWhite,
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
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              color: zimkeyBlack,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
}
