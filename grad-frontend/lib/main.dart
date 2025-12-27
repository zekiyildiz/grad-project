import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:akilli_belediye/providers/theme_provider.dart';
import 'package:akilli_belediye/providers/auth_provider.dart';
import 'package:akilli_belediye/providers/user_provider.dart';
import 'package:akilli_belediye/screens/login_screen.dart';
import 'package:akilli_belediye/screens/homepage_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const AkilliBelediyeApp(),
    ),
  );
}

class AkilliBelediyeApp extends StatefulWidget {
  const AkilliBelediyeApp({Key? key}) : super(key: key);

  @override
  State<AkilliBelediyeApp> createState() => _AkilliBelediyeAppState();
}

class _AkilliBelediyeAppState extends State<AkilliBelediyeApp> {
  // LoginScreen'in state'ini korumak için key
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  // LoginScreen instance'ını korumak için
  LoginScreen? _loginScreen;
  
  @override
  void initState() {
    super.initState();
    // Initialize auth state on app start
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
      
      // TEMA AYARLARI (Karanlık/Aydınlık Modu Burası Yönetir)
      themeMode: themeProvider.themeMode, 
      
      // Aydınlık Tema Tasarımı
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4094FF)),
        brightness: Brightness.light,
      ),
      
      // Karanlık Tema Tasarımı
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F)),
        brightness: Brightness.dark,
      ),

      // YAZI BOYUTU AYARI (Tüm uygulama için)
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(themeProvider.textScaleFactor),
          ),
          child: child!,
        );
      },

      // Initial screen based on auth state
      home: _buildHomeScreen(authProvider),
    );
  }

  Widget _buildHomeScreen(AuthProvider authProvider) {
    switch (authProvider.state) {
      case AuthState.initial:
      case AuthState.loading:
        // Show splash/loading screen while checking auth
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city,
                  size: 80,
                  color: Color(0xFF4094FF),
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  color: Color(0xFF4094FF),
                ),
                SizedBox(height: 16),
                Text(
                  'Yükleniyor...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      case AuthState.authenticated:
        _loginScreen = null; // Clear login screen when authenticated
        return const HomepageScreen();
      case AuthState.unauthenticated:
      case AuthState.error:
        // Error ve unauthenticated durumlarında aynı LoginScreen instance'ını kullan
        // Bu sayede _errorMessage state'i korunur
        _loginScreen ??= const LoginScreen();
        return _loginScreen!;
    }
  }
}