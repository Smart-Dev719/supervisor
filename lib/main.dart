import 'dart:async';

import 'package:driver_app/commons.dart';
import 'package:driver_app/forget_password.dart';
import 'package:driver_app/forget_password_reset.dart';
import 'package:driver_app/forget_password_verify.dart';
import 'package:driver_app/login.dart';
import 'package:driver_app/notification.dart';
import 'package:driver_app/password_change.dart';
import 'package:driver_app/profile.dart';
import 'package:driver_app/profile_edit.dart';
import 'package:driver_app/sub_main.dart';
import 'package:driver_app/trip_detail_pending.dart';
import 'package:driver_app/trip_track.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_trips.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();

  runApp(EasyLocalization(
      path: 'assets/locales',
      supportedLocales: const [Locale('en', 'UK'), Locale('ar', 'JO')],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      title: 'Supervisor App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Montserrat'),
      home: const MyHomePage(title: 'Supervisor App'),
      routes: {
        '/forget_password': (context) => const ForgetPassword(),
        '/forget_password_verify': (context) => const ForgetPasswordVerify(),
        '/verify_password': (context) => const ForgetPasswordReset(),
        '/main': (context) => const SubMain(),
        '/profile': (context) => const Profile(),
        '/profile_edit': (context) => const EditProfile(),
        '/password_change': (context) => const ChangePassword(),
        '/notification': (context) => const NotificationPage(),
        '/trip': (context) => const HomeTripsPage(),
        '/trip_track': (context) => const TripTrack(),
        '/trip_detail_pending': (context) => const TripDetailPending(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => SplashScreenState();
}

class SplashScreenState extends State<MyHomePage> {
  bool isLogin = false;
  String? login_id;
  String? name;

  Future<void> getLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(Commons.login_id);
    setState(() {
      isLogin = prefs.getBool('isLogin') ?? false;
      print(isLogin);
      if (isLogin) {
        Commons.login_id = prefs.getString("login_id")!;
        Commons.name = prefs.getString("name")!;
        MyLogin.setToken();
      } else {
        isLogin = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print(Commons.login_id);
    getLoginInfo().then((value) {
      if (isLogin) {
        Timer(const Duration(seconds: 2),
            () => Navigator.pushNamed(context, "/main"));
      } else {
        Timer(
            const Duration(seconds: 2),
            () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyLogin())));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/splash.png"), fit: BoxFit.cover)),
    );
  }
}
