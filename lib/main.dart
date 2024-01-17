import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:zimkey_partner_app/theme.dart';

import 'fbState.dart';
import 'home/dashboard.dart';
import 'login/login.dart';
import 'shared/globals.dart';
import 'signup/setUpLocation.dart';
import 'signup/setUpServiceList.dart';
import 'signup/signUpDetails.dart';
import 'signup/uploadDocuments.dart';
import 'splash/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHiveForFlutter();
  await GetStorage.init();
  //-----Lock Potrait oreintation - android
  WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://c8839390b37147d281f0ae3b2477e0ca@o1307426.ingest.sentry.io/6551876';
    },
    appRunner: () =>
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
            .then((_) {
      runApp(MyApp());
    }),
  );
}

class MyApp extends StatelessWidget {
  final FbState fbState = Get.put(FbState());
  late AuthLink authLink;
  late HttpLink httpLink;
  ValueNotifier<GraphQLClient>? client;

  initClient() {
    var storage = GetStorage();
    String? t = storage.read("token");
    if (t != null) {
      fbState.token.value = t;
    }

    authLink = AuthLink(getToken: () async {
      if (fbState == null) return '';
      print('token from main ------------ ${fbState.token.value}');
      return fbState.token.value;
    });

    if (t != null) {
      httpLink = HttpLink(
        'https://staging.api.zimkey.in/graphql',
        defaultHeaders: {
          'x-source-platform': 'PARTNER_APP',
          'Authorization': t
        },
      );
    } else {
      httpLink = HttpLink(
        'https://staging.api.zimkey.in/graphql',
        defaultHeaders: {
          'x-source-platform': 'PARTNER_APP',
        },
      );
    }

    final Link link = authLink.concat(httpLink);

    client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initClient();
    globalGQLClient = client;
    return GraphQLProvider(
      client: client,
      child: GetMaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Splash(),
          '/splash': (context) => Splash(),
          '/login': (context) => Login(),
          '/signup': (context) => SignUpDetails(),
          '/setLoc': (context) => SetupLocation(),
          '/setServices': (context) => SetUpServiceList(),
          '/dashboard': (context) => Dashboard(),
          '/uploadDocs': (context) => UploadDocuments(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Zimkey Partner App',
        theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Inter',
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: zimkeyOrange)),
      ),
    );
  }
}
