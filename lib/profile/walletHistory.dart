import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../home/dashboard.dart';
import '../models/partnerModel.dart';
import '../shared/globalMutations.dart';
import '../shared/globals.dart';
import '../shared/gqlQueries.dart';
import '../theme.dart';

class WalletHistory extends StatefulWidget {
  WalletHistory({Key? key}) : super(key: key);

  @override
  State<WalletHistory> createState() => _WalletHistoryState();
}

class _WalletHistoryState extends State<WalletHistory> {
  bool loading = false;
  late PartnerUser partnerUser;
  List<PartnerWalletLog>? walletLogs = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: zimkeyWhite,
          elevation: 0,
          automaticallyImplyLeading: true,
          centerTitle: false,
          iconTheme: IconThemeData(
            color: zimkeyDarkGrey,
            size: 20,
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet Balance',
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
                        'Amount payable to Zimkey on account of cash on-hand payments',
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
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: zimkeyWhite,
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Query(
              options: QueryOptions(
                document: gql(getMe),
                fetchPolicy: FetchPolicy.noCache,
              ),
              builder: (
                QueryResult result2, {
                VoidCallback? refetch,
                FetchMore? fetchMore,
              }) {
                if (result2.isLoading)
                  return Center(child: sharedLoadingIndicator());
                else if (result2.data != null && result2.data!['me'] != null) {
                  partnerUser = PartnerUser.fromJson(result2.data!['me']);

                  walletLogs = partnerUser.partnerDetails!.walletLogs;
                } else if (result2.hasException) {
                  print('ME EXCEPTION $result2!!');
                }
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        //wallet widget--
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: zimkeyBodyOrange,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  if (partnerUser
                                          .partnerDetails!.walletBalance! <=
                                      0)
                                    SizedBox(
                                      height: 10,
                                    ),
                                  Text(
                                    'Wallet Balance',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: partnerUser.partnerDetails!
                                                .walletBalance! <=
                                            0
                                        ? 15
                                        : 7,
                                  ),
                                  Text(
                                    partnerUser.partnerDetails!.walletBalance! >
                                            0
                                        ? '₹${partnerUser.partnerDetails!.walletBalance}'
                                        : '₹0',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: zimkeyGreen,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // if (partnerUser
                                  //         .partnerDetails!.walletBalance! >
                                  //     0)
                                  // InkWell(
                                  //   onTap: () {
                                  //     if (partnerUser.partnerDetails!
                                  //             .walletBalance! >
                                  //         0)
                                  //       showRedeemWalletDialog(
                                  //           'Redeem Wallet',
                                  //           'Would you like to redeem your wallet balance of ₹${partnerUser.partnerDetails!.walletBalance}?',
                                  //           context,
                                  //           null);
                                  //   },
                                  //   child: Container(
                                  //     width:
                                  //         MediaQuery.of(context).size.width -
                                  //             250,
                                  //     padding: EdgeInsets.symmetric(
                                  //         horizontal: 10, vertical: 13),
                                  //     decoration: BoxDecoration(
                                  //       color: zimkeyOrange,
                                  //       borderRadius:
                                  //           BorderRadius.circular(30),
                                  //     ),
                                  //     child: Text(
                                  //       'Redeem',
                                  //       style: TextStyle(
                                  //           fontSize: 15,
                                  //           fontWeight: FontWeight.bold,
                                  //           color: zimkeyWhite),
                                  //       textAlign: TextAlign.center,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Wallet Transaction History',
                          style: TextStyle(
                            color: zimkeyDarkGrey.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TabBar(
                          labelColor: zimkeyBlack,
                          tabs: [
                            Tab(text: 'Credit'),
                            Tab(text: 'Debit'),
                          ],
                        ),
                        if (walletLogs != null && walletLogs!.isNotEmpty)
                          SizedBox(
                            height: 500,
                            child: TabBarView(
                              children: [
                                SizedBox(
                                  height: 300,
                                  child: Container(
                                    child: ListView(
                                      children: (walletLogs
                                                      ?.where((log) =>
                                                          log.logType ==
                                                          PartnerWalletLogTypeEnum
                                                              .CREDIT)
                                                      .length ??
                                                  0) ==
                                              0
                                          ? [
                                              SizedBox(
                                                height: 100,
                                              ),
                                              Center(
                                                child: Text(
                                                  'No transactions yet',
                                                  style: TextStyle(
                                                    color: zimkeyDarkGrey
                                                        .withOpacity(0.7),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ]
                                          : walletLogs!
                                              .where((element) =>
                                                  element.logType ==
                                                  PartnerWalletLogTypeEnum
                                                      .CREDIT)
                                              .map((e) => logItemWidget(e))
                                              .toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: Container(
                                    child: ListView(
                                      children: (walletLogs
                                                      ?.where((log) =>
                                                          log.logType ==
                                                          PartnerWalletLogTypeEnum
                                                              .DEBIT)
                                                      .length ??
                                                  0) ==
                                              0
                                          ? [
                                              SizedBox(
                                                height: 100,
                                              ),
                                              Center(
                                                child: Text(
                                                  'No transactions yet',
                                                  style: TextStyle(
                                                    color: zimkeyDarkGrey
                                                        .withOpacity(0.7),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ]
                                          : walletLogs!
                                              .where((element) =>
                                                  element.logType ==
                                                  PartnerWalletLogTypeEnum
                                                      .DEBIT)
                                              .map((e) => logItemWidget(e))
                                              .toList(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  Widget logItemWidget(PartnerWalletLog logItem) {
    String logtype;
    logtype = logItem.logType.toString();
    if (logtype != null && logtype.isNotEmpty) if (logtype.contains('.'))
      logtype = logtype.split('.')[1];
    String source;
    source = logItem.source.toString();
    if (source != null && source.isNotEmpty) if (source.contains('.'))
      source = source.split('.')[1];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: zimkeyWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: zimkeyLightGrey.withOpacity(0.1),
            blurRadius: 5.0, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
            offset: Offset(
              4.0, // Move to right 10  horizontally
              2.0, // Move to bottom 10 Vertically
            ),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$logtype',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: zimkeyDarkGrey.withOpacity(0.7),
                  ),
                ),
              ),
              // SizedBox(
              //   width: 10,
              // ),
              // Text(
              //   'Source - $source',
              //   style: TextStyle(
              //     fontSize: 12,
              //     fontWeight: FontWeight.bold,
              //     color: zimkeyOrange,
              //   ),
              // ),
            ],
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            'Transaction Date - ${DateTime.parse('${logItem.transactionDate}').day.toString().padLeft(2, '0')}-${DateTime.parse('${logItem.transactionDate}').month.toString().padLeft(2, '0')}-${DateTime.parse('${logItem.transactionDate}').year}',
            style: TextStyle(
              color: zimkeyDarkGrey,
              fontSize: 13,
            ),
          ),
          if (logItem.amount != null)
            Text(
              'Amount - ${logItem.amount}',
              style: TextStyle(
                color: zimkeyDarkGrey,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  showRedeemWalletDialog(
      String title, String msg, BuildContext context, Widget? backPage) {
    showDialog(
        context: context,
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
                padding: EdgeInsets.only(left: 20, right: 15, top: 15),
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
                    InkWell(
                      onTap: () {
                        if (backPage != null)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => backPage,
                            ),
                          );
                        else
                          Get.back();
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: zimkeyDarkGrey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.clear,
                          color: zimkeyDarkGrey,
                          size: 16,
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
              actions: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: MediaQuery.of(context).size.width - 200,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                    decoration: BoxDecoration(
                      color: zimkeyOrange,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          loading = true;
                        });
                        QueryResult redeemWalletResult =
                            await partnerRedeemWalletMutation(
                                partnerUser.partnerDetails!.walletBalance);
                        setState(() {
                          loading = false;
                        });
                        if (redeemWalletResult.hasException) {
                          print(
                              'redeemWalletResult Excption >>>>> ${redeemWalletResult.exception.toString()}');
                        }
                        if (redeemWalletResult != null &&
                            redeemWalletResult.data != null &&
                            redeemWalletResult.data!['partnerRedeemWallet'] !=
                                null) {
                          print('partnerRedeemWallet success!!!!!');
                          Get.back();
                          showCustomDialog(
                              "Yay",
                              'Your wallet has been successfully redeemed.',
                              context,
                              Dashboard(
                                index: 3,
                              ));
                        }
                      },
                      child: const Text(
                        'Redeem',
                        style: TextStyle(
                          color: zimkeyWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }
}
