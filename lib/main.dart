import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/ai_assistant/controllers/ai_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProxyProvider<AuthController, AIController>(
          create: (_) => AIController(),
          update: (_, auth, ai) => ai!..setUid(auth.user?.uid),
        ),
      ],
      child: const CampusPulseApp(),
    ),
  );
}
