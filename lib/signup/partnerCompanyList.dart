import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:recase/recase.dart';

import '../models/partnerModel.dart';
import '../theme.dart';

class PartnerCompanies extends StatefulWidget {
  final List<PartnerCompany>? companies;
  final Function(PartnerCompany comp)? updateCompany;
  PartnerCompanies({
    Key? key,
    this.companies,
    this.updateCompany,
  }) : super(key: key);

  @override
  State<PartnerCompanies> createState() => _PartnerCompaniesState();
}

class _PartnerCompaniesState extends State<PartnerCompanies> {
  TextEditingController _searchCompanyController = TextEditingController();

  bool showDropdown = false;
  bool _showClearIcon = false;
  List<PartnerCompany> _searchResults = [];
  List<PartnerCompany>? dropdownItems = [];
  PartnerCompany? selectedCompany;
  bool showEmptyError = false;

  @override
  void initState() {
    dropdownItems!.clear();
    dropdownItems = widget.companies;
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
                        controller: _searchCompanyController,
                        decoration: InputDecoration(
                          fillColor: zimkeyOrange,
                          border: InputBorder.none,
                          hintText: 'Search for your company here',
                          hintStyle: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.7),
                            // fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            // tapSearch = true;
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
                              if (dropdownItems![i]
                                  .companyName!
                                  .toLowerCase()
                                  .contains(_searchCompanyController.text
                                      .toLowerCase())) {
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
                            }
                          } else {
                            setState(() {
                              showDropdown = false;
                              _searchResults.clear();
                              _showClearIcon = false;
                              showEmptyError = false;
                              showDropdown = true;
                              _searchResults = List.from(dropdownItems!);
                              selectedCompany = null;
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
                            selectedCompany = null;
                            _searchCompanyController.clear();
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
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 1.2,
        child: ListView(
          children: [
            if (_searchResults != null && _searchResults.isNotEmpty)
              for (PartnerCompany comps in _searchResults)
                InkWell(
                  onTap: () {
                    widget.updateCompany!(comps);
                    Get.back();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
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
                        ReCase(comps.companyName!).titleCase,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // trailing: ,
                    ),
                  ),
                ),
            if (_searchResults == null || _searchResults.isEmpty) emptyWidget(),
          ],
        ),
      ),
    );
  }

  Widget emptyWidget() {
    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      color: zimkeyWhite,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset('assets/images/graphics/emptySearch.png'),
          SizedBox(
            height: 20,
          ),
          Text(
            'Looks like your company is not listed below.',
            style: TextStyle(
              color: zimkeyOrange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
