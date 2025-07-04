import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:taskgenius/domain/repositories/project_repository.dart';
import 'package:taskgenius/domain/repositories/task_repository.dart';
import 'package:taskgenius/presentation/pages/auth_wrapper.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/project_repository_impl.dart';
import 'data/datasources/remote/ai_service.dart';
import 'data/datasources/local/database_helper.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart' as my_auth;
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/ai_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/ai_assistant_page.dart';
import 'core/utils/cache_manager.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();

  // Setup dependency injection
  await setupDependencies();

  runApp(MyApp());
}

Future<void> setupDependencies() async {
  // Core dependencies
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  getIt.registerLazySingleton<CacheManager>(() => CacheManager());

  // Services
  getIt.registerLazySingleton<AIService>(
    () => AIService(getIt<Dio>(), dotenv.env['OPENROUTER_API_KEY'] ?? ''),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<FirebaseAuth>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(getIt<DatabaseHelper>()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => my_auth.AuthProvider(getIt<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TaskProvider(getIt<TaskRepository>(), getIt<ProjectRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => AIProvider(getIt<AIService>(), getIt<CacheManager>()),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Task Genius',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(elevation: 0, centerTitle: true),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => HomePage(),
          '/ai-assistant': (context) => AIAssistantPage(),
          '/splash': (context) => SplashScreen(),
          '/auth': (context) => AuthWrapper(),
        },
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Center(child: Text(details.exceptionAsString()));
          };
          return child!;
        },
      ),
    );
  }
}
