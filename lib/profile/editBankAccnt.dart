import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../theme.dart';

class EditBankAccount extends StatefulWidget {
  final PartnerUser? userDetails;
  EditBankAccount({
    Key? key,
    this.userDetails,
  }) : super(key: key);

  @override
  State<EditBankAccount> createState() => _EditBankAccountState();
}

class _EditBankAccountState extends State<EditBankAccount> {
  TextEditingController _accnNo = TextEditingController();
  TextEditingController _ifsc = TextEditingController();

  FocusNode _accnNoNode = FocusNode();
  FocusNode _ifscNode = FocusNode();

  bool filledaccno = false;
  bool filledIfsc = false;

  bool erroraccnNo = false;
  bool errorIfsc = false;
  bool invalidAcc = false;
  bool invalidIfsc = false;

  bool isLoading = false;

//--------------------
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
            focusNode: _accnNoNode,
            onTapAction: () {
              if (_accnNo.text.isNotEmpty) {
                setState(() {
                  erroraccnNo = !validateAccountNo(_accnNo.text);
                  invalidAcc = erroraccnNo;
                });
              } else
                setState(() {
                  filledaccno = false;
                  erroraccnNo = false;
                  invalidAcc = false;
                });
              print('invalidAcc ... $invalidAcc');
            }),
        KeyboardActionsItem(
            focusNode: _ifscNode,
            onTapAction: () {
              if (_ifsc.text.isNotEmpty) {
                setState(() {
                  errorIfsc = !validateIFSC(_ifsc.text);
                  invalidIfsc = errorIfsc;
                });
              } else
                setState(() {
                  filledIfsc = false;
                  errorIfsc = false;
                  invalidIfsc = false;
                });
              _ifscNode.unfocus();
              print('invalidifsc ---- $invalidIfsc');
            }),
      ],
    );
  }

  @override
  void initState() {
    _ifsc.text = widget.userDetails != null &&
            widget.userDetails!.partnerDetails != null &&
            widget.userDetails!.partnerDetails!.ifsc != null
        ? widget.userDetails!.partnerDetails!.ifsc!
        : "";
    if (_ifsc.text.isNotEmpty) filledIfsc = true;
    _accnNo.text = widget.userDetails != null &&
            widget.userDetails!.partnerDetails != null &&
            widget.userDetails!.partnerDetails!.accountNumber != null
        ? widget.userDetails!.partnerDetails!.accountNumber!
        : "";
    if (_accnNo.text.isNotEmpty) filledaccno = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: zimkeyDarkGrey,
              size: 20,
            ),
            automaticallyImplyLeading: true,
            backgroundColor: zimkeyBgWhite,
            elevation: 0,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            color: zimkeyWhite,
            child: KeyboardActions(
              config: _buildConfig(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Bank Account',
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
                        'Update your bank account details.',
                        style: TextStyle(
                          fontSize: 12,
                          color: zimkeyBlack.withOpacity(0.6),
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: erroraccnNo
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/account.svg',
                          height: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _accnNo,
                            focusNode: _accnNoNode,
                            maxLength: 30,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              if (_accnNo.text.isNotEmpty)
                                setState(() {
                                  filledaccno = true;
                                  erroraccnNo = false;
                                });
                              else
                                setState(() {
                                  filledaccno = false;
                                });
                              print('filledaccno ... $filledaccno');
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_ifscNode);
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              counterText: "",
                              hintText: 'Bank Account No.',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: widget.userDetails != null &&
                                        widget.userDetails!.partnerDetails !=
                                            null &&
                                        widget.userDetails!.partnerDetails!
                                                .accountNumber !=
                                            null
                                    ? zimkeyDarkGrey
                                    : zimkeyBlack.withOpacity(0.3),
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
                            _accnNo.clear();
                            setState(() {
                              filledaccno = false;
                              invalidAcc = false;
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            size: 16,
                            color: filledaccno ? zimkeyDarkGrey : zimkeyWhite,
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
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorIfsc
                              ? zimkeyRed
                              : zimkeyDarkGrey2.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/newIcons/ifsc.svg',
                          height: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _ifsc,
                            focusNode: _ifscNode,
                            maxLength: 200,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            onChanged: (val) {
                              if (_ifsc.text.isNotEmpty &&
                                  _ifsc.text.length == 11) {
                                setState(() {
                                  filledIfsc = true;
                                  errorIfsc = false;
                                  invalidIfsc = false;
                                });
                              } else {
                                setState(() {
                                  invalidIfsc = true;
                                  filledIfsc = false;
                                });
                              }
                              print('filledIfsc ... $filledIfsc');
                            },
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              counterText: "",
                              hintText: 'IFSC Code',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: widget.userDetails != null &&
                                        widget.userDetails!.partnerDetails !=
                                            null &&
                                        widget.userDetails!.partnerDetails!
                                                .ifsc !=
                                            null
                                    ? zimkeyDarkGrey
                                    : zimkeyBlack.withOpacity(0.3),
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
                            _ifsc.clear();
                            setState(() {
                              filledIfsc = false;
                              invalidAcc = false;
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            size: 16,
                            color: filledIfsc ? zimkeyDarkGrey : zimkeyWhite,
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
                  SizedBox(
                    height: 35,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (!invalidIfsc) {
                          if (filledIfsc || filledaccno) {
                            setState(() {
                              isLoading = true;
                            });
                            QueryResult updateAccResult =
                                await updatePartnerAccountMutation(
                                    _accnNo.text, _ifsc.text);
                            setState(() {
                              isLoading = false;
                            });
                            if (updateAccResult.hasException) {
                              print(updateAccResult.exception);
                              showCustomDialog(
                                  'Oops!',
                                  "${updateAccResult.exception.toString()}",
                                  context,
                                  null);
                            } else if (updateAccResult != null &&
                                updateAccResult.data != null &&
                                updateAccResult
                                        .data!['updatePartnerPayoutAccount'] !=
                                    null) {
                              showCustomDialog(
                                  'Yay!',
                                  "Your bank account details has been updated successfully!",
                                  context,
                                  Dashboard(
                                    index: 3,
                                  ));
                            }
                          } else
                            showCustomDialog(
                                'Oops!',
                                'Fill atleast one field to update.',
                                context,
                                null);
                        }
                      },
                      child: Container(
                        width: 130,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 13),
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
                                3.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
                            color: zimkeyBgWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading) Center(child: sharedLoadingIndicator()),
      ],
    );
  }
}
