import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../fbState.dart';
import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../theme.dart';
import 'selectServicableAreas.dart';
import 'setUpServiceList.dart';
import 'signUpDetails.dart';
import 'uploadDProfilePic.dart';

class UploadDocuments extends StatefulWidget {
  UploadDocuments({Key? key}) : super(key: key);

  @override
  _UploadDocumentsState createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  final FbState fbState = Get.find();
  late var response;
  String? frontphotoId = "";
  String? backphotoId = "";

  String otherId = "";
  String? photoId = "";
  File? _image;
  final picker = ImagePicker();
  File? imgFile;
  FormData? formData;
  String? fileName;
  DocOptions? selectedDocType;
  List<String?> mediaIds = [];
  String frontImagePath = "";
  bool isLoading = false;
  String firstDocType = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  bool aadharUplaoded = false;
  bool frontAndBack = false;
  String frontDoc = "";
  List<DocOptions> docOptions = [];

  Future<String> calculateHash(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> areFilesIdentical(String filePath1, String filePath2) async {
    final hash1 = await calculateHash(filePath1);
    final hash2 = await calculateHash(filePath2);
    return hash1 == hash2;
  }

  Future getImage(DocOptions? doctype, String? frontOrBack) async {
    if (doctype != null) {
      await Permission.photos.request();
      var permissionStatus = await Permission.photos.status;
      // if (permissionStatus.isGranted || permissionStatus.isLimited) {
      var pickedFile;
      setState(() {
        isLoading = true;
      });
      await picker.pickImage(source: ImageSource.gallery).then((value) async {
        pickedFile = value;
        if (pickedFile != null) {
          firstDocType = doctype.doctype ?? "";
          if (frontOrBack == "back") {
            final isSameImage =
                await areFilesIdentical(frontImagePath, value?.path ?? "");
            print("wokring on back front image $isSameImage");
            if (isSameImage) {
              print("showing dialog 12");
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select another image.")));
            } else {
              uploadImage(pickedFile.path, doctype.code, frontOrBack)
                  .then((value) async {
                if (value!.isNotEmpty) {
                  //success
                  setState(() {
                    isLoading = false;
                    photoId = value;
                    mediaIds.add(photoId);
                    _image = File(pickedFile.path);
                  });
                  if (frontOrBack != null) {
                    if (frontOrBack == "front")
                      setState(() {
                        frontDoc = doctype.doctype ?? "";
                        frontphotoId = photoId;
                        frontImagePath = pickedFile.path;
                        selectedDocType!.frontId = frontphotoId;
                        if (backphotoId != null) {
                          frontAndBack = true;
                        }
                      });
                    else if (frontOrBack == "back") {
                      setState(() {
                        backphotoId = photoId;
                        selectedDocType!.backId = backphotoId;
                      });
                    }
                  }
                  //runmutation
                } // } else {
                //   showCustomDialog(
                //       'Oops!!', 'Upload Error - Please try again.', context, null);
                // }
              });
              print("showing dialog");
            }
          } else {
            uploadImage(pickedFile.path, doctype.code, frontOrBack)
                .then((value) async {
              if (value!.isNotEmpty) {
                //success
                setState(() {
                  isLoading = false;
                  photoId = value;
                  mediaIds.add(photoId);
                  _image = File(pickedFile.path);
                });
                if (frontOrBack != null) {
                  if (frontOrBack == "front")
                    setState(() {
                      frontphotoId = photoId;
                      frontImagePath = pickedFile.path;
                      selectedDocType!.frontId = frontphotoId;
                    });
                  else if (frontOrBack == "back") {
                    setState(() {
                      backphotoId = photoId;
                      selectedDocType!.backId = backphotoId;
                    });
                  }
                }
                //runmutation
                // var result = await uploadDocMutation(doctype.code, mediaIds);
                // setState(() {
                //   isLoading = false;
                // });
                // if (result != null &&
                //     result.data != null &&
                //     result.data!['updatePartnerDocument'] != null) {
                //   print('success  partner upload!!!!!');
                //   for (DocOptions op in docOptions) {
                //     if (op.code == doctype.code) {
                //       setState(() {
                //         op.isUploaded = true;
                //         op.mediaId!.add(photoId);
                //       });
                //     }
                //   }
                // } else {
                //   setState(() {
                //     _image = null;
                //     photoId = null;
                //   });
                //   for (DocOptions op in docOptions) {
                //     if (op.code == doctype.code) {
                //       setState(() {
                //         op.mediaId!
                //             .removeWhere((element) => element == photoId);
                //       });
                //       if (op.mediaId == null || op.mediaId!.isEmpty)
                //         setState(() {
                //           op.isUploaded = false;
                //         });
                //       if (frontOrBack != null && frontOrBack == "front")
                //         setState(() {
                //           frontphotoId = null;
                //           op.frontId = null;
                //         });
                //       else if (frontOrBack != null && frontOrBack == "back")
                //         setState(() {
                //           backphotoId = null;
                //           op.backId = null;
                //         });
                //     }
                //   }
                //   showCustomDialog('Oops!!', 'Upload Error - Please try again.',
                //       context, null);
                // }
              } // } else {
              //   showCustomDialog(
              //       'Oops!!', 'Upload Error - Please try again.', context, null);
              // }
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          showCustomDialog('Oops!!', 'Image selection error!', context, null);
        }
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
        print('Error upload ......> $onError');
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomDialog('Oops!!', 'Select a document type', context, null);
    }
  }

  Future<String?> uploadImage(
      String file, DocumentTypeEnum? doctype, String? frontOrBack) async {
    String uploadURL =
        'https://staging.api.zimkey.in/media-upload/document-upload';
    Dio dio = new Dio();
    dio.options.headers["Authorization"] = fbState.token.value;
    fileName = file.split('.').last;
    fileName = '${doctype}_$frontOrBack.$fileName';
    String? photo = '';
    formData = FormData.fromMap({
      "document": await MultipartFile.fromFile(
        file,
        filename: fileName,
      ),
    });
    await dio.post(uploadURL, data: formData).then((value) {
      response = value;
      if (response.data['status'] == 200) {
        photo = response.data['data']['id'];
        print('seuccess');
      }
    }).onError((DioError error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      if (error.response!.statusCode == 413) {
        showCustomDialog('Oops!!',
            'File size too big.Upload size limit is 10 MB.', context, null);
        print('file size too big');
      } else {
        showCustomDialog('Oops!!',
            'Upload error - ${error.response!.statusMessage}', context, null);
        print('Upload Erroor!! $error');
      }
    });
    return photo;
  }

  @override
  void initState() {
    //Init doc options-------------
    docOptions.add(DocOptions(
        doctype: 'Aadhar',
        icon: 'assets/images/icons/newIcons/aadharIcon.svg',
        code: DocumentTypeEnum.AADHAR,
        isUploaded: false,
        isTile: true,
        mediaId: []));

    docOptions.add(DocOptions(
        doctype: 'PAN Card',
        icon: 'assets/images/icons/newIcons/pan.svg',
        code: DocumentTypeEnum.PAN,
        isUploaded: false,
        isTile: true,
        mediaId: []));

    docOptions.add(DocOptions(
        doctype: 'Ration Card',
        icon: 'assets/images/icons/newIcons/pan.svg',
        code: DocumentTypeEnum.RATION_ID,
        isUploaded: false,
        isTile: true,
        mediaId: []));

    docOptions.add(DocOptions(
        doctype: 'Driving License',
        icon: 'assets/images/icons/newIcons/license.svg',
        code: DocumentTypeEnum.DRIVING_LICENSE,
        isUploaded: false,
        isTile: true,
        mediaId: []));

    docOptions.add(DocOptions(
        doctype: 'Voters Id',
        icon: 'assets/images/icons/newIcons/voterID.svg',
        code: DocumentTypeEnum.VOTER_ID,
        isUploaded: false,
        isTile: true,
        mediaId: []));

    docOptions.add(DocOptions(
        doctype: 'Passport',
        icon: 'assets/images/icons/newIcons/passport.svg',
        code: DocumentTypeEnum.PASSPORT,
        isUploaded: false,
        isTile: true,
        mediaId: []));

    docOptions.add(DocOptions(
        doctype: 'Vaccination Certificate',
        code: DocumentTypeEnum.OTHER,
        isUploaded: false,
        isTile: false,
        mediaId: []));

    docOptions.add(DocOptions(
        doctype: 'Business License',
        code: DocumentTypeEnum.BUSINESS_LICENSE,
        isUploaded: false,
        isTile: false,
        mediaId: []));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              // leading: IconButton(
              //   icon: Icon(
              //     Icons.arrow_back_ios_rounded,
              //     size: 18,
              //     color: zimkeyDarkGrey,
              //   ),
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              backgroundColor: zimkeyWhite,
              elevation: 0,
            ),
            bottomNavigationBar: SizedBox(
              height: 55,
              child: GestureDetector(
                onTap: () async {
                  var result =
                      await uploadDocMutation(selectedDocType!.code, mediaIds);
                  setState(() {
                    isLoading = false;
                  });
                  if (result != null &&
                      result.data != null &&
                      result.data!['updatePartnerDocument'] != null) {
                    print('success  partner upload!!!!!');
                    for (DocOptions op in docOptions) {
                      if (op.code == selectedDocType!.code) {
                        setState(() {
                          op.isUploaded = true;
                          op.mediaId!.add(photoId);
                        });
                      }
                    }
                  } else {
                    setState(() {
                      _image = null;
                      photoId = null;
                    });
                    for (DocOptions op in docOptions) {
                      if (op.code == selectedDocType!.code) {
                        setState(() {
                          op.mediaId!
                              .removeWhere((element) => element == photoId);
                        });
                        if (op.mediaId == null || op.mediaId!.isEmpty)
                          setState(() {
                            op.isUploaded = false;
                          });
                      }
                    }
                    showCustomDialog('Oops!!',
                        'Upload Error - Please try again.', context, null);
                  }
                  for (DocOptions options in docOptions) {
                    if (options.isUploaded != null && options.isUploaded!)
                      for (String? ids in options.mediaId!) {
                        mediaIds.add(ids);
                      }
                  }
                  if (mediaIds != null && mediaIds.isNotEmpty) {
                    for (DocOptions op in docOptions) {
                      if (op.doctype!.toLowerCase() == 'aadhar' &&
                          op.isUploaded == true)
                        setState(() {
                          aadharUplaoded = true;
                        });
                    }
                    // if (!aadharUplaoded)
                    //   showCustomDialog('Oops!',
                    //       'Aadhar card copy must be uploaded.', context, null);
                    // else {
                    PartnerUser partnerUser;
                    List<PartnerPendingTaskEnum?>? partnerProgressStage = [];
                    var userResult = await getUserOnly();
                    if (userResult != null &&
                        userResult.data != null &&
                        userResult.data!['me'] != null) {
                      print('logged in user ');
                      partnerUser =
                          PartnerUser.fromJson(userResult.data!['me']);
                      fbState.setPartnerUser(partnerUser);
                      fbState.setIsRegistered(
                          partnerUser.isPartnerRegistered.toString());
                      if (partnerUser != null &&
                          partnerUser.isPartnerRegistered!) {
                        if (partnerUser.userType!.toLowerCase() != "customer" &&
                            partnerUser.partnerDetails != null) {
                          //Check Partner progress
                          partnerProgressStage.clear();
                          if (partnerUser.partnerDetails != null &&
                              partnerUser.partnerDetails!.pendingTasks !=
                                  null &&
                              partnerUser
                                  .partnerDetails!.pendingTasks!.isNotEmpty) {
                            print("somtthing related");
                            partnerProgressStage =
                                partnerUser.partnerDetails!.pendingTasks;
                            fbState.setPartnerProgress(partnerProgressStage!);
                            String stage = partnerProgressStage[0].toString();
                            print(stage);
                            if (stage.contains('.'))
                              stage = stage.split('.')[1];
                            switch (stage) {
                              case 'UPLOAD_PROFILE_PICTURE':
                                {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: UploadProfilePic(),
                                        duration: Duration(milliseconds: 400),
                                      ));
                                  break;
                                }
                              case 'UPLOAD_DOCUMENT':
                                {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: UploadDocuments(),
                                        duration: Duration(milliseconds: 400),
                                      ));
                                  break;
                                }
                              case 'SELECT_SERVICE':
                                {
                                  Navigator.push(
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
                                  Navigator.push(
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
                            }
                          } else {
                            print("else wokring");
                            sugnupConfirmationDialog('Thank You!',
                                'We have recievd your registration request. You will be contacted shortly.');
                          }
                        } else {
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
                    }
                    // }
                  } else {
                    showCustomDialog(
                        'Oops!',
                        "Kindly upload atleast one document for verification.",
                        context,
                        null);
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width - 190,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: zimkeyOrange,
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
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              color: zimkeyWhite,
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Documents',
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
                            'Please upload documents',
                            style: TextStyle(
                              fontSize: 13,
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
                  Container(
                    // color: zimkeyGreen,
                    height: MediaQuery.of(context).size.height / 1.4,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        if (selectedDocType != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedDocType = null;
                                backphotoId = null;
                                frontphotoId = null;
                                // _image = null;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 100,
                              decoration: BoxDecoration(
                                color: zimkeyWhite,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: zimkeyLightGrey.withOpacity(0.1),
                                    blurRadius: 2.0, // soften the shadow
                                    spreadRadius: 2.0, //extend the shadow
                                    offset: Offset(
                                      1.0, // Move to right 10  horizontally
                                      1.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 7),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chevron_left_outlined,
                                    color: zimkeyOrange,
                                  ),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      color: zimkeyOrange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 15,
                        ),
                        if (selectedDocType == null)
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                for (DocOptions options in docOptions)
                                  if (options.isTile != null && options.isTile!)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedDocType = options;
                                        });
                                      },
                                      child: Container(
                                        height: 110,
                                        child: Stack(
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          4.5,
                                                  minWidth: 60,
                                                  maxHeight: 120,
                                                  minHeight: 80),
                                              width: 92,
                                              height: 92,
                                              decoration: BoxDecoration(
                                                color: zimkeyBodyOrange,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: options.isUploaded!
                                                      ? zimkeyOrange
                                                      : zimkeyBodyOrange,
                                                ),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 0),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 5),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // Icon(Icons.document_scanner),
                                                  SvgPicture.asset(
                                                      options.icon!),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    options.doctype!,
                                                    style: TextStyle(
                                                      color: zimkeyDarkGrey,
                                                      fontSize: 11,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                            if (options.isUploaded!)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: zimkeyOrange,
                                                  ),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: zimkeyWhite,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        if (selectedDocType != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (firstDocType != "" &&
                                      firstDocType ==
                                          selectedDocType?.doctype) {
                                    getImage(selectedDocType, 'front');
                                  } else if (firstDocType == "") {
                                    getImage(selectedDocType, 'front');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Please select same doc")));
                                  }
                                },
                                child: uploadTile('front', selectedDocType),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  if (firstDocType != "" &&
                                      firstDocType ==
                                          selectedDocType?.doctype) {
                                    getImage(selectedDocType, 'back');
                                  } else if (firstDocType == "") {
                                    getImage(selectedDocType, 'back');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Please select same doc")));
                                  }
                                },
                                child: uploadTile('back', selectedDocType),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 15,
                        ),
                        if (selectedDocType == null)
                          Column(
                            children: [
                              for (DocOptions options in docOptions)
                                if (options.isTile != null && !options.isTile!)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.only(
                                        bottom: 10, top: 10, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        color: zimkeyLightGrey,
                                        borderRadius: BorderRadius.circular(5)
                                        // border: Border(
                                        //   bottom: BorderSide(
                                        //     color: zimkeyDarkGrey.withOpacity(0.2),
                                        //   ),
                                        // ),
                                        ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          options.isUploaded = false;
                                        });
                                        getImage(options, null);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              options.doctype!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: zimkeyDarkGrey,
                                              ),
                                            ),
                                          ),
                                          _image != null && options.isUploaded!
                                              ? InkWell(
                                                  onTap: () {
                                                    for (DocOptions op
                                                        in docOptions) {
                                                      if (op.code ==
                                                          options.code) {
                                                        setState(() {
                                                          op.isUploaded = false;
                                                          op.mediaId!.clear();
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: zimkeyOrange,
                                                    ),
                                                    child: Icon(
                                                      Icons.clear,
                                                      color: zimkeyWhite,
                                                      size: 14,
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.add,
                                                  size: 18,
                                                  color: zimkeyOrange,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // SizedBox(
                  //   height: 5,
                  // ),
                ],
              ),
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

  Widget uploadTile(String docSide, DocOptions? selectedDocType) {
    return Container(
      height: 110,
      width: 100,
      child: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 3,
                  minWidth: 70,
                  maxHeight: 100,
                  minHeight: 80),
              width: 90,
              height: 90,
              decoration: docSide != null && docSide == "front"
                  ? BoxDecoration(
                      color: zimkeyBodyOrange,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: selectedDocType!.frontId != null &&
                                selectedDocType.frontId!.isNotEmpty
                            ? zimkeyOrange
                            : zimkeyBodyOrange,
                      ),
                    )
                  : BoxDecoration(
                      color: zimkeyBodyOrange,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: selectedDocType!.backId != null &&
                                selectedDocType.backId!.isNotEmpty
                            ? zimkeyOrange
                            : zimkeyBodyOrange,
                      ),
                    ),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon(Icons.document_scanner),
                  docSide != null && docSide == "front"
                      ? SvgPicture.asset(
                          selectedDocType.frontId != null &&
                                  selectedDocType.frontId!.isNotEmpty
                              ? 'assets/images/icons/newIcons/gallery-tick.svg'
                              : 'assets/images/icons/newIcons/gallery-add.svg',
                          height: 30,
                          color: zimkeyOrange,
                        )
                      : SvgPicture.asset(
                          selectedDocType.backId != null &&
                                  selectedDocType.backId!.isNotEmpty
                              ? 'assets/images/icons/newIcons/gallery-tick.svg'
                              : 'assets/images/icons/newIcons/gallery-add.svg',
                          height: 30,
                          color: zimkeyOrange,
                        ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    docSide != null && docSide == "front" ? 'Front' : 'Back',
                    style: TextStyle(
                      color: zimkeyDarkGrey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
          (docSide != null &&
                      docSide == "front" &&
                      selectedDocType.frontId != null &&
                      selectedDocType.frontId!.isNotEmpty) ||
                  (docSide != null &&
                      docSide == "back" &&
                      selectedDocType.backId != null &&
                      selectedDocType.backId!.isNotEmpty)
              ? Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      for (DocOptions options in docOptions) {
                        if (options.code == selectedDocType.code) {
                          if (docSide != null && docSide == "front")
                            setState(() {
                              options.mediaId!.removeWhere(
                                  (element) => element == options.frontId);
                              frontphotoId = null;
                              options.frontId = null;
                            });
                          else if (docSide != null && docSide == "back")
                            setState(() {
                              options.mediaId!.removeWhere(
                                  (element) => element == options.backId);
                              backphotoId = null;
                              options.backId = null;
                            });
                          //if any one media removed, the set flag as false
                          setState(() {
                            options.isUploaded = false;
                          });
                        }
                      }
                      print('cancelled!!!!!!!');
                    },
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: zimkeyOrange,
                      ),
                      child: Icon(
                        Icons.clear,
                        color: zimkeyWhite,
                        size: 18,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 0,
                )
        ],
      ),
    );
  }

  sugnupConfirmationDialog(String title, String msg) {
    showDialog(
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
          padding: EdgeInsets.only(left: 20, top: 20),
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
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: new InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: Dashboard(),
                      duration: Duration(milliseconds: 400),
                    ));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width / 3,
                padding: EdgeInsets.symmetric(
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: zimkeyOrange,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: zimkeyLightGrey.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 1.0, //extend the shadow
                      offset: Offset(
                        2.0, // Move to right 10  horizontally
                        1.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                child: Text(
                  'Proceed',
                  style: TextStyle(
                    color: zimkeyWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      context: context,
    );
  }
}

class DocOptions {
  String? doctype;
  String? icon;
  DocumentTypeEnum? code;
  bool? isUploaded;
  List<String?>? mediaId;
  bool? isTile;
  String? frontId;
  String? backId;

  DocOptions({
    this.code,
    this.doctype,
    this.icon,
    this.isUploaded,
    this.mediaId,
    this.isTile,
    this.backId,
    this.frontId,
  });
}
