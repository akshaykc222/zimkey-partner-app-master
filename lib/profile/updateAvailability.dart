import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';

class EditAvailability extends StatefulWidget {
  const EditAvailability({Key? key}) : super(key: key);

  @override
  _EditAvailabilityState createState() => _EditAvailabilityState();
}

class _EditAvailabilityState extends State<EditAvailability> {
  TextEditingController _nextDate = TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(
      mask: '##-##-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  bool filledDate = false;

  int? selectedValue;
  OverlayEntry? overlayEntry;
  bool validEmail = true;
  bool validAadhar = false;
  bool showError = false;
  bool isLoading = false;
  bool? isopen = false;
  String unavailableTill = "dd/mm/yyyy";

  @override
  void initState() {
    if (fbState.partnerUser != null &&
        fbState.partnerUser.value != null &&
        fbState.partnerUser.value!.partnerDetails != null)
      isopen = fbState.partnerUser.value!.partnerDetails!.isAvailable;
    print(
        "unable from ${fbState.partnerUser.value!.partnerDetails!.unavailableTill}");
    if (fbState.partnerUser.value!.partnerDetails!.unavailableTill != null) {
      unavailableTill = DateFormat('dd/MM/yyyy')
          .format(fbState.partnerUser.value!.partnerDetails!.unavailableTill!);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double? bottom;

  @override
  Widget build(BuildContext context) {
    bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: zimkeyBgWhite,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: zimkeyDarkGrey,
          size: 18,
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.chevron_left,
            color: zimkeyDarkGrey,
            size: 30,
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: zimkeyBgWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Container(
            color: zimkeyWhite,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text(
                      'Update Availability',
                      style: TextStyle(
                        fontSize: 18,
                        color: zimkeyBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                          color: isopen!
                              ? zimkeyGreen.withOpacity(0.3)
                              : zimkeyDarkGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        isopen! ? 'Open' : 'Not available',
                        style: TextStyle(
                          fontSize: 12,
                          color: isopen!
                              ? Colors.green[900]
                              : zimkeyDarkGrey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 3,
                // ),
                // Text(
                //   'Update your profile details.',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: zimkeyBlack.withOpacity(0.6),
                //   ),
                // ),
                SizedBox(
                  height: 7,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: zimkeyBlack.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            // child: SingleChildScrollView(
            //   reverse: false,
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 0,
                    ),
                    isopen!
                        ? Text(
                            'How long will you be unavailable for?',
                            style: TextStyle(
                              fontSize: 13,
                              color: zimkeyOrange,
                            ),
                          )
                        : Query(
                            options: QueryOptions(
                              document: gql(getMe),
                            ),
                            builder: (
                              QueryResult result, {
                              VoidCallback? refetch,
                              FetchMore? fetchMore,
                            }) {
                              PartnerUser tempUser;
                              tempUser =
                                  PartnerUser.fromJson(result.data!['me']);

                              return Text(
                                'Your account is inactive till ${DateFormat("dd-MM-yyyy").format(tempUser.partnerDetails?.unavailableTill ?? DateTime.now())}.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: zimkeyOrange,
                                    fontWeight: FontWeight.bold),
                              );
                            }),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    if (isopen!)
                      Container(
                        margin: EdgeInsets.only(bottom: 10, top: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: zimkeyDarkGrey2.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/newIcons/calendar.svg',
                              height: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _nextDate,
                                //editing controller of this TextField
                                readOnly: true,
                                //set it true, so that user will not able to edit text
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        'Unavailable till - Tap to select date',
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0)),

                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: zimkeyDarkGrey,
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  );
                                  if (pickedDate != null) {
                                    print(
                                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);
                                    print(
                                        formattedDate); //formatted date output using intl package =>  2021-03-16
                                    setState(() {
                                      _nextDate.text =
                                          formattedDate; //set output date to TextField value.
                                      filledDate = true;
                                    });
                                  } else {
                                    setState(() {
                                      filledDate = false;
                                    });
                                  }
                                },
                              ),
                            ),
                            // Expanded(
                            //   child: Stack(
                            //     children: [
                            //       if (_nextDate.text.isEmpty)
                            //         Container(
                            //           padding: EdgeInsets.symmetric(vertical: 5),
                            //           width: double.infinity,
                            //           child: Text('$unavailableTill'),
                            //         ),
                            //       // Positioned(
                            //       //   left: 0,
                            //       //   right: 0,
                            //       //   top: 0,
                            //       //   child:
                            //       // ),
                            //     ],
                            //   ),
                            // ),
                            // Expanded(
                            //   child: DateTimePicker(
                            //     controller: _nextDate,
                            //     firstDate: DateTime(DateTime.now().day + 1),
                            //     lastDate: DateTime(DateTime.now().year + 1),
                            //     dateLabelText:
                            //         'Enter Next Availability Date - dd/mm/yyyy',
                            //     fieldLabelText:
                            //         'Enter  Next Availability Date - dd/mm/yyyy',
                            //     style: TextStyle(
                            //       fontSize: 13,
                            //       color: zimkeyDarkGrey,
                            //     ),
                            //     onChanged: (val) {
                            //       if (val.isNotEmpty) {
                            //         setState(() {
                            //           filledDate = true;
                            //         });
                            //       } else
                            //         setState(() {
                            //           filledDate = false;
                            //         });
                            //     },
                            //     validator: (val) {
                            //       print(val);
                            //       return null;
                            //     },
                            //     decoration: InputDecoration(
                            //       border: InputBorder.none,
                            //     ),
                            //     textInputAction: TextInputAction.done,
                            //     onSaved: (val) => print(val),
                            //   ),
                            // ),
                            SizedBox(
                              width: 20,
                            ),
                            if (filledDate)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _nextDate.clear();
                                    filledDate = false;
                                  });
                                },
                                child: Icon(
                                  Icons.clear,
                                  size: 15,
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () async {
                        QueryResult? availResult;
                        if (!isopen!) {
                          setState(() {
                            isLoading = true;
                          });
                          availResult =
                              await updatePartnerUnavailableMutation(null);
                          setState(() {
                            isLoading = false;
                          });
                          if (availResult != null &&
                              availResult.data != null &&
                              availResult.data!['updatePartnerUnavailable'] !=
                                  null) {
                            showCustomDialog(
                              'Done!',
                              "Your status has been updated to AVAILABLE.",
                              context,
                              Dashboard(
                                index: 3,
                              ),
                            );
                          }
                        } else if (isopen! && _nextDate.text.isNotEmpty) {
                          DateTime datetemp =
                              DateFormat('dd-MM-yyyy').parse(_nextDate.text);
                          String thedate = datetemp.toIso8601String();
                          setState(() {
                            isLoading = true;
                          });
                          availResult =
                              await updatePartnerUnavailableMutation(thedate);
                          setState(() {
                            isLoading = false;
                          });
                          if (availResult != null &&
                              availResult.data != null &&
                              availResult.data!['updatePartnerUnavailable'] !=
                                  null) {
                            showCustomDialog(
                              'Done!',
                              "Your status has been updated to UNAVAILABLE till ${_nextDate.text}.",
                              context,
                              Dashboard(
                                index: 3,
                              ),
                            );
                          }
                        } else if (_nextDate.text.isEmpty) {
                          showCustomDialog(
                            'Oops!',
                            "Kindly select a date first.",
                            context,
                            null,
                          );
                        }
                        if (availResult != null && availResult.hasException) {
                          if (availResult.exception != null &&
                              availResult.exception!.graphqlErrors != null &&
                              availResult.exception!.graphqlErrors.isNotEmpty &&
                              availResult.exception!.graphqlErrors[0].message !=
                                  null)
                            showCustomDialog(
                                'Oops!',
                                "${availResult.exception!.graphqlErrors[0].message}",
                                context,
                                null);
                          else
                            showCustomDialog('Oops!', "Something went wrong.",
                                context, null);
                        }
                      },
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              vertical: 13, horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: zimkeyOrange,
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
                            isopen! ? 'Set to Unavailable' : 'Set to Available',
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
            // ),
          ),
          if (isLoading)
            Center(
              child: sharedLoadingIndicator(),
            ),
        ],
      ),
    );
  }
}
