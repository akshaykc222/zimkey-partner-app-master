import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:page_transition/page_transition.dart';

import '../fbState.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../theme.dart';
import 'partnerCompanyList.dart';

class SignUpDetails extends StatefulWidget {
  final FbState? fbstate;

  const SignUpDetails({Key? key, this.fbstate}) : super(key: key);

  @override
  _SignUpDetailsState createState() => _SignUpDetailsState();
}

class _SignUpDetailsState extends State<SignUpDetails> {
  TextEditingController _name = new TextEditingController();
  TextEditingController _aadharNo = new TextEditingController();
  TextEditingController _city = new TextEditingController(text: "Kochi");
  TextEditingController _postalCode = new TextEditingController();
  TextEditingController _accNo = new TextEditingController();
  TextEditingController _ifscCode = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _houseNo = new TextEditingController();
  TextEditingController _locality = new TextEditingController();
  TextEditingController _landmark = new TextEditingController();
  TextEditingController _companyName = new TextEditingController();
  TextEditingController _area = new TextEditingController();

  //focus nodes
  final FocusNode _aadharNoNode = FocusNode();
  final FocusNode _postalCodeNode = FocusNode();
  final FocusNode _accNoNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _areaNode = FocusNode();
  final FocusNode _cityNode = FocusNode();
  final FocusNode _ifscNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _houseNoNode = FocusNode();
  final FocusNode _localityNode = FocusNode();
  final FocusNode _landmarkNode = FocusNode();
  final FocusNode _companyNameNode = FocusNode();
  final FocusNode _areYouCompany = FocusNode();

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
          toolbarAlignment: MainAxisAlignment.end,
          displayArrows: true,
          onTapAction: () {
            if (_email.text.isNotEmpty) {
              setState(() {
                errorEmail = !isEmail(_email.text);
                validEmail = !errorEmail;
              });
            } else {
              setState(() {
                validEmail = true;
                filledEmail = false;
                errorEmail = false;
              });
            }
          },
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
        KeyboardActionsItem(
            focusNode: _accNoNode,
            onTapAction: () {
              bool hasFocus = _accNoNode.hasFocus;
              if (!hasFocus) {
                //   showOverlay(context, _ifscNode);
                // } else {
                // FocusScope.of(context).requestFocus(_ifscNode);
                // removeOverlay();
                if (_accNo.text.isNotEmpty) {
                  setState(() {
                    erroraAccnt = !validateAccountNo(_accNo.text);
                    invalidAcc = erroraAccnt;
                  });
                } else
                  setState(() {
                    filledAcc = false;
                    erroraAccnt = false;
                    invalidAcc = false;
                  });
              }
              print('invalidAcc ... $invalidAcc');
            }),
        KeyboardActionsItem(
            focusNode: _ifscNode,
            onTapAction: () {
              if (_ifscCode.text.isNotEmpty) {
                setState(() {
                  errorIfsc = !validateIFSC(_ifscCode.text);
                  invalidIfsc = errorIfsc;
                });
              } else
                setState(() {
                  filledifsc = false;
                  errorIfsc = false;
                  invalidIfsc = false;
                });
              _ifscNode.unfocus();
              print('invalidifsc ---- $invalidIfsc');
            }),
      ],
    );
  }

  List<int> selectedItems = [];
  // List<String> selectedAreas = [];
  int? selectedValue;
  OverlayEntry? overlayEntry;
  bool showError = false;
  bool isLoading = false;

  List<DropdownMenuItem> dropdownAreas = [];
  String? selectedCompanyID;

//mandatory field flags----
  bool checked = false;
  bool filledName = false;
  bool filledAadhar = false;
  bool filledStreetAddr = false;
  bool filledPostal = false;
  bool filledCity = true;
  bool filledifsc = false;
  bool filledAcc = false;
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
  bool erroraAccnt = false;
  bool errorIfsc = false;
  bool errorCompany = false;

  bool invalidAcc = false;
  bool invalidIfsc = false;
  bool validEmail = true;
  bool validAadhar = true;

  List<Area> areas = [];
  FirebaseAuth auth = FirebaseAuth.instance;

  var aadharMaskFormatter = new MaskTextInputFormatter(
    mask: '####-####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

//Pageview variables---------------
  PageController _pagecontroller = PageController();
  int _currWidgetIndex = 0;

  @override
  void initState() {
    //postal code-----------
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
      // bool hasFocus = _postalCodeNode.hasFocus;
      // if (hasFocus) {
      //   showOverlay(context, null, buttonTxt: "Done");
      // } else {
      //   _postalCodeNode.unfocus();
      //   removeOverlay();
      // }
    });
    //----------acc no
    _accNoNode.addListener(() {
      bool hasFocus = _accNoNode.hasFocus;
      if (!hasFocus) {
        //   showOverlay(context, _ifscNode);
        // } else {
        // FocusScope.of(context).requestFocus(_ifscNode);
        // removeOverlay();
        if (_accNo.text.isNotEmpty) {
          setState(() {
            erroraAccnt = !validateAccountNo(_accNo.text);
            invalidAcc = erroraAccnt;
          });
        } else
          setState(() {
            filledAcc = false;
            erroraAccnt = false;
            invalidAcc = false;
          });
      }
      print('invalidAcc ... $invalidAcc');
    });
    //-------------aadhar node
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
      bool hasFocus = _aadharNoNode.hasFocus;
      if (!hasFocus) {
        // showOverlay(context, _houseNoNode, buttonTxt: "Done");
        _aadharNoNode.unfocus();
        // removeOverlay();
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
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _emailNode.dispose();
    _aadharNoNode.dispose();
    _houseNoNode.dispose();
    _localityNode.dispose();
    _landmarkNode.dispose();
    _areaNode.dispose();
    _pagecontroller.dispose();
    _companyNameNode.dispose();
    _postalCodeNode.dispose();
    _accNoNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        backgroundColor: zimkeyBgWhite,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: zimkeyBgWhite,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Let’s Get Started!',
                            style: TextStyle(
                              fontSize: 24,
                              color: zimkeyBlack,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Please fill basic information.',
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
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (widget.fbstate != null &&
                                    widget.fbstate!.partnerUser != null &&
                                    widget.fbstate!.partnerUser.value != null &&
                                    widget.fbstate!.partnerUser.value!.phone !=
                                        null &&
                                    widget.fbstate!.partnerUser.value!.phone!
                                        .isNotEmpty)
                                  Text(
                                    'Not ${widget.fbstate!.partnerUser.value!.phone} ?',
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
        body: isLoading
            ? Center(
                child: sharedLoadingIndicator(),
              )
            : KeyboardActions(
                config: _buildConfig(context),
                child: Container(
                  // height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  // child: SingleChildScrollView(
                  // reverse: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        color: Colors.white,
                        child: ExpandablePageView(
                          children: [
                            new Center(
                              child: personalInfoSection(),
                            ),
                            new Center(
                              child: addressFieldSection(),
                            ),
                            new Center(
                              child: officialDetailsSection(),
                            ),
                          ],
                          // scrollDirection: Axis.horizontal,
                          // reverse: true,
                          physics: NeverScrollableScrollPhysics(),
                          controller: _pagecontroller,
                          onPageChanged: (num) {
                            setState(() {
                              _currWidgetIndex = num;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // pageview indicator-----
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            customPageViewIndicators(
                              _pagecontroller,
                              3,
                              false,
                              20,
                              5,
                              dotColor: zimkeyOrange,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      //button row-----
                      Container(
                        child: Row(
                          mainAxisAlignment: _currWidgetIndex > 0
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.center,
                          children: [
                            if (_currWidgetIndex > 0)
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  if (_pagecontroller.page! > 0)
                                    setState(() {
                                      _pagecontroller.previousPage(
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeIn,
                                      );
                                      _currWidgetIndex--;
                                    });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 13, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: zimkeyWhite,
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
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _currWidgetIndex > 0
                                          ? zimkeyOrange
                                          : zimkeyBlack.withOpacity(0.5),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                print(
                                    '_currWidgetIndex .... $_currWidgetIndex');
                                // as long as not last page
                                if (_pagecontroller.page! <= 2) {
                                  if (filledEmail)
                                    setState(() {
                                      validEmail = isEmail(_email.text);
                                    });
                                  if (_aadharNo.text.isNotEmpty) {
                                    String thiAddhar =
                                        _aadharNo.text.replaceAll('-', '');
                                    if (thiAddhar != null &&
                                        thiAddhar.isNotEmpty &&
                                        thiAddhar.length < 12)
                                      setState(() {
                                        validAadhar = false;
                                        errorAadhar = false;
                                      });
                                    else
                                      setState(() {
                                        validAadhar = true;
                                        errorAadhar = true;
                                      });
                                  }
                                  //frst page check
                                  if (_currWidgetIndex == 0) {
                                    if (filledName &&
                                        (filledEmail && validEmail) &&
                                        filledAadhar &&
                                        validAadhar)
                                      //go next page---------
                                      setState(() {
                                        _currWidgetIndex++;
                                        _pagecontroller.nextPage(
                                          duration: Duration(milliseconds: 400),
                                          curve: Curves.easeIn,
                                        );
                                      });
                                    else {
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
                                      else {
                                        if (validEmail)
                                          setState(() {
                                            errorEmail = false;
                                          });
                                        else
                                          setState(() {
                                            errorEmail = true;
                                          });
                                      }
                                      if (!filledAadhar)
                                        setState(() {
                                          errorAadhar = true;
                                        });
                                      else
                                        setState(() {
                                          errorAadhar = false;
                                        });
                                    }
                                  }
                                  //second page check
                                  else if (_currWidgetIndex == 1) {
                                    if (filledHouseNo &&
                                        filledLocality &&
                                        filledArea &&
                                        filledPostal &&
                                        !errorPostal)
                                      //go next page---------
                                      setState(() {
                                        _currWidgetIndex++;
                                        FocusScope.of(context)
                                            .requestFocus(_areYouCompany);
                                        _pagecontroller.nextPage(
                                          duration: Duration(milliseconds: 400),
                                          curve: Curves.easeIn,
                                        );
                                      });
                                    else {
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
                                    }
                                  }
                                  //third page check

                                  else if (_currWidgetIndex == 2) {
                                    if ((filledAcc && !invalidAcc) &&
                                        (filledifsc && !invalidIfsc) &&
                                        ((checked && filledCompany) ||
                                            (!checked && !filledCompany))) {
                                      //call register mutation
                                      print("if state is wrking");
                                      if (filledName &&
                                          (filledEmail && validEmail) &&
                                          filledAadhar &&
                                          filledArea &&
                                          filledLocality &&
                                          filledHouseNo &&
                                          // selectedArea.isNotEmpty &&
                                          filledPostal &&
                                          filledCity &&
                                          (filledAcc && !invalidAcc) &&
                                          (filledifsc && !invalidIfsc) &&
                                          ((checked && filledCompany) ||
                                              (!checked && !filledCompany))) {
                                        PartnerRegisterAddressGqlInput
                                            partnerAdd =
                                            PartnerRegisterAddressGqlInput(
                                          buildingName: _houseNo.text,
                                          locality: _locality.text,
                                          landmark: _landmark.text,
                                          area: _area.text,
                                          postalCode: _postalCode.text,
                                          address: "",
                                          isDefault: true,
                                          city: _city.text,
                                        );
                                        print('call register');
                                        setState(() {
                                          isLoading = true;
                                        });
                                        //register partner
                                        var registerResult =
                                            await registerPartnerMutation(
                                                _name.text,
                                                partnerAdd,
                                                _accNo.text,
                                                _email.text,
                                                _ifscCode.text,
                                                "",
                                                checked,
                                                selectedCompanyID,
                                                _aadharNo.text
                                                    .replaceAll("-", "")
                                                    .trim());
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (registerResult != null &&
                                            registerResult.data != null &&
                                            registerResult
                                                    .data!['registerPartner'] !=
                                                null) {
                                          print('regsiter success!!');
                                          await getUser(context);
                                        } else if (registerResult
                                            .hasException) {
                                          showCustomDialog(
                                              'Oops!!',
                                              'Registration Error - ${registerResult.exception!.graphqlErrors.first.message}.',
                                              context,
                                              null);
                                        }
                                      }
                                    } else {
                                      print("else state is wrking");
                                      if (!filledAcc)
                                        setState(() {
                                          erroraAccnt = true;
                                        });
                                      else {
                                        if (invalidAcc)
                                          setState(() {
                                            erroraAccnt = true;
                                          });
                                        else
                                          setState(() {
                                            erroraAccnt = false;
                                          });
                                      }
                                      if (!filledifsc)
                                        setState(() {
                                          errorIfsc = true;
                                        });
                                      else {
                                        if (invalidIfsc)
                                          setState(() {
                                            errorIfsc = true;
                                          });
                                        else
                                          setState(() {
                                            errorIfsc = false;
                                          });
                                      }
                                      if (checked && !filledCompany)
                                        setState(() {
                                          errorCompany = true;
                                        });
                                      else
                                        setState(() {
                                          errorCompany = false;
                                        });
                                    }
                                  }
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width / 2.5,
                                padding: EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: (_currWidgetIndex == 0 &&
                                              filledName &&
                                              (filledEmail && validEmail) &&
                                              (filledAadhar && validAadhar)) ||
                                          (_currWidgetIndex == 1 &&
                                              filledHouseNo &&
                                              filledLocality &&
                                              filledArea &&
                                              filledCity &&
                                              filledPostal &&
                                              !errorPostal) ||
                                          (_currWidgetIndex == 2 &&
                                              (filledAcc && !invalidAcc) &&
                                              (filledifsc && !invalidIfsc) &&
                                              ((checked && filledCompany) ||
                                                  (!checked && !filledCompany)))
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
                                    color: (_currWidgetIndex == 0 &&
                                                filledName &&
                                                (filledEmail && validEmail) &&
                                                (filledAadhar &&
                                                    validAadhar)) ||
                                            (_currWidgetIndex == 1 &&
                                                filledHouseNo &&
                                                filledLocality &&
                                                filledArea &&
                                                filledCity &&
                                                filledPostal &&
                                                !errorPostal) ||
                                            (_currWidgetIndex == 2 &&
                                                (filledAcc && !invalidAcc) &&
                                                (filledifsc && !invalidIfsc) &&
                                                ((checked && filledCompany) ||
                                                    (!checked &&
                                                        !filledCompany)))
                                        ? zimkeyWhite
                                        : zimkeyDarkGrey.withOpacity(0.5),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: 40,
                      // ),
                    ],
                  ),
                  // ),
                ),
              ),
      ),
    );
  }

  Widget personalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //name
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: errorName ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
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
                  maxLength: 50,
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
              IconButton(
                onPressed: () {
                  _name.clear();
                  setState(() {
                    filledName = false;
                  });
                },
                icon: Icon(
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
        //email
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    errorEmail ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
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
                        validEmail = true;
                      });
                    print('filledEmail ... $filledEmail');
                  },
                  onEditingComplete: () {
                    if (_email.text.isNotEmpty) {
                      setState(() {
                        errorEmail = !isEmail(_email.text);
                        validEmail = !errorEmail;
                      });
                    } else {
                      setState(() {
                        validEmail = true;
                        filledEmail = false;
                        errorEmail = false;
                      });
                    }
                    FocusScope.of(context).requestFocus(_aadharNoNode);
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
              IconButton(
                onPressed: () {
                  _email.clear();
                  setState(() {
                    filledEmail = false;
                    errorEmail = false;
                    validEmail = true;
                  });
                },
                icon: Icon(
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
        //aadhar
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    errorAadhar ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
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
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  // onTap: () {
                  //   if (_email.text.isNotEmpty) {
                  //     setState(() {
                  //       errorEmail = !isEmail(_email.text);
                  //       validEmail = !errorEmail;
                  //     });
                  //   } else {
                  //     setState(() {
                  //       validEmail = true;
                  //       filledEmail = false;
                  //       errorEmail = false;
                  //     });
                  //   }
                  // },
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      String thiAddhar = _aadharNo.text.replaceAll('-', '');
                      if (thiAddhar != null &&
                          thiAddhar.isNotEmpty &&
                          thiAddhar.length != 12)
                        setState(() {
                          validAadhar = false;
                          errorAadhar = true;
                          filledAadhar = false;
                        });
                      else
                        setState(() {
                          validAadhar = true;
                          errorAadhar = false;
                          filledAadhar = true;
                        });
                    }
                    print('filledAadhar ... $filledAadhar');
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
              IconButton(
                onPressed: () {
                  _aadharNo.clear();
                  setState(() {
                    filledAadhar = false;
                    errorAadhar = false;
                  });
                },
                icon: Icon(
                  Icons.clear,
                  color: filledAadhar ? zimkeyDarkGrey : zimkeyWhite,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        if (filledAadhar && !validAadhar)
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
      ],
    );
  }

  Widget addressFieldSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                color:
                    errorHouseNo ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
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
                  textCapitalization: TextCapitalization.words,
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
                    FocusScope.of(context).requestFocus(_localityNode);
                  },
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    counterText: "",
                    hintText: 'House / Flat / Floor No. *',
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
              IconButton(
                onPressed: () {
                  _houseNo.clear();
                  setState(() {
                    filledHouseNo = false;
                  });
                },
                icon: Icon(
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
                    FocusScope.of(context).requestFocus(_landmarkNode);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    counterText: "",
                    hintText: 'Apartment / Locality *',
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
              IconButton(
                onPressed: () {
                  _locality.clear();
                  setState(() {
                    filledLocality = false;
                  });
                },
                icon: Icon(
                  Icons.clear,
                  color: filledLocality ? zimkeyDarkGrey : zimkeyWhite,
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
                color: zimkeyDarkGrey2.withOpacity(0.1),
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
                    hintText: 'Landmark (Eg. Opposite school)',
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
              IconButton(
                onPressed: () {
                  _landmark.clear();
                  setState(() {
                    filledLandmark = false;
                  });
                },
                icon: Icon(
                  Icons.clear,
                  color: filledLandmark ? zimkeyDarkGrey : zimkeyWhite,
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
                color: errorCity ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
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
                    hintText: 'City *',
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
              IconButton(
                onPressed: () {
                  _city.clear();
                  setState(() {
                    filledCity = false;
                  });
                },
                icon: Icon(
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
                color: errorArea ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
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
                  maxLength: 100,
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
                    FocusScope.of(context).requestFocus(_postalCodeNode);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    counterText: "",
                    hintText: 'Town / Area (Eg. Kaloor) *',
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
              IconButton(
                onPressed: () {
                  _area.clear();
                  setState(() {
                    filledArea = false;
                    errorArea = false;
                  });
                },
                icon: Icon(
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
                color:
                    errorPostal ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
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
                    if (_postalCode.text.isNotEmpty &&
                        _postalCode.text.length == 6)
                      setState(() {
                        filledPostal = true;
                        errorPostal = false;
                      });
                    else
                      setState(() {
                        filledPostal = false;
                        errorPostal = true;
                      });
                    print('filledPostal ... $filledPostal');
                  },
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  onEditingComplete: () {
                    if (checked)
                      FocusScope.of(context).requestFocus(_companyNameNode);
                    else
                      FocusScope.of(context).requestFocus(_accNoNode);
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
              IconButton(
                onPressed: () {
                  _postalCode.clear();
                  setState(() {
                    filledPostal = false;
                  });
                },
                icon: Icon(
                  Icons.clear,
                  color: filledPostal ? zimkeyDarkGrey : zimkeyWhite,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        if (filledPostal && errorPostal)
          Container(
            margin: EdgeInsets.only(top: 3),
            child: Text(
              'Oops! Looks like the postal code (6 digits) is not a valid.',
              style: TextStyle(
                color: zimkeyRed,
                fontSize: 12,
              ),
            ),
          ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget officialDetailsSection() {
    return SizedBox(
      // height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                checked = !checked;
                _companyName.clear();
                errorCompany = false;
                filledCompany = false;
                print('checked ... $checked');
              });
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/icons/newIcons/tick-circle.svg',
                  color:
                      checked ? zimkeyOrange : zimkeyDarkGrey.withOpacity(0.5),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Focus(
                    focusNode: _areYouCompany,
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
                    color: errorCompany
                        ? zimkeyRed
                        : zimkeyDarkGrey2.withOpacity(0.1),
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
                    child: GestureDetector(
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
                      child: TextFormField(
                        focusNode: _companyNameNode,
                        controller: _companyName,
                        maxLength: 200,
                        enabled: false,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        // onChanged: (val) {
                        //   if (_companyName.text.isNotEmpty)
                        //     setState(() {
                        //       filledCompany = true;
                        //     });
                        //   else
                        //     setState(() {
                        //       filledCompany = false;
                        //     });
                        // },

                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(_accNoNode);
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
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    onPressed: () {
                      _companyName.clear();
                      selectedCompanyID = null;
                      setState(() {
                        filledCompany = false;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: filledCompany ? zimkeyDarkGrey : zimkeyWhite,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Bank Details',
            style: TextStyle(
                fontSize: 12,
                color: zimkeyBlack.withOpacity(0.5),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          //acc no
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: erroraAccnt
                      ? zimkeyRed
                      : zimkeyDarkGrey2.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/icons/newIcons/account.svg',
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    focusNode: _accNoNode,
                    controller: _accNo,
                    maxLength: 18,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      if (_accNo.text.isNotEmpty)
                        setState(() {
                          filledAcc = true;
                        });
                      else
                        setState(() {
                          filledAcc = false;
                          erroraAccnt = false;
                          invalidAcc = false;
                        });
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(_ifscNode);
                    },
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      counterText: "",
                      hintText: checked
                          ? 'Company Account Number *'
                          : 'Account Number *',
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
                IconButton(
                  onPressed: () {
                    _accNo.clear();
                    setState(() {
                      filledAcc = false;
                      erroraAccnt = false;
                      invalidAcc = false;
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: filledAcc ? zimkeyDarkGrey : zimkeyWhite,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          if (invalidAcc)
            Container(
              margin: EdgeInsets.only(top: 3),
              child: Text(
                'Oops! Looks like the account no. is not a valid (9-18 digits).',
                style: TextStyle(
                  color: zimkeyRed,
                  fontSize: 12,
                ),
              ),
            ),
          SizedBox(
            height: 15,
          ),
          //ifsc
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      errorIfsc ? zimkeyRed : zimkeyDarkGrey2.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/icons/newIcons/ifsc.svg',
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    focusNode: _ifscNode,
                    controller: _ifscCode,
                    maxLength: 11,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    onEditingComplete: () {
                      if (_ifscCode.text.isNotEmpty) {
                        setState(() {
                          errorIfsc = !validateIFSC(_ifscCode.text);
                          invalidIfsc = errorIfsc;
                        });
                      } else
                        setState(() {
                          filledifsc = false;
                          errorIfsc = false;
                          invalidIfsc = false;
                        });
                      // _ifscNode.unfocus();
                      print('invalidifsc ---- $invalidIfsc');
                    },
                    onChanged: (val) {
                      if (_ifscCode.text.isNotEmpty)
                        setState(() {
                          filledifsc = true;
                        });
                      else
                        setState(() {
                          filledifsc = false;
                          errorIfsc = false;
                          invalidIfsc = false;
                        });
                    },
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      counterText: "",
                      hintText: 'IFSC Code *',
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
                IconButton(
                  onPressed: () {
                    _ifscCode.clear();
                    setState(() {
                      filledifsc = false;
                      errorIfsc = false;
                      invalidIfsc = false;
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: filledifsc ? zimkeyDarkGrey : zimkeyWhite,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          if (invalidIfsc)
            Container(
              margin: EdgeInsets.only(top: 3),
              child: Text(
                'Oops! Looks like the IFSC code is not a valid.',
                style: TextStyle(
                  color: zimkeyRed,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
