import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:page_transition/page_transition.dart';

import '../home/dashboard.dart';
import '../models/jobModel.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';

class AddScope extends StatefulWidget {
  final String? bookingServiceItemId;
  final PartnerCalendarItem? jobItem;
  AddScope({
    Key? key,
    this.bookingServiceItemId,
    this.jobItem,
  }) : super(key: key);

  @override
  _AddScopeState createState() => _AddScopeState();
}

class _AddScopeState extends State<AddScope> {
  int? extraHours;
  int? maxunits;
  int? minunits = 0;
  double extraWorkCost = 0;
  String? addonUnit;
  TextEditingController _extraWorkController = TextEditingController();
  bool isLoading = false;
  double? unitPrice = 0;

  @override
  void initState() {
    extraHours = widget
        .jobItem!.bookingServiceItem!.bookingService!.service!.addons!.first.minUnit;
    minunits = widget
        .jobItem!.bookingServiceItem!.bookingService!.service!.addons!.first.minUnit;
    maxunits = widget
        .jobItem!.bookingServiceItem!.bookingService!.service!.addons!.first.maxUnit;
    addonUnit = widget
        .jobItem!.bookingServiceItem!.bookingService!.service!.addons!.first.unit
        .toString();
    if (addonUnit != null && addonUnit!.contains('.')) {
      addonUnit = addonUnit!.split('.')[1];
    }
    unitPrice = widget.jobItem!.bookingServiceItem!.bookingService!.service!.addons!
        .first.unitPrice!.total;
//initial cost
    if (unitPrice != null && extraHours != null)
      extraWorkCost = unitPrice! * extraHours!;
    super.initState();
  }

  Future<QueryResult> addAddonMutation(
      String? bookingServiceItemId, double units, String? addonId) async {
    final MutationOptions _options = MutationOptions(
      document: gql(addAddon),
      variables: <String, dynamic>{
        "units": units,
        "bookingServiceItemId": bookingServiceItemId,
        "addonId": addonId
      },
    );
    setState(() {
      isLoading = true;
    });
    final QueryResult addAddonResult =
        await globalGQLClient.value.mutate(_options);
    setState(() {
      isLoading = false;
    });
    if (addAddonResult.hasException) {
      if (addAddonResult.exception!.graphqlErrors != null &&
          addAddonResult.exception!.graphqlErrors.isNotEmpty)
        showCustomDialog(
            'Oops',
            '${addAddonResult.exception!.graphqlErrors.first.message}',
            context,
            null);

      if (addAddonResult.exception!.linkException != null)
        showCustomDialog(
            'Oops',
            '${addAddonResult.exception!.linkException.toString()}',
            context,
            null);
      print(addAddonResult.exception.toString());
    }
    if (addAddonResult != null &&
        addAddonResult.data != null &&
        addAddonResult.data!['addAddon'] != null) {
      print('Add addon job success!!!!!');
      showCustomDialog(
          'Done',
          'You have successfully added additional scope of work to your job.',
          context,
          Dashboard());
    }
    return addAddonResult;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: zimkeyOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: zimkeyWhite,
                size: 18,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            title: Text(
              'Add Scope of Work',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: zimkeyWhite,
              ),
            ),
          ),
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 0),
            color: zimkeyWhite,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Add Extra $addonUnit(s)',
                                  style: TextStyle(
                                    color: zimkeyDarkGrey.withOpacity(1),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  // color: zimkeyLightGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (extraHours! > minunits!)
                                          setState(() {
                                            extraHours = extraHours!+1;
                                            extraWorkCost =
                                                unitPrice! * extraHours!;
                                          });
                                        else {
                                          showCustomDialog(
                                              'Oops!',
                                              'The minimum allowed value is $minunits.',
                                              context,
                                              null);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: zimkeyLightGrey,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: SvgPicture.asset(
                                            'assets/images/icons/newIcons/minus.svg'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '$extraHours',
                                      style: TextStyle(
                                        color: zimkeyDarkGrey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          extraHours = extraHours!+1;
                                          extraWorkCost =
                                              unitPrice! * extraHours!;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: zimkeyLightGrey,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: SvgPicture.asset(
                                            'assets/images/icons/newIcons/add.svg'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: zimkeyLightGrey,
                                borderRadius: BorderRadius.circular(10)
                                // border: Border(
                                //   bottom: BorderSide(
                                //     color: zimkeyDarkGrey.withOpacity(0.3),
                                //   ),
                                // ),
                                ),
                            child: TextFormField(
                              style: TextStyle(
                                color: zimkeyDarkGrey,
                                // fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              controller: _extraWorkController,
                              maxLines: 5,
                              maxLength: 400,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                counterText: '',
                                fillColor: zimkeyOrange,
                                border: InputBorder.none,
                                hintText: 'Add the work description',
                                hintStyle: TextStyle(
                                  color: zimkeyDarkGrey.withOpacity(1),
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                Container(
                  color: zimkeyLightGrey,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'Extra work cost',
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     color: zimkeyDarkGrey.withOpacity(0.7),
                            //     fontFamily: 'Inter',
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 3,
                            // ),
                            Text(
                              'Unit price: ₹${unitPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: zimkeyDarkGrey,
                                fontFamily: 'Inter',
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Total: ₹${extraWorkCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: zimkeyDarkGrey,
                                fontFamily: 'Inter',
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await addAddonMutation(
                              widget.bookingServiceItemId,
                              double.parse(extraHours.toString()),
                              widget.jobItem!.bookingServiceItem!.bookingService!
                                  .service!.addons!.first.id);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 250,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
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
                            'Add',
                            style: TextStyle(
                              fontSize: 14,
                              color: zimkeyWhite,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  showConfirmationDialog(String title, String msg, BuildContext context) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
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
                  padding: EdgeInsets.only(left: 20, top: 15, right: 15),
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
                  padding: EdgeInsets.only(left: 20, right: 15, bottom: 0),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$msg',
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          new InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width - 270,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              decoration: BoxDecoration(
                                color: zimkeyWhite,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  // BoxShadow(
                                  //   color: zimkeyLightGrey.withOpacity(0.1),
                                  //   blurRadius: 5.0, // soften the shadow
                                  //   spreadRadius: 2.0, //extend the shadow
                                  //   offset: Offset(
                                  //     1.0, // Move to right 10  horizontally
                                  //     1.0, // Move to bottom 10 Vertically
                                  //   ),
                                  // )
                                ],
                              ),
                              child: const Text(
                                'No',
                                style: TextStyle(
                                  color: zimkeyDarkGrey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          new InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: Dashboard(),
                                  duration: Duration(milliseconds: 300),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width - 270,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
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
                                'Yes',
                                style: TextStyle(
                                  color: zimkeyWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // actions: <Widget>[],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 250),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {} as Widget Function(BuildContext, Animation<double>, Animation<double>));
  }
}
