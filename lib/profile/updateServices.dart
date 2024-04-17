import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:recase/recase.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/serviceModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../theme.dart';

class UpdateServices extends StatefulWidget {
  final FbState? fbState;
  UpdateServices({
    Key? key,
    this.fbState,
  }) : super(key: key);

  @override
  State<UpdateServices> createState() => _UpdateServicesState();
}

class _UpdateServicesState extends State<UpdateServices> {
  List<AllServices>? partnerServices = [];
  bool isloading = false;
  List<String?> selectedServiceIds = [];
  List<ServiceCategory> serviceCatgegoryList = [];
  TextEditingController _searchAreaController = TextEditingController();
  bool _showClearIcon = false;

  List<AllServices> serviceMap = [];
  List<AllServices> _searchResults = [];
  bool selectAll = false;

  @override
  void initState() {
    if (widget.fbState != null &&
        widget.fbState!.partnerUser != null &&
        widget.fbState!.partnerUser.value != null &&
        widget.fbState!.partnerUser.value!.partnerDetails != null &&
        widget.fbState!.partnerUser.value!.partnerDetails!.services != null &&
        widget.fbState!.partnerUser.value!.partnerDetails!.services!.isNotEmpty)
      partnerServices =
          widget.fbState!.partnerUser.value!.partnerDetails!.services;

    //get all services-----
    if (widget.fbState != null &&
        widget.fbState!.allServiceCatg != null &&
        widget.fbState!.allServiceCatg.isNotEmpty) {
      for (ServiceCategory catg in widget.fbState!.allServiceCatg) {
        for (AllServices subServ in catg.services!) {
          for (AllServices selectedOne in partnerServices!) {
            if (selectedOne.id == subServ.id) subServ.isSelected = true;
          }
          serviceMap.add(subServ);
        }
        serviceCatgegoryList.add(catg);
      }
    }
    if (partnerServices!.length == serviceMap.length) selectAll = true;
    //---------
    _searchResults = serviceMap;
    _searchResults.sort((a, b) {
      if (b.isSelected == true) {
        return 1;
      }
      return -1;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: zimkeyWhite,
            elevation: 0,
            automaticallyImplyLeading: true,
            centerTitle: false,
            iconTheme: IconThemeData(
              color: zimkeyDarkGrey,
              size: 20,
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Your Services',
                              style: TextStyle(
                                fontSize: 18,
                                color: zimkeyBlack,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Tap to select or unselect your services offered',
                              style: TextStyle(
                                fontSize: 12,
                                color: zimkeyBlack.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
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
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: zimkeyLightGrey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                left: 7,
                                right: 7,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/icons/search.svg',
                                    color: zimkeyDarkGrey,
                                    width: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: zimkeyDarkGrey,
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      controller: _searchAreaController,
                                      decoration: InputDecoration(
                                        fillColor: zimkeyOrange,
                                        border: InputBorder.none,
                                        hintText:
                                            'Search for your service here',
                                        hintStyle: TextStyle(
                                          color:
                                              zimkeyDarkGrey.withOpacity(0.7),
                                          // fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            _showClearIcon = true;
                                            _searchResults.clear();
                                          });
                                          for (AllServices servItem
                                              in fbState.allServices) {
                                            //search by area name
                                            if (servItem.name!
                                                .toLowerCase()
                                                .contains(_searchAreaController
                                                    .text
                                                    .toLowerCase())) {
                                              setState(() {
                                                _searchResults.add(servItem);
                                                _searchResults =
                                                    Set.of(_searchResults)
                                                        .toList();
                                              });
                                              print(
                                                  '!!!!!!!!!searchlist ${_searchResults.length}');
                                            }
                                          }
                                        } else {
                                          setState(() {
                                            _searchResults.clear();
                                            _showClearIcon = false;
                                            //Reset
                                            for (AllServices servItem
                                                in fbState.allServices)
                                              _searchResults.add(servItem);
                                            _searchResults =
                                                List.from(_searchResults);
                                          });
                                          print(
                                              'CLEARED ${_searchResults.length}');
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (_showClearIcon)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _searchResults.clear();
                                        });
                                        //Reset
                                        for (AllServices servItem
                                            in fbState.allServices) {
                                          setState(() {
                                            _searchResults.add(servItem);
                                            _searchResults =
                                                List.from(_searchResults);
                                          });
                                        }
                                        _searchAreaController.clear();
                                        _showClearIcon = false;
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
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              // selectedIds.clear();
                              _searchResults.clear();
                              if (!selectAll) {
                                for (AllServices servItem
                                    in fbState.allServices)
                                  setState(() {
                                    // selectedIds.add(mapsItem.id);
                                    servItem.isSelected = true;
                                    _searchResults.add(servItem);
                                  });
                              } else {
                                for (AllServices servItem
                                    in fbState.allServices)
                                  setState(() {
                                    servItem.isSelected = false;
                                    _searchResults.add(servItem);
                                  });
                              }
                              setState(() {
                                selectAll = !selectAll;
                              });
                              // print(
                              // 'Select all - $selectAll ---- ${selectedIds.length} ||| _searchResults - ${_searchResults.length}');
                            },
                            child: Text(
                              selectAll ? 'Deselect\nAll' : 'Select\nAll',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: selectAll
                                    ? zimkeyOrange
                                    : zimkeyDarkGrey.withOpacity(0.7),
                                fontSize: 13,
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
          ),
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                color: zimkeyWhite,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 0,
                        runSpacing: 2,
                        children: [
                          for (AllServices servItems in _searchResults)
                            InkWell(
                              onTap: () {
                                if (servItems.isSelected != null)
                                  setState(() {
                                    servItems.isSelected =
                                        !servItems.isSelected!;
                                  });
                                else
                                  setState(() {
                                    servItems.isSelected = true;
                                  });
                                for (AllServices items in fbState.allServices) {
                                  if (items.id == servItems.id)
                                    setState(() {
                                      items.isSelected = servItems.isSelected;
                                    });
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: servItems.isSelected != null &&
                                            servItems.isSelected!
                                        ? zimkeyBodyOrange
                                        : zimkeyWhite,
                                    borderRadius: BorderRadius.circular(7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: zimkeyLightGrey,
                                        blurRadius: 5.0, // soften the shadow
                                        spreadRadius: 2.0, //extend the shadow
                                        offset: Offset(
                                          3.0, // Move to right 10  horizontally
                                          4.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                    border: Border.all(
                                      color: servItems.isSelected != null &&
                                              servItems.isSelected!
                                          ? zimkeyOrange.withOpacity(0.5)
                                          : zimkeyLightGrey,
                                    )),
                                child: Text(
                                  ReCase(servItems.name!).originalText,
                                  style: TextStyle(
                                    color: zimkeyDarkGrey.withOpacity(1),
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: MediaQuery.of(context).size.width / 4,
                right: MediaQuery.of(context).size.width / 4,
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      isloading = true;
                    });
                    selectedServiceIds.clear();
                    for (AllServices allserv in _searchResults) {
                      if (allserv.isSelected != null && allserv.isSelected!)
                        setState(() {
                          selectedServiceIds.add(allserv.id);
                        });
                    }
                    print("working upto here");
                    if (selectedServiceIds.isNotEmpty) {
                      setState(() {
                        isloading = false;
                      });
                      print("working upto here");
                      confirmUpdateService('Confirm',
                          "Are you sure you want to update your services?");
                    } else {
                      setState(() {
                        isloading = false;
                      });
                      showCustomDialog(
                          'Oops!',
                          "Kindly select atleast one service to update",
                          context,
                          null);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 200,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: zimkeyOrange,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      "Update",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: zimkeyWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isloading)
          Center(
            child: sharedLoadingIndicator(),
          ),
      ],
    );
  }

  confirmUpdateService(String title, String msg) {
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
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$msg',
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            setState(() {
                              isloading = false;
                            });
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: zimkeyOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () async {
                        var servicesResult =
                            await updatePartnerServicesMutation(
                                selectedServiceIds);
                        setState(() {
                          isloading = false;
                        });
                        if (servicesResult != null &&
                            servicesResult.data != null &&
                            servicesResult.data!['updatePartnerServices'] !=
                                null) {
                          print('success  services!!!!');
                          Get.back();
                          Future.delayed(Duration(seconds: 3), () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: Dashboard(
                                  index: 3,
                                ),
                                duration: Duration(milliseconds: 300),
                              ),
                            );
                          });
                          showCustomDialog(
                            'Done!',
                            'Your services have been updated successfully!',
                            context,
                            Dashboard(
                              index: 3,
                            ),
                          );
                        } else if (servicesResult.hasException) {
                          showCustomDialog(
                              'Oops',
                              'Some exception has occured - ${servicesResult.exception!.graphqlErrors.first.message}',
                              context,
                              null);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            color: zimkeyOrange,
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
        );
      },
    );
  }
}
