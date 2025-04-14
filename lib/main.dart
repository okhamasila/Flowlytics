// import 'package:flutter/material.dart';
// import 'pages/login.dart'; // Impor halaman login
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const LoginPage(), // Ganti ke halaman login
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowlytics/providers/user_provider.dart';
import 'package:flowlytics/providers/student_provider.dart';
import 'package:flowlytics/pages/login.dart';
import 'package:flowlytics/asset/student_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: MaterialApp(
        title: 'Flowlytics',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        ),
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return userProvider.isLoggedIn
                ? const StudentListScreen()
                : const LoginPage();
          },
        ),
      ),
    );
  }
}
