import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../home/dashboard.dart';
import '../../jobBoard/models/job_board_model.dart';
import '../../shared/globalMutations.dart';
import '../../shared/globals.dart';
import '../../theme.dart';

class StartJob extends StatefulWidget {
  final String msg;
  final PartnerCalendarItem item;
  const StartJob({super.key, required this.msg, required this.item});

  @override
  State<StartJob> createState() => _StartJobState();
}

class _StartJobState extends State<StartJob> {
  var showClearIcon = false;
  final _workCode = TextEditingController();

  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${widget.msg}',
            style: TextStyle(
              color: zimkeyDarkGrey,
              fontSize: 14,
            ),
          ),
          Text(
            'Work Code - ${widget.item!.bookingServiceItem!.workCode} (For testing only)',
            style: TextStyle(
              color: zimkeyOrange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              color: zimkeyLightGrey,
              borderRadius: BorderRadius.circular(5),
            ),
            // width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/images/icons/newIcons/privacy.svg',
                  color: zimkeyDarkGrey,
                  width: 18,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    style: TextStyle(
                      color: zimkeyDarkGrey,
                      // fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLength: 4,
                    textCapitalization: TextCapitalization.characters,
                    controller: _workCode,
                    decoration: InputDecoration(
                      counterText: '',
                      fillColor: zimkeyOrange,
                      border: InputBorder.none,
                      hintText: 'Enter job verification code',
                      hintStyle: TextStyle(
                        color: zimkeyDarkGrey.withOpacity(0.7),
                        // fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onChanged: (value) {
                      if (_workCode.text.isNotEmpty)
                        setState(() {
                          showClearIcon = true;
                        });
                      else
                        setState(() {
                          showClearIcon = false;
                        });
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                if (showClearIcon)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _workCode.clear();
                        showClearIcon = false;
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: zimkeyDarkGrey,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : InkWell(
                  onTap: () async {
                    if (_workCode.text.isNotEmpty) {
                      // Navigator.pop(context);
                      setState(() {
                        isLoading = true;
                      });
                      QueryResult startJobResult = await startJobMutation(
                        widget.item.bookingServiceItem!.id,
                        _workCode.text,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      Get.back();
                      if (startJobResult != null &&
                          startJobResult.data != null &&
                          startJobResult.data!['startJob'] != null) {
                        print('start job success!!!!!');
                        showCustomDialog(
                          'Yay!',
                          'Your job has started successfully. Kindly check the in-progress tab for all ongoing job details.',
                          context,
                          Dashboard(
                            index: 2,
                            tabIndex: 1,
                          ),
                        );
                      }
                      if (startJobResult.hasException) {
                        if (startJobResult.exception!.graphqlErrors.isNotEmpty)
                          showCustomDialog(
                              'Oops',
                              '${startJobResult.exception!.graphqlErrors.first.message}',
                              context,
                              null);

                        if (startJobResult.exception!.linkException != null)
                          showCustomDialog(
                              'Oops',
                              '${startJobResult.exception!.linkException.toString()}',
                              context,
                              null);
                      }
                    }
                  },
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 2,
                      padding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 10),
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
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: zimkeyWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
