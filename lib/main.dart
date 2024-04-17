import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:zimkey_partner_app/theme.dart';

import 'fbState.dart';
import 'firebase_options.dart';
import 'home/dashboard.dart';
import 'login/login.dart';
import 'notification.dart';
import 'shared/globals.dart';
import 'signup/setUpLocation.dart';
import 'signup/setUpServiceList.dart';
import 'signup/signUpDetails.dart';
import 'signup/uploadDocuments.dart';
import 'splash/splash.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initHiveForFlutter();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationService().init();
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

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        cache: GraphQLCache(partialDataPolicy: PartialDataCachePolicy.reject),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
        navigatorKey: navigatorKey,
        builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                      MediaQuery.of(context).size.shortestSide < 600
                          ? 0.85
                          : 1.5)),
              child: child!);
        },
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
            useMaterial3: false,
            progressIndicatorTheme:
                ProgressIndicatorThemeData(color: zimkeyOrange),
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: zimkeyOrange)),
      ),
    );
  }
}
