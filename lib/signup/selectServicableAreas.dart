import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:recase/recase.dart';

import '../fbState.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../theme.dart';

class SelectSearcableAreas extends StatefulWidget {
  final FbState? fbState;
  SelectSearcableAreas({
    Key? key,
    this.fbState,
  }) : super(key: key);

  @override
  _SelectSearcableAreasState createState() => _SelectSearcableAreasState();
}

class _SelectSearcableAreasState extends State<SelectSearcableAreas> {
  List<String?> selectedIds = [];
  bool isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool selectAll = false;
  List<Area> areaMaps = [];
  List<Area> _searchResults = [];
  TextEditingController _searchAreaController = TextEditingController();
  bool _showClearIcon = false;

  @override
  void initState() {
    if (widget.fbState != null && widget.fbState!.areaList != null)
      for (Area area in widget.fbState!.areaList) {
        if (area.isSelected != null) area.isSelected = false;
        areaMaps.add(area);
      }
    _searchResults = areaMaps;
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
            automaticallyImplyLeading: false,
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(85.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Areas',
                              style: TextStyle(
                                fontSize: 24,
                                color: zimkeyBlack,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Tap to set your serviceable areas',
                              style: TextStyle(
                                fontSize: 12,
                                color: zimkeyBlack.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              //unregister devide ID
                              if (fbState.deviceId != null &&
                                  fbState.deviceId.value != null) {
                                await unsetFCMToken(
                                    context, fbState.deviceId.value);
                              }
                              fbState.setUserLoggedIn('false');
                              fbState.setToken('');
                              await auth.signOut().then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                              print('Logged out!!!!!!');
                              Get.toNamed('/login');
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                if (fbState != null &&
                                    fbState.partnerUser != null &&
                                    fbState.partnerUser.value != null &&
                                    fbState.partnerUser.value!.phone != null &&
                                    fbState.partnerUser.value!.phone!.isNotEmpty)
                                  Text(
                                    'Not ${fbState.partnerUser.value!.phone} ?',
                                    style: TextStyle(
                                      color: zimkeyOrange,
                                      fontSize: 10,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  'Back To Login',
                                  style: TextStyle(
                                    color: zimkeyOrange,
                                    fontSize: 10,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                    Row(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          'Search for your area or pincode',
                                      hintStyle: TextStyle(
                                        color: zimkeyDarkGrey.withOpacity(0.7),
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
                                        for (Area itemTile
                                            in widget.fbState!.areaList) {
                                          //search by area name
                                          if (itemTile.name!
                                              .toLowerCase()
                                              .contains(_searchAreaController
                                                  .text
                                                  .toLowerCase())) {
                                            setState(() {
                                              _searchResults.add(itemTile);
                                              _searchResults =
                                                  Set.of(_searchResults)
                                                      .toList();
                                            });
                                            print(
                                                '!!!!!!!!!searchlist ${_searchResults.length}');
                                          }
                                          //search by area pincode
                                          for (Pincodes thispin
                                              in itemTile.pincodes!) {
                                            if (thispin.pinCode!.contains(
                                                _searchAreaController.text)) {
                                              setState(() {
                                                _searchResults.add(itemTile);
                                                _searchResults =
                                                    Set.of(_searchResults)
                                                        .toList();
                                              });
                                            }
                                          }
                                        }
                                      } else {
                                        setState(() {
                                          _searchResults.clear();
                                          _showClearIcon = false;
                                          //Reset
                                          for (Area itemTile
                                              in widget.fbState!.areaList)
                                            _searchResults.add(itemTile);
                                          _searchResults =
                                              List.from(_searchResults);
                                        });
                                        print(
                                            'CLEARED ${_searchResults.length}');
                                      }
                                      //Set the selction of the items
                                      for (Area mapsItem in _searchResults)
                                        for (String? ids in selectedIds)
                                          if (ids == mapsItem.id)
                                            setState(() {
                                              mapsItem.isSelected = true;
                                            });
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
                                      for (Area itemTile
                                          in widget.fbState!.areaList)
                                        _searchResults.add(itemTile);
                                      _searchResults =
                                          List.from(_searchResults);
                                      //Set the selction of the items
                                      for (Area mapsItem in _searchResults) {
                                        for (String? ids in selectedIds) {
                                          if (ids == mapsItem.id)
                                            setState(() {
                                              mapsItem.isSelected = true;
                                            });
                                        }
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
                            selectedIds.clear();
                            _searchResults.clear();
                            if (!selectAll) {
                              for (Area mapsItem in widget.fbState!.areaList)
                                setState(() {
                                  selectedIds.add(mapsItem.id);
                                  mapsItem.isSelected = true;
                                  _searchResults.add(mapsItem);
                                });
                            } else {
                              for (Area mapsItem in widget.fbState!.areaList)
                                setState(() {
                                  mapsItem.isSelected = false;
                                  _searchResults.add(mapsItem);
                                });
                            }
                            setState(() {
                              selectAll = !selectAll;
                            });
                            print(
                                'Select all - $selectAll ---- ${selectedIds.length} ||| _searchResults - ${_searchResults.length}');
                          },
                          child: Text(
                            'Select\nAll',
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
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 0),
                color: zimkeyWhite,
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      if (_searchResults != null && _searchResults.isNotEmpty)
                        Wrap(
                          spacing: 0,
                          runSpacing: 2,
                          children: [
                            for (Area area in _searchResults)
                              InkWell(
                                onTap: () {
                                  //set selection--------
                                  if (area.isSelected != null) {
                                    setState(() {
                                      area.isSelected = !area.isSelected!;
                                    });
                                  } else
                                    setState(() {
                                      area.isSelected = true;
                                    });
                                  //set selction list-----------
                                  if (area.isSelected!)
                                    setState(() {
                                      selectedIds.add(area.id);
                                    });
                                  else
                                    setState(() {
                                      selectedIds.removeWhere(
                                          (element) => element == area.id);
                                    });

                                  //remove duplicates----------
                                  setState(() {
                                    selectedIds = List.from(selectedIds);
                                  });
                                  print(
                                      'selectedIds >>>>> ${selectedIds.length}');
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: area.isSelected != null &&
                                            area.isSelected!
                                        ? zimkeyBodyOrange.withOpacity(0.5)
                                        : zimkeyWhite,
                                    border: Border.all(
                                      color: area.isSelected != null &&
                                              area.isSelected!
                                          ? zimkeyOrange
                                          : zimkeyWhite,
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: zimkeyLightGrey,
                                        blurRadius: 3.0, // soften the shadow
                                        spreadRadius: 4.0, //extend the shadow
                                        offset: Offset(
                                          3.0, // Move to right 10  horizontally
                                          1.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    ReCase(area.name!).titleCase,
                                    style: TextStyle(
                                      color: zimkeyDarkGrey,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      SizedBox(
                        height: 100,
                      ),
                      if (_searchResults == null || _searchResults.isEmpty)
                        emptyWidget(),
                    ],
                  ),
                ),
              ),
              if (_searchResults != null && _searchResults.isNotEmpty)
                Positioned(
                  bottom: 30,
                  left: MediaQuery.of(context).size.width / 4,
                  right: MediaQuery.of(context).size.width / 4,
                  child: InkWell(
                    onTap: () async {
                      if (selectedIds != null && selectedIds.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        var result =
                            await upadteServiceAreasMutation(selectedIds);
                        setState(() {
                          isLoading = false;
                        });
                        if (result != null &&
                            result.data != null &&
                            result.data!['updatePartnerAreas'] != null) {
                          print('success  areas!!!!');
                          await getUser(context);
                        } else {
                          showCustomDialog(
                              'Oops!', 'Some error occured', context, null);
                        }
                      } else {
                        showCustomDialog(
                            'Oops!',
                            'Please select atleast one area before proceeding.',
                            context,
                            null);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 390,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedIds != null && selectedIds.isNotEmpty
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
                          color: selectedIds != null && selectedIds.isNotEmpty
                              ? zimkeyWhite
                              : zimkeyDarkGrey.withOpacity(0.5),
                          fontFamily: 'Inter',
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isLoading) Center(child: sharedLoadingIndicator()),
      ],
    );
  }

  Widget emptyWidget() {
    return Container(
      color: zimkeyWhite,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      alignment: Alignment.topCenter,
      child: Text(
        'Can\'t find your area? No worries.\nSelect the area nearest to your location.\nEg: If you can\'t find \'Ponnurunni\' select \'Vytila\'.',
        style: TextStyle(
          color: zimkeyOrange,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
