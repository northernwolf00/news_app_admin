import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:news_app_user/User/home_screen_user.dart';
import 'package:news_app_user/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oguz News',
      theme: ThemeData(
        useMaterial3: true,
        
      ),
     home:  NetworkChecker(child: HomeScreenUser()),
    );
  }
}

class NetworkChecker extends StatefulWidget {
  final Widget child;

  const NetworkChecker({super.key, required this.child});

  @override
  State<NetworkChecker> createState() => _NetworkCheckerState();
}

class _NetworkCheckerState extends State<NetworkChecker> {
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  void _checkInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  void _retryConnection() {
    _checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Lottie.asset('assets/anim/no_internet.json'),
              ),
              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(123, 208, 185, 1.0),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

