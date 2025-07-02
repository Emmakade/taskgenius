import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:taskgenius/data/datasources/remote/ai_service.dart';
import 'package:taskgenius/domain/repositories/auth_repository.dart';
import 'package:taskgenius/presentation/pages/ai_assistant_page.dart';
import 'package:taskgenius/presentation/pages/home_page.dart';
import 'package:taskgenius/presentation/providers/ai_provider.dart';
import 'package:taskgenius/presentation/providers/task_provider.dart';

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(GetIt.instance<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            GetIt.instance<TaskRepository>(),
            GetIt.instance<ProjectRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AIProvider(
            GetIt.instance<AIService>(),
            GetIt.instance<CacheManager>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Task Genius',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: AuthWrapper(),
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => HomePage(),
          '/ai-assistant': (context) => AIAssistantPage(),
        },
      ),
    );
  }
}
