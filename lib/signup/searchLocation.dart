import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:recase/recase.dart';

import '../fbState.dart';
import '../models/partnerModel.dart';
import '../theme.dart';

class SearchLocation extends StatefulWidget {
  final Function? updateSearchArea;
  final Function? goback;
  final List<Area>? areaList;
  const SearchLocation({
    Key? key,
    this.updateSearchArea,
    this.goback,
    this.areaList,
  }) : super(key: key);

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  static TextEditingController _searchAreaController = TextEditingController();
  bool showDropdown = true;
  List<Area> _searchResults = [];
  List<Area>? dropdownItems = [];
  bool _showClearIcon = false;
  bool showEmptyError = false;
  String? selectedArea;
  final FbState fbState = Get.find();
  bool tapSearch = false;

  @override
  void initState() {
    _searchAreaController.text = '';
    selectedArea = '';
    //initiate dropdon list
    dropdownItems!.clear();
    dropdownItems = widget.areaList;
    //duplicate
    if (dropdownItems != null) _searchResults = List.from(dropdownItems!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: zimkeyWhite,
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                if (widget.goback != null) widget.goback!();
                Get.back();
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: zimkeyDarkGrey,
                size: 16,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: zimkeyLightGrey,
                  borderRadius: BorderRadius.circular(25),
                ),
                // width: MediaQuery.of(context).size.width,
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icons/search.svg',
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
                        controller: _searchAreaController,
                        decoration: InputDecoration(
                          fillColor: zimkeyOrange,
                          border: InputBorder.none,
                          hintText: 'Search for your area or pincode',
                          hintStyle: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.7),
                            // fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            tapSearch = true;
                            showDropdown = true;
                            _showClearIcon = true;
                          });
                        },
                        onChanged: (value) {
                          _searchResults.clear();
                          setState(() {
                            _showClearIcon = true;
                          });
                          if (value.isNotEmpty) {
                            for (int i = 0; i < dropdownItems!.length; i++) {
                              if (dropdownItems![i].name!.toLowerCase().contains(
                                  _searchAreaController.text.toLowerCase())) {
                                setState(() {
                                  showEmptyError = false;
                                  showDropdown = true;
                                  _searchResults.add(dropdownItems![i]);
                                  _searchResults =
                                      Set.of(_searchResults).toList();
                                });
                                print(
                                    '!!!!!!!!!searchlist ${_searchResults.length}');
                              }
                              //search by area pincode
                              for (Pincodes thispin
                                  in dropdownItems![i].pincodes!) {
                                if (thispin.pinCode!
                                    .contains(_searchAreaController.text)) {
                                  setState(() {
                                    showEmptyError = false;
                                    showDropdown = true;
                                    _searchResults.add(dropdownItems![i]);
                                    _searchResults =
                                        Set.of(_searchResults).toList();
                                  });
                                }
                              }
                            }
                          } else {
                            setState(() {
                              showDropdown = false;
                              _searchResults.clear();
                              _showClearIcon = false;
                              showEmptyError = false;
                              showDropdown = true;
                              _searchResults = List.from(dropdownItems!);
                              selectedArea = "";
                            });
                            print('CLEARED ${_searchResults.length}');
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
                            showDropdown = false;
                            _searchResults.clear();
                            _searchResults = List.from(dropdownItems!);
                            selectedArea = "";
                            _searchAreaController.clear();
                            _showClearIcon = false;
                            showEmptyError = false;
                            showDropdown = true;
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
            ),
          ],
        ),
      ),
      body: Container(
        color: zimkeyWhite,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Stack(
          children: [
            //search results
            if (showDropdown || !showEmptyError || _searchResults.isNotEmpty)
              Container(
                height: MediaQuery.of(context).size.height / 1.2,
                child: ListView(
                  children: [
                    for (Area item in _searchResults)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedArea = item.name;
                            fbState.setUserLoc(selectedArea!);
                            _searchAreaController.text = selectedArea!;
                            _searchResults = List.from(dropdownItems!);
                            showDropdown = false;
                            FocusScope.of(context).unfocus();
                            showEmptyError = false;
                            widget.updateSearchArea!(item);
                          });
                          Get.back();
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(0),
                            padding: EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                            child: Text(
                              ReCase(item.name!).titleCase,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // trailing: ,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (showEmptyError || _searchResults.isEmpty) emptyWidget(),
          ],
        ),
      ),
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
