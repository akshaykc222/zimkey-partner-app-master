import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:recase/recase.dart';

import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';

class SignupConfirmation extends StatefulWidget {
  SignupConfirmation({Key? key}) : super(key: key);

  @override
  _SignupConfirmationState createState() => _SignupConfirmationState();
}

class _SignupConfirmationState extends State<SignupConfirmation> {
  PartnerUser partnerUser = PartnerUser();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: zimkeyWhite,
          elevation: 0,
        ),
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
                return Center(
                  child: sharedLoadingIndicator(),
                );
              else if (result.data!['me'] != null) {
                PartnerUser temp;
                temp = PartnerUser.fromJson(result.data!['me']);
                partnerUser = temp;
                print('result data is there!!>>>>> ${partnerUser.name}');
              } else {
                print('else part of query!!');
              }
              //Slpash Content
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                color: zimkeyWhite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thank you',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: zimkeyDarkGrey,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'We have received your request.Someone will be in contact with you shortly.',
                        style: TextStyle(
                          fontSize: 13,
                          color: zimkeyDarkGrey.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Profile details',
                        style: TextStyle(
                          fontSize: 20,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Contact',
                        style: TextStyle(
                          fontSize: 17,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${ReCase(result.data!['me']['name']).sentenceCase}',
                        style: TextStyle(
                          fontSize: 15,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'ID Card No',
                        style: TextStyle(
                          fontSize: 15,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 16,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      result.data!['me']['partnerDetails'] != null
                          ? Text(
                              '${ReCase(result.data!['me']['partnerDetails']['address']).sentenceCase}',
                              style: TextStyle(
                                fontSize: 15,
                                color: zimkeyDarkGrey,
                                fontWeight: FontWeight.w100,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'City, Country',
                        style: TextStyle(
                          fontSize: 15,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      result.data!['me']['partnerDetails'] != null
                          ? Text(
                              '${ReCase(result.data!['me']['partnerDetails']['postalCode']).sentenceCase}',
                              style: TextStyle(
                                fontSize: 15,
                                color: zimkeyDarkGrey,
                                fontWeight: FontWeight.w100,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 16,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      result.data!['me']['categorySelected'] != null
                          ? Text(
                              '${ReCase(result.data!['me']['categorySelected']).sentenceCase}',
                              style: TextStyle(
                                fontSize: 15,
                                color: zimkeyDarkGrey,
                                fontWeight: FontWeight.w100,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 16,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '1 Dec, 2020',
                        style: TextStyle(
                          fontSize: 15,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 16,
                          color: zimkeyDarkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      result.data!['me']['documentsUploaded'] != null
                          ? Text(
                              '${ReCase(result.data!['me']['documentsUploaded']).sentenceCase}',
                              style: TextStyle(
                                fontSize: 15,
                                color: zimkeyDarkGrey,
                                fontWeight: FontWeight.w100,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: Dashboard(),
                                  duration: Duration(milliseconds: 400),
                                ));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2.5,
                            padding: EdgeInsets.symmetric(
                              vertical: 17,
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
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
