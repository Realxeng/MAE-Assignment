import 'package:flutter/material.dart';
import 'package:nab/pages/customer/cus_main.dart';
import 'package:nab/pages/vendor/vendor_listing.dart';
import 'package:nab/pages/vendor/vendor_summary.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nab/pages/common/user_login.dart';
import 'package:nab/pages/admin/admin_home_page.dart';

import 'package:nab/pages/common/landing_page.dart';
import 'firebase_options.dart';
import 'utils/auth_router.dart';
import 'utils/user_provider.dart';
import 'utils/listing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nab',
      home: AuthRouter(),
      routes: {
        '/landing': (context) => LandingPage(),
        '/login': (context) => LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/adminHome') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AdminHomePage(uid: args['uid']),
          );
        }
        if (settings.name == '/customerHome') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CustomerMainPage(uid: args['uid']),
          );
        }
        if (settings.name == '/vendorHome') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => VendorHomePage(uid: args['uid']),
          );
        }
        // Fallback route
        return MaterialPageRoute(builder: (context) => LandingPage());
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00AFFFFF)),
      ),
    );
  }
}
