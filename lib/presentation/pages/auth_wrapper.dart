// presentation/pages/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (!authProvider.isInitialized) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Task Genius',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Initializing...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate based on authentication state
        if (authProvider.isAuthenticated) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
