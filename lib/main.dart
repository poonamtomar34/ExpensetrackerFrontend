import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/RegisterUserScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/ExpenseListScreen.dart';
import 'screens/LogOut.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/register',
      routes: {
        '/register': (BuildContext context) => const RegisterScreen(),
        '/login': (BuildContext context) => const LoginScreen(),
        '/dashboard': (BuildContext context) => const ExpenseListScreen(),
        '/logout': (BuildContext context) => const LogoutScreen(),
      },
    );
  }
}
