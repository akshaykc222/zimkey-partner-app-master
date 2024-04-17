import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'models/jobModel.dart';
import 'models/partnerModel.dart';
import 'models/serviceModel.dart';

class FbState extends GetxController {
  var token = "".obs;
  var areaLoc = "".obs;
  var isLoggedIn = "".obs;
  var geoLoc = "".obs;
  var isRegistered = "".obs;
  var userId = "".obs;
  Rx<PartnerUser?> partnerUser = PartnerUser().obs;
  RxList<Area> areaList = RxList<Area>();
  RxList<JobBoard> jobBoardList = RxList<JobBoard>();
  RxList<PartnerCalendarItem> jobCalendarlist = RxList<PartnerCalendarItem>();
  RxList<PartnerPendingTaskEnum?> partnerProgress =
      RxList<PartnerPendingTaskEnum?>();
  var deviceId = "".obs;
  Rx<CmsContent> cmsConetent = CmsContent().obs;
  RxList<PartnerCompany> companies = RxList<PartnerCompany>();
  RxList<ServiceCategory> allServiceCatg = RxList<ServiceCategory>();
  RxList<AllServices> allServices = RxList<AllServices>();

  setToken(String newToken) {
    token.value = newToken;
    var storage = GetStorage();
    storage.write("token", newToken);
    print(token.value);
  }

  //save Location area
  setUserLoc(String loc) {
    areaLoc.value = loc;
  }

  //save Geo Location area
  setGeoLoc(String loc) {
    geoLoc.value = loc;
  }

  //save user if logged in check
  setUserLoggedIn(String val) {
    isLoggedIn.value = val;
  }

  //save user if registered check
  setIsRegistered(String val) {
    isRegistered.value = val;
  }

  setUserID(String val) {
    userId.value = val;
  }

  //set partner user
  setPartnerUser(PartnerUser? val) {
    print(val?.toJson(print: true));
    partnerUser.value = val;
  }

  //area list
  setAreaList(List<Area> val) {
    areaList.value = val;
  }

  //open jobs list
  setJobBoardList(List<JobBoard> val) {
    jobBoardList.value = val;
  }

  // jobs calendar list
  setJobCalendarList(List<PartnerCalendarItem> val) {
    jobCalendarlist.value = val;
  }

  // jobs calendar list
  setPartnerProgress(List<PartnerPendingTaskEnum?> val) {
    partnerProgress.value = val;
  }

  // set Device Id
  setDeviceID(String val) {
    deviceId.value = val;
  }

  // set CMS Content
  setCMSContent(CmsContent val) {
    cmsConetent.value = val;
  }

  //set companies--
  setCompanies(List<PartnerCompany> val) {
    companies.value = val;
  }

  //set service catg--
  setServiceCategories(List<ServiceCategory> val) {
    allServiceCatg.value = val;
  }

  //set services--
  setAllServices(List<AllServices> val) {
    allServices.value = val;
  }

  @override
  void onInit() {
    super.onInit();
  }
}
