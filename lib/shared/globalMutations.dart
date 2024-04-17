import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:page_transition/page_transition.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../login/login.dart';
import '../models/partnerModel.dart';
import '../models/serviceModel.dart';
import '../signup/selectServicableAreas.dart';
import '../signup/setUpServiceList.dart';
import '../signup/signUpDetails.dart';
import '../signup/uploadDProfilePic.dart';
import '../signup/uploadDocuments.dart';
import 'globals.dart';
import 'gqlQueries.dart';

final FbState fbState = Get.find();
List<PartnerPendingTaskEnum?>? partnerProgressStage = [];

final deviceInfoPlugin = DeviceInfoPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;
String? _token;
late var deviceMap;

//Get me --------

Future<List<PartnerCompany>> getCompanies(String s) async {
  List<PartnerCompany> companyList = [];
  final MutationOptions _options = MutationOptions(
    document: gql(getPartnerCompanies),
    variables: {
      'pageSize': 30,
      'pageNumber': 1,
      'companyName': s
    },
  );
  final QueryResult loggedInUser = await globalGQLClient.value.mutate(_options);
  if (loggedInUser.hasException) {
    print('Getuser exception >>> ${loggedInUser.exception.toString()}');
  }
  if (loggedInUser.data != null ) {
    for (Map comps
    in (loggedInUser.data?['getPartnerCompanies']['data'] ?? [])) {
      PartnerCompany temp;
      temp = PartnerCompany.fromJson(comps as Map<String, dynamic>);
      companyList.add(temp);
    }
  }
  companyList =companyList.toSet().toList();
  return companyList;
}
checkUser() async {
  PartnerUser partnerUser;
  final MutationOptions _options = MutationOptions(
    document: gql(getMe),
  );
  final QueryResult loggedInUser = await globalGQLClient.value.mutate(_options);
  if (loggedInUser.hasException) {
    print('Getuser exception >>> ${loggedInUser.exception.toString()}');
  }
  if (loggedInUser != null &&
      loggedInUser.data != null &&
      loggedInUser.data!['me'] != null) {
    print('logged in user ');
    partnerUser = PartnerUser.fromJson(loggedInUser.data!['me']);
    fbState.setPartnerUser(partnerUser);
  }
}

Future<QueryResult> getUser(BuildContext context) async {
  PartnerUser partnerUser;
  final MutationOptions _options = MutationOptions(
    document: gql(getMe),
  );
  final QueryResult loggedInUser = await globalGQLClient.value.mutate(_options);
  if (loggedInUser.hasException) {
    print('Getuser exception >>> ${loggedInUser.exception.toString()}');
  }
  if (loggedInUser != null &&
      loggedInUser.data != null &&
      loggedInUser.data!['me'] != null) {
    print('logged in user ');
    partnerUser = PartnerUser.fromJson(loggedInUser.data!['me']);
    fbState.setPartnerUser(partnerUser);
    fbState.setIsRegistered(partnerUser.isPartnerRegistered.toString());
    if (partnerUser != null && partnerUser.isPartnerRegistered!) {
      if (partnerUser.userType!.toLowerCase() != "customer" &&
          partnerUser.partnerDetails != null) {
        //Check Partner progress
        partnerProgressStage!.clear();
        if (partnerUser.partnerDetails != null &&
            partnerUser.partnerDetails!.pendingTasks != null &&
            partnerUser.partnerDetails!.pendingTasks!.isNotEmpty) {
          partnerProgressStage = partnerUser.partnerDetails!.pendingTasks;
          fbState.setPartnerProgress(partnerProgressStage!);
          String stage = partnerProgressStage![0].toString();
          if (stage.isNotEmpty && stage.contains('.'))
            stage = stage.split('.')[1];
          switch (stage) {
            case 'UPLOAD_PROFILE_PICTURE':
              {
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: UploadProfilePic(),
                      duration: Duration(milliseconds: 400),
                    ));
                break;
              }
            case 'SELECT_SERVICE':
              {
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: SetUpServiceList(),
                      duration: Duration(milliseconds: 400),
                    ));
                break;
              }
            case 'SELECT_AREA':
              {
                await getAreasQuery();
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: SelectSearcableAreas(
                        fbState: fbState,
                      ),
                      duration: Duration(milliseconds: 400),
                    ));
                break;
              }
            case 'UPLOAD_DOCUMENT':
              {
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: UploadDocuments(),
                      duration: Duration(milliseconds: 400),
                    ));
                break;
              }
          }
        } else
          //no pending tasks---------
          Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: Dashboard(
                  index: 0,
                ),
                duration: Duration(milliseconds: 400),
              ));
      } else
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: SignUpDetails(
                fbstate: fbState,
              ),
              duration: Duration(milliseconds: 400),
            ));
    } else {
      //parner not yet registered---------
      Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: SignUpDetails(
              fbstate: fbState,
            ),
            duration: Duration(milliseconds: 400),
          ));
    }
  } else {
    if (loggedInUser.hasException)
      print('Get me exception - ${loggedInUser.exception}');
    showCustomDialog(
        'Ooops!',
        'Some error fetching partner details. Try after sometime.',
        context,
        Login());
  }
  return loggedInUser;
}

Future<QueryResult> getAreasQuery() async {
  List<Area> arealist = [];
  final MutationOptions _options = MutationOptions(
    document: gql(getAreas),
  );
  final QueryResult areasResult = await globalGQLClient.value.mutate(_options);
  if (areasResult.hasException) {
    print(areasResult.exception.toString());
  }
  if (areasResult != null &&
      areasResult.data != null &&
      areasResult.data!['getAreas'] != null) {
    arealist.clear();
    for (Map areaitems in areasResult.data!['getAreas']) {
      Area temp;
      temp = Area.fromJson(areaitems as Map<String, dynamic>);
      // temp.pincodes = pincodeList;
      arealist.add(temp);
    }
    fbState.setAreaList(arealist);
    print('success  areas!!!!');
  }
  return areasResult;
}

Future<QueryResult> setFCMToken(
    String? device, String? deviceId, String? token) async {
  final MutationOptions _options = MutationOptions(
    fetchPolicy: FetchPolicy.noCache,
    document: gql(registerFcmToken),
    variables: {
      "device": device != null ? device.toUpperCase() : "",
      "deviceId": deviceId,
      "token": token,
    },
  );
  final QueryResult registerFCMResult =
      await globalGQLClient.value.mutate(_options);
  if (registerFCMResult.hasException) {
    print('Register FCM >>>>> ${registerFCMResult.exception.toString()}');
    // showCustomDialog('Oops!', '${registerFCMResult.exception.toString()}',
    //     context, false, null);
  }
  if (registerFCMResult != null &&
      registerFCMResult.data != null &&
      registerFCMResult.data!['registerFcmToken'] != null &&
      registerFCMResult.data!['registerFcmToken']) {
    print('success FCM!!!!!');
  }
  return registerFCMResult;
}

Future<QueryResult> unsetFCMToken(BuildContext context, String deviceId) async {
  final MutationOptions _options = MutationOptions(
    document: gql(unregisterFcmToken),
    variables: {
      "deviceId": deviceId,
    },
  );
  final QueryResult unregisterFCMResult =
      await globalGQLClient.value.mutate(_options);
  if (unregisterFCMResult.hasException) {
    print('Unregister FCM >>>>> ${unregisterFCMResult.exception.toString()}');
    // showCustomDialog('Oops!', '${registerFCMResult.exception.toString()}',
    //     context, false, null);
  }
  if (unregisterFCMResult != null &&
      unregisterFCMResult.data != null &&
      unregisterFCMResult.data!['unregisterFcmToken'] != null) {
    print('success unregsiter FCM!!!!! ${unregisterFCMResult.data}');
  }
  return unregisterFCMResult;
}

Future<QueryResult> upadteServiceAreasMutation(
    List<String?> selectedIds) async {
  final MutationOptions _options = MutationOptions(
    document: gql(updatePartnerAreas),
    variables: {
      'areas': selectedIds,
    },
  );
  final QueryResult areasResult = await globalGQLClient.value.mutate(_options);
  if (areasResult.hasException) {
    print(areasResult.exception.toString());
  }
  if (areasResult != null &&
      areasResult.data != null &&
      areasResult.data!['updatePartnerAreas'] != null) {
    print('success  areas!!!!');
  }
  return areasResult;
}

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
  }
  if (updateServicesResult != null &&
      updateServicesResult.data != null &&
      updateServicesResult.data!['updatePartnerServices'] != null) {
    // await getUser(context);
    print('Done!!!!!!!!');
  }
  return updateServicesResult;
}

Future<void> saveTokenToDatabase(String? token) async {
  String? deviceType, deviceID;
  deviceType = deviceMap['systemName'];
  if (deviceType != null && deviceType.toLowerCase() == 'ios')
    deviceID = deviceMap['identifierForVendor'];
  else
    deviceID = deviceMap['id'];
  fbState.setDeviceID(deviceID!);
  //Callregister FCM token
  QueryResult fcmResult = await setFCMToken(deviceType, deviceID, token);
  if (fcmResult != null &&
      !fcmResult.hasException &&
      fcmResult.data!['registerFcmToken'] != null &&
      fcmResult.data!['registerFcmToken']) {
    print('FCM SUCESSSS!!!!!');
  }
}

getDeviceInfo() async {
  //Device Info------
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  deviceMap = deviceInfo.toMap();
  // fbState.setDeviceID(deviceMap['identifierForVendor']);
  // print('deviceMap --->   $deviceMap');
}

setupMessaging() async {
  // Get the token each time the application loads
  String? token = await FirebaseMessaging.instance.getToken();

  // Save the initial token to the database
  await saveTokenToDatabase(token);

  // Any time the token refreshes, store this in the database too.
  FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');
}

Future<QueryResult> approvePendingJob(
    String? bookingServiceItemId, bool sts) async {
  final MutationOptions _options = MutationOptions(
    document: gql(approveJob),
    variables: {"bookingServiceItemId": bookingServiceItemId, "status": sts},
  );
  final QueryResult apprveJobResult =
      await globalGQLClient.value.mutate(_options);
  print(apprveJobResult);
  if (apprveJobResult.hasException) {
    print('Approve Job Excption >>>>> ${apprveJobResult.exception.toString()}');
  }
  if (apprveJobResult != null &&
      apprveJobResult.data != null &&
      apprveJobResult.data!['approveJob'] != null) {
    print('Approve Job success!!!!!');
  }
  return apprveJobResult;
}

//Upafte Payout Account
Future<QueryResult> updatePartnerAccountMutation(
    String accountNumber, String ifscCode) async {
  final MutationOptions _options = MutationOptions(
    document: gql(updatePartnerPayoutAccount),
    variables: {
      "data": {
        "accountNumber": accountNumber,
        "ifscCode": ifscCode,
      },
    },
  );
  final QueryResult updateAccResult =
      await globalGQLClient.value.mutate(_options);
  if (updateAccResult.hasException) {
    print(
        'update Accnt Excption >>>>> ${updateAccResult.exception.toString()}');
  }
  if (updateAccResult != null &&
      updateAccResult.data != null &&
      updateAccResult.data!['updatePartnerPayoutAccount'] != null) {
    print('update Accnt success!!!!!');
  }
  return updateAccResult;
}

//Get CMS Content
Future<QueryResult> getCMSContentMutation() async {
  final MutationOptions _options = MutationOptions(
    fetchPolicy: FetchPolicy.noCache,
    document: gql(getCmsContent),
  );
  final QueryResult getCmsResult = await globalGQLClient.value.mutate(_options);
  if (getCmsResult.hasException) {
    print('getCmsContent Excption >>>>> ${getCmsResult.exception.toString()}');
  }
  if (getCmsResult != null &&
      getCmsResult.data != null &&
      getCmsResult.data!['getCmsContent'] != null) {
    CmsContent cmsConetent;
    cmsConetent = CmsContent.fromJson(getCmsResult.data!['getCmsContent']);
    fbState.setCMSContent(cmsConetent);
  }
  return getCmsResult;
}

//Get Partner Companies
Future<QueryResult> getPartnerCompaniesMutation() async {
  final MutationOptions _options = MutationOptions(
    fetchPolicy: FetchPolicy.noCache,
    document: gql(getPartnerCompanies),
  );
  final QueryResult getCompaniesResult =
      await globalGQLClient.value.mutate(_options);
  if (getCompaniesResult.hasException) {
    print(
        'getCompaniesResult Excption >>>>> ${getCompaniesResult.exception.toString()}');
  }
  if (getCompaniesResult != null &&
      getCompaniesResult.data != null &&
      getCompaniesResult.data!['getPartnerCompanies'] != null) {
    List<PartnerCompany> companies = [];
    for (Map comps in getCompaniesResult.data!['getPartnerCompanies']) {
      PartnerCompany temp;
      temp = PartnerCompany.fromJson(comps as Map<String, dynamic>);
      companies.add(temp);
    }
    fbState.setCompanies(companies);
    print('getCompaniesResult success!!!!! $companies');
  }
  return getCompaniesResult;
}

//Mutation Update Partner Unvaialbilty
Future<QueryResult> updatePartnerUnavailableMutation(
    String? unavailableTill) async {
  final MutationOptions _options = MutationOptions(
    document: gql(updatePartnerUnavailable),
    variables: {
      "unavailableTill": unavailableTill,
    },
  );
  final QueryResult updatePartnerUnavailableResult =
      await globalGQLClient.value.mutate(_options);
  if (updatePartnerUnavailableResult.hasException) {
    print(
        'updatePartnerUnavailableResult Excption >>>>> ${updatePartnerUnavailableResult.exception.toString()}');
  }
  if (updatePartnerUnavailableResult != null &&
      updatePartnerUnavailableResult.data != null &&
      updatePartnerUnavailableResult.data!['updatePartnerUnavailable'] !=
          null) {
    print('updatePartnerUnavailableResult success!!!!!');
  }
  return updatePartnerUnavailableResult;
}

//Mutation partnerRedeemWallet
Future<QueryResult> partnerRedeemWalletMutation(double? amount) async {
  final MutationOptions _options = MutationOptions(
    document: gql(partnerRedeemWallet),
    variables: {
      "amount": amount,
    },
  );
  final QueryResult redeemWalletResult =
      await globalGQLClient.value.mutate(_options);
  if (redeemWalletResult.hasException) {
    print(
        'redeemWalletResult Excption >>>>> ${redeemWalletResult.exception.toString()}');
  }
  if (redeemWalletResult != null &&
      redeemWalletResult.data != null &&
      redeemWalletResult.data!['partnerRedeemWallet'] != null) {
    print('partnerRedeemWallet success!!!!!');
  }
  return redeemWalletResult;
}

//Mutation upadte partner details
Future<QueryResult> updatePartnerDetailsMutation(
    String? name,
    PartnerRegisterAddressGqlInput? partnerAdd,
    String? email,
    String? photoId,
    String? selectedCompanyID,
    String? adhar) async {
  final MutationOptions _options = MutationOptions(
    document: gql(updatePartnerDetails),
    variables: {
      "name": name,
      "address": partnerAdd,
      "email": email,
      "photoId": photoId,
      "companyId": selectedCompanyID,
      "aadharNumber": adhar
    },
  );
  final QueryResult upadteResult = await globalGQLClient.value.mutate(_options);
  // if (upadteResult.hasException) {
  //   print('upadteResult Excption >>>>> ${upadteResult.exception.toString()}');
  // }
  // if (upadteResult != null &&
  //     upadteResult.data != null &&
  //     upadteResult.data!['updatePartnerDetails'] != null) {
  //   print('upadteResult success!!!!!');
  // }
  return upadteResult;
}

//Start Job
Future<QueryResult> startJobMutation(
    String? bookingServiceItemId, String workCode) async {
  final MutationOptions _options = MutationOptions(
    document: gql(startJob),
    variables: <String, dynamic>{
      "bookingServiceItemId": bookingServiceItemId,
      "workCode": workCode.toUpperCase()
    },
  );
  final QueryResult startJobResult =
      await globalGQLClient.value.mutate(_options);
  if (startJobResult.hasException) print(startJobResult.exception.toString());
  if (startJobResult != null &&
      startJobResult.data != null &&
      startJobResult.data!['startJob'] != null) {
    print('start job success!!!!!');
  }
  return startJobResult;
}

Future<QueryResult> reworkMutation(
    String? bookingServiceItemId, bool sts) async {
  print("on rework");
  final MutationOptions _options = MutationOptions(
    document: gql(rework),
    variables: <String, dynamic>{
      "bookingServiceItemId": bookingServiceItemId,
      "status": sts
    },
  );
  print(_options);
  final QueryResult startJobResult =
      await globalGQLClient.value.mutate(_options);
  print("result" + startJobResult.toString());
  if (startJobResult.hasException) {
    print(
        'Mutation failed with exception: ${startJobResult.exception.toString()}');
  }

  if (startJobResult.data != null) {
    print('Mutation result: ${startJobResult.data}');
  }
  return startJobResult;
}

Future<QueryResult> assignJobMutation(String? jobBoardId, bool? isLoading,
    BuildContext context, List<String>? teamId, Function refetch) async {
  final MutationOptions _options = MutationOptions(
    document: gql(commitJob),
    variables: <String, dynamic>{"jobBoardId": jobBoardId, "teamId": teamId},
  );
  final QueryResult assignJobMutationResult =
      await globalGQLClient.value.mutate(_options);
  print("result");
  print(assignJobMutationResult);
  if (assignJobMutationResult.hasException) {
    showCustomDialog(
        'Oops!',
        '${assignJobMutationResult.exception!.graphqlErrors.first.message}',
        context,
        null);
    print(assignJobMutationResult.exception.toString());
  }
  if (assignJobMutationResult != null &&
      assignJobMutationResult.data != null &&
      assignJobMutationResult.data!['commitJob'] != null) {
    print('success update addre!!!!!');
    refetch();
    showCustomDialog(
        'Yay!',
        'Job has been successfully assigned.',
        context,
        Dashboard(
          index: 2,
        ));
  }
  return assignJobMutationResult;
}

//Get Service Categories
Future<QueryResult> getServiceCategoriesMutation() async {
  final MutationOptions _options = MutationOptions(
    fetchPolicy: FetchPolicy.noCache,
    document: gql(getServiceCategories),
  );
  final QueryResult getServiceCategoriesResult =
      await globalGQLClient.value.mutate(_options);
  if (getServiceCategoriesResult.hasException) {
    print(
        'getServiceCategoriesResult Excption >>>>> ${getServiceCategoriesResult.exception.toString()}');
  }
  if (getServiceCategoriesResult != null &&
      getServiceCategoriesResult.data != null &&
      getServiceCategoriesResult.data!['getServiceCategories'] != null) {
    List<ServiceCategory> servicesCatgs = [];
    for (Map catg in getServiceCategoriesResult.data!['getServiceCategories']) {
      ServiceCategory temp;
      temp = ServiceCategory.fromJson(catg as Map<String, dynamic>);
      servicesCatgs.add(temp);
    }
    fbState.setServiceCategories(servicesCatgs);
    List<AllServices>? partnerServices = [];
    List<AllServices> serviceMap = [];
    if (fbState != null &&
        fbState.partnerUser != null &&
        fbState.partnerUser.value != null &&
        fbState.partnerUser.value!.partnerDetails != null &&
        fbState.partnerUser.value!.partnerDetails!.services != null &&
        fbState.partnerUser.value!.partnerDetails!.services!.isNotEmpty)
      partnerServices = fbState.partnerUser.value!.partnerDetails!.services;

    for (ServiceCategory catg in fbState.allServiceCatg.value) {
      for (AllServices subServ in catg.services!) {
        for (AllServices selectedOne in partnerServices!) {
          if (selectedOne.id == subServ.id) subServ.isSelected = true;
        }
        serviceMap.add(subServ);
      }
    }
    fbState.setAllServices(serviceMap);
    print('getServiceCategoriesResult success!!!!!');
  }
  return getServiceCategoriesResult;
}

//Register Partner
Future<QueryResult> registerPartnerMutation(
    String name,
    PartnerRegisterAddressGqlInput address,
    String accno,
    String email,
    String ifsc,
    String photoId,
    bool partofCompany,
    String? companyId,
    String? adhar) async {
  final MutationOptions _options = MutationOptions(
    document: gql(registerPartner),
    variables: <String, dynamic>{
      "data": {
        "name": name,
        "address": {
          "buildingName": address.buildingName,
          "address": address.address,
          "locality": address.locality,
          "landmark": address.landmark,
          "postalCode": address.postalCode,
          "area": address.area,
          "isDefault": address.isDefault,
          "city": address.city,
        },
        "accountNumber": accno,
        "email": email,
        "ifscCode": ifsc,
        "companyId": companyId,
        "photoId": photoId,
        "aadharNumber": adhar
      },
    },
  );
  final QueryResult registerResult =
      await globalGQLClient.value.mutate(_options);
  if (registerResult.hasException) {
    print(registerResult.exception.toString());
  }
  if (registerResult.data != null &&
      registerResult.data!['registerPartner'] != null) {
    PartnerUser thisUser;
    thisUser = PartnerUser.fromJson(registerResult.data!['registerPartner']);
    fbState.setPartnerUser(thisUser);
    print('success  partner registr - ${thisUser.name}!!!!!');
  }
  return registerResult;
}

//Get call Partner
Future<QueryResult> callPartnerMutation(String? bookingServiceItemId) async {
  final MutationOptions _options = MutationOptions(
    fetchPolicy: FetchPolicy.noCache,
    document: gql(callPartnerCustomer),
    variables: {
      "bookingServiceItemId": bookingServiceItemId,
    },
  );
  final QueryResult callPartnerResult =
      await globalGQLClient.value.mutate(_options);
  if (callPartnerResult.hasException) {
    print(
        'call Partner Excption >>>>> ${callPartnerResult.exception.toString()}');
  }
  if (callPartnerResult != null &&
      callPartnerResult.data != null &&
      callPartnerResult.data!['callPartnerCustomer'] != null &&
      callPartnerResult.data!['callPartnerCustomer']) {
    print('call Partner  success!!!!! ');
  }
  return callPartnerResult;
}

//Uplaod Partner Docs
Future<QueryResult> uploadDocMutation(
    DocumentTypeEnum? type, List<String?> medias) async {
  String docType = type.toString();
  if (docType != null && docType.isNotEmpty && docType.contains('.')) {
    docType = docType.split('.')[1];
  }
  final MutationOptions _options = MutationOptions(
    document: gql(updatePartnerDocument),
    variables: <String, dynamic>{
      "type": docType,
      "medias": medias,
    },
  );
  final QueryResult docUpldResult =
      await globalGQLClient.value.mutate(_options);
  if (docUpldResult.hasException) {
    print(docUpldResult.exception.toString());
  }
  if (docUpldResult != null &&
      docUpldResult.data != null &&
      docUpldResult.data!['updatePartnerDocument'] != null) {
    print('success  partner upload!!!!!');
  } else if (docUpldResult.hasException) {
    print('DOC EXCPETION  >>>>> ${docUpldResult.exception}');
  }
  return docUpldResult;
}

//Get me only--------
Future<QueryResult> getUserOnly() async {
  final MutationOptions _options = MutationOptions(
    document: gql(getMe),
  );
  final QueryResult loggedInUser = await globalGQLClient.value.mutate(_options);
  if (loggedInUser.hasException) {
    print(loggedInUser.exception.toString());
  }
  return loggedInUser;
}
