import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme.dart';
import 'repositories/api_property_repository.dart';
import 'repositories/property_repository.dart';
import 'viewmodels/property_viewmodel.dart';
import 'views/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration (loads .env file)
  try {
    await AppConfig.initialize();
    debugPrint('✅ App configuration loaded successfully');
    debugPrint('🌐 API URL: ${AppConfig.apiUrl}');
  } catch (e) {
    debugPrint("⚠️ Warning: Could not load app configuration: $e");
    debugPrint("Using default configuration values");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dependency Injection for Repository
        Provider<PropertyRepository>(
          create: (_) => ApiPropertyRepository(),
        ),
        // ViewModel which depends on Repository
        ChangeNotifierProvider<PropertyViewModel>(
          create: (context) => PropertyViewModel(
            context.read<PropertyRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
