import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'repositories/api_property_repository.dart';
import 'repositories/property_repository.dart';
import 'viewmodels/property_viewmodel.dart';
import 'views/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables (create .env file if missing, handled gracefully if empty or missing in dev for now, but better to have it)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found or could not be loaded. Using defaults.");
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
        title: 'Real Estate Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
