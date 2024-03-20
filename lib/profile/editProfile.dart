import 'package:easy_mask/easy_mask.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:page_transition/page_transition.dart';

import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../signup/partnerCompanyList.dart';
import '../theme.dart';
import 'editProfilePic.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _name = new TextEditingController();
  TextEditingController _aadharNo = new TextEditingController();
  TextEditingController _city = new TextEditingController(text: "Kochi");
  TextEditingController _area = new TextEditingController();
  TextEditingController _postalCode = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _houseNo = new TextEditingController();
  TextEditingController _locality = new TextEditingController();
  TextEditingController _landmark = new TextEditingController();
  TextEditingController _companyName = new TextEditingController();

  //focus nodes
  final FocusNode _aadharNoNode = FocusNode();
  final FocusNode _postalCodeNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _areaNode = FocusNode();
  final FocusNode _cityNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _houseNoNode = FocusNode();
  final FocusNode _localityNode = FocusNode();
  final FocusNode _landmarkNode = FocusNode();
  final FocusNode _companyNameNode = FocusNode();

  //--------------------
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nameNode,
        ),
        KeyboardActionsItem(
          focusNode: _emailNode,
        ),
        KeyboardActionsItem(
          focusNode: _aadharNoNode,
          onTapAction: () {
            if (_aadharNo.text.isNotEmpty)
              setState(() {
                filledAadhar = true;
              });
            else
              setState(() {
                filledAadhar = false;
              });
            if (_aadharNo.text.isNotEmpty) {
              String thiAddhar = _aadharNo.text.replaceAll('-', '');
              if (thiAddhar != null &&
                  thiAddhar.isNotEmpty &&
                  thiAddhar.length < 12)
                setState(() {
                  validAadhar = false;
                });
              else
                setState(() {
                  validAadhar = true;
                });
            }
          },
        ),
        KeyboardActionsItem(
          focusNode: _houseNoNode,
        ),
        KeyboardActionsItem(
          focusNode: _localityNode,
        ),
        KeyboardActionsItem(
          focusNode: _landmarkNode,
        ),
        KeyboardActionsItem(
          focusNode: _cityNode,
        ),
        KeyboardActionsItem(
          focusNode: _areaNode,
        ),
        KeyboardActionsItem(
          focusNode: _postalCodeNode,
        ),
      ],
    );
  }

  int? selectedValue;
  OverlayEntry? overlayEntry;
  bool validEmail = true;
  bool validAadhar = false;
  bool showError = false;
  bool isLoading = false;
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }

  List<DropdownMenuItem> dropdownAreas = [];
  String? selectedCompanyID;

//mandatory field flags----
  bool checked = false;
  bool filledName = false;
  bool filledAadhar = false;
  bool filledStreetAddr = false;
  bool filledPostal = false;
  bool filledCity = true;
  // bool filledifsc = false;
  // bool filledAcc = false;
  bool filledArea = false;
  bool filledEmail = false;
  bool filledHouseNo = false;
  bool filledLocality = false;
  bool filledLandmark = false;
  bool filledCompany = false;

  //error flags
  bool errorName = false;
  bool errorAadhar = false;
  bool errorStreetAddr = false;
  bool errorPostal = false;
  bool errorCity = false;
  bool errorArea = false;
  bool errorEmail = false;
  bool errorHouseNo = false;
  bool errorLocality = false;
  bool errorLandmark = false;
  bool errorCompany = false;

  String? _image;

  List<Area> areas = [];
  FirebaseAuth auth = FirebaseAuth.instance;

  var aadharMaskFormatter = new MaskTextInputFormatter(
    mask: '####-####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    //aadhar node
    _aadharNoNode.addListener(() {
      if (_aadharNo.text.isNotEmpty)
        setState(() {
          filledAadhar = true;
        });
      else
        setState(() {
          filledAadhar = false;
        });
      print('filledAadhar $filledAadhar');
    });
    //-------poastal code
    _postalCodeNode.addListener(() {
      if (_postalCode.text.isNotEmpty)
        setState(() {
          filledPostal = true;
        });
      else
        setState(() {
          filledPostal = false;
        });
      print('filledPostal $filledPostal');
    });
    //-------------------------------
    //Prefill profile details
    if (fbState != null &&
        fbState.partnerUser != null &&
        fbState.partnerUser.value != null) {
      if (fbState.partnerUser.value!.name != null) {
        _name.text = fbState.partnerUser.value!.name!;
        filledName = true;
      }
      if (fbState.partnerUser.value!.email != null) {
        _email.text = fbState.partnerUser.value!.email!;
        filledEmail = true;
      }
      print(
          "adhaar no: ${fbState.partnerUser.value?.partnerDetails?.aadharNumber}");
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.aadharNumber != null) {
        _aadharNo.text =
            fbState.partnerUser.value!.partnerDetails!.aadharNumber!;
        MagicMask mask = MagicMask.buildMask('9999-9999-9999');
        _aadharNo.text = mask.getMaskedString(_aadharNo.text);
        filledAadhar = true;
      }
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.address != null &&
          fbState.partnerUser.value!.partnerDetails!.address!.buildingName !=
              null) {
        _houseNo.text =
            fbState.partnerUser.value!.partnerDetails!.address!.buildingName!;
        filledHouseNo = true;
      }
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.address != null &&
          fbState.partnerUser.value!.partnerDetails!.address!.locality !=
              null) {
        _locality.text =
            fbState.partnerUser.value!.partnerDetails!.address!.locality!;
        filledLocality = true;
      }
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.address != null &&
          fbState.partnerUser.value!.partnerDetails!.address!.landmark !=
              null &&
          fbState.partnerUser.value!.partnerDetails!.address!.landmark!
              .isNotEmpty) {
        _landmark.text =
            fbState.partnerUser.value!.partnerDetails!.address!.landmark!;
        filledLandmark = true;
      }
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.address != null &&
          fbState.partnerUser.value!.partnerDetails!.address!.area != null) {
        _area.text = fbState.partnerUser.value!.partnerDetails!.address!.area!;
        filledArea = true;
      }
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.address != null &&
          fbState.partnerUser.value!.partnerDetails!.address!.postalCode !=
              null) {
        _postalCode.text =
            fbState.partnerUser.value!.partnerDetails!.address!.postalCode!;
        filledPostal = true;
      }
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.company != null &&
          fbState.partnerUser.value!.partnerDetails!.company!.isNotEmpty) {
        _companyName.text = fbState
            .partnerUser.value!.partnerDetails!.company!.first.companyName!;
        selectedCompanyID =
            fbState.partnerUser.value!.partnerDetails!.company!.first.id;
        filledCompany = true;
        checked = true;
      }
      if (fbState.partnerUser.value!.partnerDetails != null &&
          fbState.partnerUser.value!.partnerDetails!.photo != null) {
        _image =
            baseImgUrl + fbState.partnerUser.value!.partnerDetails!.photo!.url!;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _aadharNoNode.dispose();
    _postalCodeNode.dispose();
    _area.dispose();
    _name.dispose();
    _email.dispose();
    _landmark.dispose();
    _locality.dispose();
    super.dispose();
  }

  double? bottom;

  @override
  Widget build(BuildContext context) {
    bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: zimkeyBgWhite,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: zimkeyDarkGrey,
          size: 18,
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.chevron_left,
            color: zimkeyDarkGrey,
            size: 30,
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: zimkeyBgWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Container(
            color: zimkeyWhite,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
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
                  'Update your profile details.',
                  style: TextStyle(
                    fontSize: 12,
                    color: zimkeyBlack.withOpacity(0.6),
                  ),
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
      body: Stack(
        children: [
          KeyboardActions(
            config: _buildConfig(context),
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              // child: SingleChildScrollView(
              //   reverse: false,
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: EditProfilePicPage(),
                            duration: Duration(milliseconds: 300),
                          ),
                        );
                      },
                      child: _image != null && _image!.isNotEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: new NetworkImage(_image!),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/icons/newIcons/gallery-add.svg',
                                  height: 70,
                                  color: zimkeyDarkGrey.withOpacity(0.7),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Edit Profile Picture',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: zimkeyOrange,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  //name--------
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorName
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/name.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _name,
                            focusNode: _nameNode,
                            maxLength: 30,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              if (_name.text.isNotEmpty)
                                setState(() {
                                  errorName = false;
                                  filledName = true;
                                });
                              else
                                setState(() {
                                  filledName = false;
                                });
                              print('filledName ... $filledName');
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_emailNode);
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: 'Name *',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _name.clear();
                            setState(() {
                              filledName = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: filledName ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //email--
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorName
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/email.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _email,
                            focusNode: _emailNode,
                            maxLength: 30,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              if (_email.text.isNotEmpty)
                                setState(() {
                                  errorEmail = false;
                                  filledEmail = true;
                                });
                              else
                                setState(() {
                                  filledEmail = false;
                                });
                              print('filledEmail ... $filledEmail');
                            },
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(_aadharNoNode);
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: 'Email *',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _email.clear();
                            setState(() {
                              filledEmail = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: filledEmail ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        )
                      ],
                    ),
                  ),
                  if (!validEmail)
                    Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        'Oops! Looks like the email is not a valid.',
                        style: TextStyle(
                          color: zimkeyRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorAadhar
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/aadhar.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _aadharNo,
                            focusNode: _aadharNoNode,
                            maxLength: 14,
                            inputFormatters: [aadharMaskFormatter],
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              if (_aadharNo.text.isNotEmpty)
                                setState(() {
                                  filledAadhar = true;
                                  errorAadhar = false;
                                });
                              else
                                setState(() {
                                  filledAadhar = false;
                                });
                              print('filledAadhar ... $filledAadhar');
                            },
                            onEditingComplete: () {
                              if (_aadharNo.text.isNotEmpty &&
                                  _aadharNo.text.length < 12)
                                setState(() {
                                  filledAadhar = true;
                                  errorAadhar = true;
                                });
                              else {
                                setState(() {
                                  errorAadhar = false;
                                });
                                FocusScope.of(context)
                                    .requestFocus(_houseNoNode);
                              }
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              counterText: "",
                              hintText: 'Aadhar Card No. *',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _aadharNo.clear();
                            setState(() {
                              filledAadhar = false;
                              errorAadhar = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: filledAadhar ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (filledAadhar && errorAadhar != null && errorAadhar)
                    Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        'Oops! Looks like the aadhar number (12 digits) is not a valid.',
                        style: TextStyle(
                          color: zimkeyRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 14,
                      color: zimkeyBlack.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //house no
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorHouseNo
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/house.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _houseNo,
                            focusNode: _houseNoNode,
                            maxLength: 200,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            onTap: () {
                              if (_aadharNo.text.isNotEmpty &&
                                  _aadharNo.text.length < 12)
                                setState(() {
                                  filledAadhar = true;
                                  errorAadhar = true;
                                });
                              else {
                                setState(() {
                                  errorAadhar = false;
                                });
                              }
                            },
                            onChanged: (val) {
                              if (_houseNo.text.isNotEmpty)
                                setState(() {
                                  filledHouseNo = true;
                                  errorHouseNo = false;
                                });
                              else
                                setState(() {
                                  filledHouseNo = false;
                                });
                              print('filledHouseNo ... $filledHouseNo');
                            },
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(_localityNode);
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              counterText: "",
                              hintText: 'House No./ House name *',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _houseNo.clear();
                            setState(() {
                              filledHouseNo = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: filledHouseNo ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //locality
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorLocality
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/locality.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _locality,
                            focusNode: _localityNode,
                            maxLength: 200,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              if (_locality.text.isNotEmpty)
                                setState(() {
                                  filledLocality = true;
                                  errorLocality = false;
                                });
                              else
                                setState(() {
                                  filledLocality = false;
                                });
                              print('filledLocality ... $filledLocality');
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(_landmarkNode);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              counterText: "",
                              hintText: 'Locality *',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _locality.clear();
                            setState(() {
                              filledLocality = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color:
                                filledLocality ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //landmark
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorLandmark
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/landmark.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _landmark,
                            focusNode: _landmarkNode,
                            maxLength: 200,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              if (_landmark.text.isNotEmpty)
                                setState(() {
                                  filledLandmark = true;
                                  errorLandmark = false;
                                });
                              else
                                setState(() {
                                  filledLandmark = false;
                                });
                              print('filledLandmark ... $filledLandmark');
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_cityNode);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              counterText: "",
                              hintText: 'Landmark',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _landmark.clear();
                            setState(() {
                              filledLandmark = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color:
                                filledLandmark ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //city
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorCity
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/city.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _city,
                            focusNode: _cityNode,
                            maxLength: 100,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              if (_city.text.isNotEmpty)
                                setState(() {
                                  filledCity = true;
                                  errorCity = false;
                                });
                              else
                                setState(() {
                                  filledCity = false;
                                });
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_areaNode);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              counterText: "",
                              hintText: 'Town / City *',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _city.clear();
                            setState(() {
                              filledCity = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: filledCity ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //area
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorArea
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/areas.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: _areaNode,
                            controller: _area,
                            maxLength: 50,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              if (_area.text.isNotEmpty)
                                setState(() {
                                  filledArea = true;
                                  errorArea = false;
                                });
                              else
                                setState(() {
                                  filledArea = false;
                                });
                              print('filledArea ... $filledArea');
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(_postalCodeNode);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              counterText: "",
                              hintText: 'Area *',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _area.clear();
                              filledArea = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: filledArea ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //postal
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorPostal
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/postal.svg',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: _postalCodeNode,
                            controller: _postalCode,
                            maxLength: 6,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              if (_postalCode.text.isNotEmpty)
                                setState(() {
                                  filledPostal = true;
                                  errorPostal = false;
                                });
                              else
                                setState(() {
                                  filledPostal = false;
                                });
                              print('filledPostal ... $filledPostal');
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            onEditingComplete: () {
                              if (checked)
                                FocusScope.of(context)
                                    .requestFocus(_companyNameNode);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              counterText: "",
                              hintText: 'Postal Code *',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: zimkeyBlack.withOpacity(0.3),
                              ),
                              fillColor: zimkeyOrange,
                              focusColor: zimkeyOrange,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _postalCode.clear();
                            setState(() {
                              filledPostal = false;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: filledPostal ? zimkeyDarkGrey : zimkeyWhite,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        checked = !checked;
                        _companyName.clear();
                        print('checked ... $checked');
                      });
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/tick-circle.svg',
                          color: checked
                              ? zimkeyOrange
                              : zimkeyDarkGrey.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Are you part of a company?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: zimkeyDarkGrey,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (checked)
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: zimkeyDarkGrey2.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/icons/newIcons/company.svg',
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              focusNode: _companyNameNode,
                              controller: _companyName,
                              maxLength: 200,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: PartnerCompanies(
                                        updateCompany: (PartnerCompany comp) {
                                      setState(() {
                                        selectedCompanyID = comp.id;
                                        _companyName.text = comp.companyName!;
                                        filledCompany = true;
                                      });
                                    }),
                                    duration: Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                counterText: "",
                                hintText: 'Company Name',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: zimkeyBlack.withOpacity(0.3),
                                ),
                                fillColor: zimkeyOrange,
                                focusColor: zimkeyOrange,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () {
                              _companyName.clear();
                              selectedCompanyID = null;
                              setState(() {
                                filledCompany = false;
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              color:
                                  filledCompany ? zimkeyDarkGrey : zimkeyWhite,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (!filledName)
                            setState(() {
                              errorName = true;
                            });
                          else
                            setState(() {
                              errorName = false;
                            });
                          if (!filledEmail)
                            setState(() {
                              errorEmail = true;
                            });
                          else
                            setState(() {
                              errorEmail = false;
                            });
                          if (!filledAadhar)
                            setState(() {
                              errorAadhar = true;
                            });
                          else
                            setState(() {
                              errorAadhar = false;
                            });
                          if (!filledLocality)
                            setState(() {
                              errorLocality = true;
                            });
                          else
                            setState(() {
                              errorLocality = false;
                            });
                          if (!filledHouseNo)
                            setState(() {
                              errorHouseNo = true;
                            });
                          else
                            setState(() {
                              errorHouseNo = false;
                            });
                          if (!filledArea)
                            setState(() {
                              errorArea = true;
                            });
                          else
                            setState(() {
                              errorArea = false;
                            });
                          if (!filledCity)
                            setState(() {
                              errorCity = true;
                            });
                          else
                            setState(() {
                              errorCity = false;
                            });
                          if (!filledPostal)
                            setState(() {
                              errorPostal = true;
                            });
                          else
                            setState(() {
                              errorPostal = false;
                            });
                          if (checked && !filledCompany)
                            setState(() {
                              errorCompany = true;
                            });
                          else
                            setState(() {
                              errorCompany = false;
                            });
                          if (!filledName &&
                              !filledEmail &&
                              !filledAadhar &&
                              !filledArea &&
                              !filledLocality &&
                              !filledHouseNo &&
                              !filledPostal) {
                            showCustomDialog('Oops!!',
                                'Fill all mandatory fields*.', context, null);
                          }
                          if (filledName &&
                              filledEmail &&
                              filledAadhar &&
                              filledArea &&
                              filledLocality &&
                              filledHouseNo &&
                              filledPostal &&
                              filledCity &&
                              ((!checked && !filledCompany) ||
                                  (checked && filledCompany))) {
                            PartnerRegisterAddressGqlInput partnerAdd =
                                PartnerRegisterAddressGqlInput(
                              buildingName: _houseNo.text,
                              locality: _locality.text,
                              landmark: _landmark.text,
                              area: _area.text,
                              postalCode: _postalCode.text,
                              isDefault: true,
                              address: "",
                              city: _city.text,
                            );

                            setState(() {
                              isLoading = true;
                            });
                            var a = _aadharNo.text.replaceAll("-", "").trim();
                            QueryResult updateData =
                                await updatePartnerDetailsMutation(
                                    _name.text,
                                    partnerAdd,
                                    _email.text,
                                    fbState.partnerUser.value!.partnerDetails!
                                            .photo!.id ??
                                        "",
                                    selectedCompanyID,
                                    a);
                            setState(() {
                              isLoading = false;
                            });
                            print(updateData);
                            if (updateData != null &&
                                updateData.data != null &&
                                updateData.data!['updatePartnerDetails'] !=
                                    null) {
                              showCustomDialog(
                                  'Yay!!',
                                  'Your profile has been successfully updated.',
                                  context,
                                  Dashboard(
                                    index: 3,
                                  ));
                            } else if (updateData.hasException) {
                              showCustomDialog(
                                  'Oops!!',
                                  'Exception - ${updateData.exception!.graphqlErrors.first.message}.',
                                  context,
                                  null);
                            }
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 2.5,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: filledEmail &&
                                    filledName &&
                                    filledAadhar &&
                                    filledHouseNo &&
                                    filledLocality &&
                                    filledArea &&
                                    filledCity &&
                                    filledPostal &&
                                    ((!checked && !filledCompany) ||
                                        (checked && filledCompany))
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
                              fontSize: 15,
                              color: filledEmail &&
                                      filledName &&
                                      filledAadhar &&
                                      filledHouseNo &&
                                      filledArea &&
                                      filledCity &&
                                      filledPostal &&
                                      ((!checked && !filledCompany) ||
                                          (checked && filledCompany))
                                  ? Colors.white
                                  : zimkeyBlack.withOpacity(0.5),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 140,
                  ),
                ],
              ),
              // ),
            ),
          ),
          if (isLoading)
            Center(
              child: sharedLoadingIndicator(),
            ),
        ],
      ),
    );
  }
}
