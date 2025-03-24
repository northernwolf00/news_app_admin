import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app_oguz/Admin/login_firebase.dart';
import 'package:news_app_oguz/User/home_screen_user.dart';

import 'package:news_app_oguz/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        // home: HomeScreenUser(),
        home:  LoginScreen(),
        
        );
        
        // ref.watch(connectivityNotifierProvider).connected
        //     ? AuthWidget(
        //         adminPanelBuilder: (context) => const AdminHome(),
        //         nonSignedInBuilder: (context) => const SignInPage(),
        //         signedInBuilder: (context) => const UserHome(),
        //       )
        //     : const NoInternetPage());
  }
}
