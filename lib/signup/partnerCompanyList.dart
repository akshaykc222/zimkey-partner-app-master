import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recase/recase.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:zimkey_partner_app/shared/globalMutations.dart';
import 'package:zimkey_partner_app/shared/gqlQueries.dart';

import '../firebase_options.dart';
import '../models/partnerModel.dart';
import '../notification.dart';
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
  FetchMore? fetchMoreData;
  VoidCallback? refetch1;
  bool hasNextPage = false;
  bool showDropdown = false;
  bool _showClearIcon = false;
  List<PartnerCompany> _searchResults = [];
  List<PartnerCompany>? dropdownItems = [];
  PartnerCompany? selectedCompany;
  bool showEmptyError = false;
  int pageNo = 1;
  bool hasNext = false;

  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    dropdownItems!.clear();
    dropdownItems = widget.companies;
    //duplicate
    if (dropdownItems != null) _searchResults = List.from(dropdownItems!);

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasNextPage) {
          pageNo++;
          fetchMoreData!(FetchMoreOptions(
            variables: {
              'pageSize': 30,
              'pageNumber': pageNo,
            },
            updateQuery: (previousResultData, fetchMoreResultData) {
              // Update the existing data with new data
              final List<dynamic> newData =
                  fetchMoreResultData!['getJobBoard']['data'];
              return {
                'getJobBoard': {
                  'data': [...newData]
                }
              };
            },
          ));
        }
      }
    });
    super.initState();
  }
  search(String s) async {
    print("Search started with $s");
  var data = await  getCompanies(s);
  print("Search results ${data.length}");
  _searchResults.clear();
  _searchResults.addAll(data);
  setState(() {


  });
  }
  String _searchTerm="";

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getPartnerCompanies),
          variables: {
            'pageSize': 30,
            'pageNumber': pageNo,
            'companyName': _searchTerm
          },
        ),
        builder: (
          QueryResult result, {
          VoidCallback? refetch,
          FetchMore? fetchMore,
        }) {
          refetch1 = refetch!;
          fetchMoreData = fetchMore;
          // _searchResults.clear();
          // print("ere" + result.data!['getPartnerCompanies'].toString());
          for (Map comps
              in (result.data?['getPartnerCompanies']['data'] ?? [])) {
            PartnerCompany temp;
            temp = PartnerCompany.fromJson(comps as Map<String, dynamic>);
            _searchResults.add(temp);
          }
         _searchResults= _searchResults.toSet().toList();
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
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 0, bottom: 0),
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
                                search(value);
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
                                _searchTerm="";
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
            body: result.isLoading && _searchResults.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    color: zimkeyWhite,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.2,
                    child: ListView.builder(
                      controller: scrollController,
                        physics: BouncingScrollPhysics(),
                        itemCount: _searchResults.length+1,
                        shrinkWrap: true,
                        itemBuilder: (context,index) {
                        if(index>=_searchResults.length){
                          return result.isLoading? Center(child: CircularProgressIndicator(),):SizedBox();
                        }else{
                          var comps = _searchResults[index];
                          return InkWell(
                            onTap: () {
                              widget.updateCompany!(comps);
                              Get.back();
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
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
                          );
                        }

                        }),
                  ),
          );
        });
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
          SvgPicture.asset('assets/images/icons/newIcons/information.svg'),
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
