import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providerlar
// (Paket isimlerin farklıysa kendi proje ismine göre düzelt, örn: import '../providers/...')
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

// Ekranlar
import 'screens/login_screen.dart';
import 'screens/homepage_screen.dart';
import 'screens/admin_panel.dart'; // EKLENDİ: Admin paneli
import 'screens/employee_tasks_screen.dart'; // EKLENDİ: Çalışan paneli

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
  // LoginScreen instance'ını korumak için
  LoginScreen? _loginScreen;

  @override
  void initState() {
    super.initState();
    // Uygulama açılınca token kontrolü yap
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

      // TEMA AYARLARI
      themeMode: themeProvider.themeMode,

      // Aydınlık Tema
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4094FF)),
        brightness: Brightness.light,
      ),

      // Karanlık Tema
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F)),
        brightness: Brightness.dark,
      ),

      // YAZI BOYUTU AYARI
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
    // --- GEÇİCİ TASARIM MODU: Sadece bu satırı ekle ---
    return const HomepageScreen(); 
    // ------------------------------------------------
  /*  switch (authProvider.state) {
      case AuthState.initial:
      case AuthState.loading:
        // Yükleniyor Ekranı
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
        _loginScreen = null; // Giriş başarılıysa login ekranını hafızadan sil

        // --- BURASI DEĞİŞTİ: ROL KONTROLÜ EKLENDİ ---
        // 0: Admin
        // 2: Çalışan (Employee)
        // Diğer: Vatandaş
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
        // Hata veya giriş yapılmamışsa Login ekranı
        _loginScreen ??= const LoginScreen();
        return _loginScreen!;
    }
  }*/
}
} 