import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../theme.dart';

class UploadProfilePic extends StatefulWidget {
  UploadProfilePic({Key? key}) : super(key: key);

  @override
  State<UploadProfilePic> createState() => _UploadProfilePicState();
}

class _UploadProfilePicState extends State<UploadProfilePic> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  late var response;
  String? photoId = "";
  XFile? pickedFile;
  File? _image;
  final picker = ImagePicker();
  File? imgFile;
  //---------------------------
  //Image Selection--------------
  Future getImage() async {
    setState(() {
      // isLoading = true;
    });
    var permission = await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    // if (permissionStatus.isGranted || permissionStatus.isLimited) {
    XFile? oldPickedFile;
    await picker.pickImage(source: ImageSource.gallery).then((value) async {
      setState(() {
        oldPickedFile = pickedFile;
        pickedFile = value;
        // isLoading = false;
      });
      if (pickedFile != null) {
        await uploadImage(pickedFile!.path).then((value) {
          setState(() {
            photoId = value;
            if (photoId!.isNotEmpty) _image = File(pickedFile!.path);
          });
        });
      } else {
        setState(() {
          pickedFile = oldPickedFile;
        });
        showCustomDialog('Oops!!', 'Image selection error!', context, null);
      }
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
      print('error>>> $onError');
    });
  }

//Upload Image Post API------
  Future<String?> uploadImage(String file) async {
    String uploadURL =
        'https://staging.api.zimkey.in/media-upload/profile-upload/';
    Dio dio = new Dio();
    dio.options.headers["Authorization"] = "${fbState.token.value}";

    String fileName = file.split('/').last;
    String? photo = '';
    FormData formData = FormData.fromMap({
      "document": await MultipartFile.fromFile(
        file,
        filename: fileName,
      ),
    });
    await dio
        .post(
      uploadURL,
      data: formData,
    )
        .then((value) {
      response = value;
      if (response.data['status'] == 200) {
        photo = response.data['data']['id'];
        print('seuccess');
      }
    }).onError((DioError error, stackTrace) {
      if (error.response!.statusCode == 413) {
        showCustomDialog('Oops!!',
            'File size too big. Upload size limit is 10 MB.', context, null);
        print('${error.response!.statusMessage}');
      } else if (error.response!.statusCode == 403) {
        showCustomDialog('Oops!!',
            'Upload Error - ${error.response!.statusMessage}', context, null);
      } else if (error.response!.statusCode == 500) {
        showCustomDialog('Oops!!',
            'Upload Error - ${error.response!.statusMessage}', context, null);
      } else {
        showCustomDialog('Oops!!',
            'Upload Error - ${error.response!.statusMessage}', context, null);
        print('Upload Erroor!! $error');
      }
    });
    return photo;
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
          ),
          body: Container(
            color: zimkeyWhite,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 0,
              bottom: 0,
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload a Profile Picture',
                              style: TextStyle(
                                fontSize: 20,
                                color: zimkeyBlack,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Kindly upload your most recent profile picture.',
                              style: TextStyle(
                                fontSize: 11,
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
                              // height: MediaQuery.of(context).size.height - 200,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (fbState != null &&
                                      fbState.partnerUser != null &&
                                      fbState.partnerUser.value != null &&
                                      fbState.partnerUser.value!.phone !=
                                          null &&
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
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  // color: Colors.pink[50],
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: _image == null
                      ? InkWell(
                          onTap: () async {
                            await getImage();
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                'assets/images/icons/newIcons/gallery-add.svg',
                                height: 110,
                                color: zimkeyDarkGrey.withOpacity(0.7),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Upload Profile Picture (Max size 10 MB)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: zimkeyOrange,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: new FileImage(_image!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await getImage();
                                  },
                                  child: Text(
                                    'Change',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: zimkeyOrange,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _image = null;
                                      pickedFile = null;
                                    });
                                  },
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: zimkeyOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                ),
                InkWell(
                  onTap: (() async {
                    if (pickedFile != null &&
                        photoId != null &&
                        photoId!.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });
                      var updateDataResult = await updatePartnerDetailsMutation(
                          null, null, null, photoId, null, null);
                      setState(() {
                        isLoading = false;
                      });
                      print(updateDataResult);
                      if (updateDataResult.data != null &&
                          updateDataResult.data!['updatePartnerDetails'] !=
                              null) {
                        print("this is wrking");
                        try {
                          showCustomDialog(
                              'Yay!!',
                              'Your profile pic has been successfully updated.',
                              context,
                              null);
                        } catch (e) {}
                        await getUser(context);
                      } else if (updateDataResult.hasException) {
                        showCustomDialog(
                            'Oops!!',
                            'Exception - ${updateDataResult.exception!.graphqlErrors.first.message}.',
                            context,
                            null);
                      }
                    }
                  }),
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - 200,
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                    decoration: BoxDecoration(
                      color: pickedFile != null ? zimkeyOrange : zimkeyWhite,
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
                      'Upload',
                      style: TextStyle(
                        fontSize: 16,
                        color: pickedFile != null
                            ? Colors.white
                            : zimkeyBlack.withOpacity(0.5),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Center(
            child: sharedLoadingIndicator(),
          ),
      ],
    );
  }
}
