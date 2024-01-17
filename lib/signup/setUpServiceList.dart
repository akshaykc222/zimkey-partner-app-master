import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../fbState.dart';
import '../models/partnerModel.dart';
import '../models/serviceModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';
import 'serviceButton.dart';

class SetUpServiceList extends StatefulWidget {
  SetUpServiceList({
    Key? key,
  }) : super(key: key);

  @override
  SetUpServiceListState createState() => SetUpServiceListState();
}

class SetUpServiceListState extends State<SetUpServiceList> {
  bool isLoading = false;
  List<String?> selectedServices = [];
  List<String?> serviceIds = [];
  List<ServiceCategory> serviceCatgegoryList = [];
  final FbState fbState = Get.find();
  PartnerUser? partnerUser;
  List<PartnerPendingTaskEnum> partnerProgressStage = [];
  FirebaseAuth auth = FirebaseAuth.instance;

  //Setup area list
  Future<QueryResult> updatePartnerServicesMutation(
      List<String?> serviceIds) async {
    final MutationOptions _options = MutationOptions(
      document: gql(updatePartnerServices),
      variables: <String, dynamic>{
        'services': serviceIds,
      },
    );
    final QueryResult updateServicesResult =
        await globalGQLClient.value.mutate(_options);
    if (updateServicesResult.hasException) {
      print(updateServicesResult.exception.toString());
      showCustomDialog(
          'Oops!',
          '${updateServicesResult.exception!.graphqlErrors.first.message}',
          context,
          null);
    }
    if (updateServicesResult != null &&
        updateServicesResult.data != null &&
        updateServicesResult.data!['updatePartnerServices'] != null) {
      await getUser(context);
      print('Done!!!!!!!!');
    }
    return updateServicesResult;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: zimkeyWhite,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40.0),
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
                              'Select Services',
                              style: TextStyle(
                                fontSize: 24,
                                color: zimkeyBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Please select services that you would offer.',
                              style: TextStyle(
                                fontSize: 12,
                                color: zimkeyDarkGrey.withOpacity(0.6),
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
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (fbState != null &&
                                      fbState.partnerUser != null &&
                                      fbState.partnerUser.value != null &&
                                      fbState.partnerUser.value!.phone != null &&
                                      fbState
                                          .partnerUser.value!.phone!.isNotEmpty)
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
                  ],
                ),
              ),
            ),
          ),
          body: Query(
              options: QueryOptions(document: gql(getServiceCategories)),
              builder: (
                QueryResult result, {
                VoidCallback? refetch,
                FetchMore? fetchMore,
              }) {
                if (result.isLoading)
                  return Center(child: sharedLoadingIndicator());
                else if (result.data != null &&
                    result.data!['getServiceCategories'] != null) {
                  serviceCatgegoryList.clear();
                  for (Map item in result.data!['getServiceCategories']) {
                    ServiceCategory temp;
                    temp = ServiceCategory.fromJson(item as Map<String, dynamic>);
                    serviceCatgegoryList.add(temp);
                    // print(
                    //     'allServiceCategories \' service  ---- >>>>> ${temp.name}');
                  }
                }
                return Container(
                  color: zimkeyWhite,
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (ServiceCategory item in serviceCatgegoryList)
                                if (item.services != null &&
                                    item.services!.isNotEmpty)
                                  Column(
                                    children: [
                                      //catgeory name
                                      Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 13),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${item.name}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: zimkeyDarkGrey
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //subservices
                                      for (AllServices subServ in item.services!)
                                        ServiceButton(
                                          subServ: subServ,
                                          updateServiceSelection:
                                              (bool selection) {
                                            if (selection) {
                                              setState(() {
                                                selectedServices
                                                    .add(subServ.name);
                                                serviceIds.add(subServ.id);
                                              });
                                            } else {
                                              selectedServices.removeWhere(
                                                  (element) =>
                                                      element!.toLowerCase() ==
                                                      subServ.name!
                                                          .toLowerCase());
                                              setState(() {
                                                serviceIds.removeWhere(
                                                    (element) =>
                                                        element == subServ.id);
                                              });
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                              SizedBox(
                                height: 90,
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
                            if (serviceIds != null && serviceIds.isNotEmpty)
                              await updatePartnerServicesMutation(serviceIds);
                            else
                              showCustomDialog(
                                  'Oops!',
                                  'Please select atleast one service category to proceed',
                                  context,
                                  null);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 15),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width - 390,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                              color: serviceIds != null && serviceIds.isNotEmpty
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
                                color:
                                    serviceIds != null && serviceIds.isNotEmpty
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
                );
              }),
        ),
        if (isLoading)
          Center(
            child: sharedLoadingIndicator(),
          ),
      ],
    );
  }
}
