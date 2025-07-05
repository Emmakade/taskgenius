import 'package:flutter/material.dart';

import 'core/utils/route_name.dart';
import 'presentation/pages/ai_assistant_page.dart';
import 'presentation/pages/auth_wrapper.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  RouteNames.login: (context) => LoginPage(),
  RouteNames.register: (context) => RegisterPage(),
  RouteNames.home: (context) => HomePage(),
  RouteNames.aiAssistant: (context) => AIAssistantPage(),
  RouteNames.splash: (context) => SplashScreen(),
  RouteNames.authWrapper: (context) => AuthWrapper(),
};
