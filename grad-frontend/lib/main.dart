import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 

// Providers
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/homepage_screen.dart';
import 'screens/admin_panel.dart'; 
import 'screens/employee_tasks_screen.dart'; 

void main() async {
  // Wait for the Flutter engine to start before loading the language pack
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    // We built the app with a multilingual architecture
    EasyLocalization(
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('tr', 'TR'), 
      useOnlyLangCode: true, // Prevents the en-US.json error!
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const AkilliBelediyeApp(),
      ),
    ),
  );
}

class AkilliBelediyeApp extends StatefulWidget {
  const AkilliBelediyeApp({Key? key}) : super(key: key);

  @override
  State<AkilliBelediyeApp> createState() => _AkilliBelediyeAppState();
}

class _AkilliBelediyeAppState extends State<AkilliBelediyeApp> {
  // To preserve the LoginScreen instance
  LoginScreen? _loginScreen;

  @override
  void initState() {
    super.initState();

    // Check the token when the app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'Akıllı Belediye',
      debugShowCheckedModeBanner: false,

      // MaterialApp settings required for a multilingual setup
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // THEME SETTINGS
      themeMode: themeProvider.themeMode,

      // Bright Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4094FF)),
        brightness: Brightness.light,
      ),

      // Dark Theme
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F)),
        brightness: Brightness.dark,
      ),

      // FONT SIZE SETTING
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(themeProvider.textScaleFactor),
          ),
          child: child!,
        );
      },

      // BAŞLANGIÇ EKRANI MANTIĞI
      home: _buildHomeScreen(authProvider),
    );
  }

  Widget _buildHomeScreen(AuthProvider authProvider) {

    switch (authProvider.state) {
      case AuthState.initial:
      case AuthState.loading:

        // Loading Screen
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_city, size: 80, color: Color(0xFF4094FF)),
                SizedBox(height: 24),
                CircularProgressIndicator(color: Color(0xFF4094FF)),
                SizedBox(height: 16),
                Text(
                  'Yükleniyor...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );

      case AuthState.authenticated:
        _loginScreen = null; // If the login is successful, clear the login screen from memory

        // --- ROLE CHECK ADDED ---

        // 0: Admin
        // 2: Employee
        // Other: Citizen

        if (authProvider.userRoleId == 0) {
          return const AdminDashboardScreen();
        } else if (authProvider.userRoleId == 2) {
          return const EmployeeTasksScreen();
        } else {
          return const HomepageScreen();
        }

      // --------------------------------------------

      case AuthState.unauthenticated:
      case AuthState.error:

      // If an error occurs or no login is made, display the login screen
      _loginScreen ??= const LoginScreen();

      return _loginScreen!;
    }
  }
}