import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:recase/recase.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../theme.dart';

class UpdateServiceAreas extends StatefulWidget {
  final FbState? fbState;
  final List<Area>? partnerAreas;
  UpdateServiceAreas({
    Key? key,
    this.fbState,
    this.partnerAreas,
  }) : super(key: key);

  @override
  State<UpdateServiceAreas> createState() => _UpdateServiceAreasState();
}

class _UpdateServiceAreasState extends State<UpdateServiceAreas> {
  List<Area>? selectedAreas = [];
  List<Area> tempAreas = [];
  bool showSearchList = false;
  bool isloading = false;
  PartnerUser? userdetails;
  List<String?> selectedIds = [];
  bool isLoading = false;
  bool selectAll = false;
  List<Area> areaMaps = [];
  List<Area> _searchResults = [];
  TextEditingController _searchAreaController = TextEditingController();
  bool _showClearIcon = false;

  @override
  void initState() {
    //Already selected areas---------
    selectedAreas = widget.partnerAreas;
    //Load all areas list-----------
    if (widget.fbState != null && widget.fbState!.areaList != null)
      for (Area area in widget.fbState!.areaList) {
        for (Area partnerAreaItem in selectedAreas!) {
          if (partnerAreaItem.id == area.id) {
            area.isSelected = true;
            selectedIds.add(area.id);
          }
        }
        areaMaps.add(area);
      }
    _searchResults = areaMaps;
    if (selectedIds.length == _searchResults.length) selectAll = true;
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
                              'Update Your Service Areas',
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
                              'Tap to select or unselect your serviceable areas',
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
                                            'Search for your area or pincode',
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
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: area.isSelected != null &&
                                            area.isSelected!
                                        ? zimkeyBodyOrange.withOpacity(0.5)
                                        : zimkeyWhite,
                                    border: Border.all(
                                      color: area.isSelected != null &&
                                              area.isSelected!
                                          ? zimkeyOrange.withOpacity(0.5)
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
                  bottom: 10,
                  right: MediaQuery.of(context).size.width / 4,
                  left: MediaQuery.of(context).size.width / 4,
                  child: InkWell(
                    onTap: () async {
                      print("selected ${selectedIds.length}");
                      if (selectedIds.isNotEmpty) {
                        confirmUpdateAreas('Confirm',
                            'Are you sure you want to update your service areas?');
                      } else {
                        showCustomDialog(
                            'Oops!',
                            'Please select atleast one area before proceeding.',
                            context,
                            null);
                      }
                    },
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 2.5,
                        padding: EdgeInsets.symmetric(
                          vertical: 17,
                        ),
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
                          'Update',
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedIds != null && selectedIds.isNotEmpty
                                ? zimkeyWhite
                                : zimkeyDarkGrey.withOpacity(0.5),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
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

  confirmUpdateAreas(String title, String msg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                              onTap: () => Get.back(),
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
                                  'Yay!',
                                  "Your service areas have been updated successfully!",
                                  context,
                                  Dashboard(
                                    index: 3,
                                  ));
                              // await getUser(context);
                            } else {
                              showCustomDialog(
                                  'Oops!', 'Some error occured', context, null);
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
            ));
  }

  //Empty Widget-------
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
