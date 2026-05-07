import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/database/database.dart';
import './pages/cards_pages/home_cards.dart'; 
import './pages/wallets_pages/home_wallets.dart';
import './pages/cards_pages/create_card.dart';
import './pages/wallets_pages/create_wallets.dart';
import './pages/cards_pages/cards.dart';
import './pages/wallets_pages/wallets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './pages/auth_pages/login.dart';
import './pages/auth_pages/register.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/pages/settings_pages/settings.dart';

late AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase успешно инициализирован!");
  } catch (e) {
    print("Ошибка инициализации Firebase: $e");
  }

  database = AppDatabase();
  
  try {
    await database.select(database.wallets).get();
  } catch (e) {
    print("Ошибка базы: $e");
  }

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/home_cards', 
  
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Проверяем: залогинен ли и подтверждена ли почта
    final bool isAuthenticated = user != null && user.emailVerified;
    
    final bool isLoggingIn = state.matchedLocation == '/login';
    final bool isRegistering = state.matchedLocation == '/register';

    // 1. Если не авторизован и не на страницах входа/регистрации -> на логин
    if (!isAuthenticated && !isLoggingIn && !isRegistering) {
      return '/login';
    }
    
    // 2. Если авторизован, но пытается зайти на страницы входа -> домой
    if (isAuthenticated && (isLoggingIn || isRegistering)) {
      return '/home_cards';
    }
    
    return null; // В остальных случаях идем куда шли
  },
  
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(), // Убедись, что LoginPage импортирован
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home_cards',
      builder: (context, state) => const HomeCardsPage(title: 'Мои Карты'), 
    ),
    GoRoute(
      path: '/home_wallets',
      builder: (context, state) => const HomeWalletsPage(title: 'Мои Кошельки'),
    ),
    GoRoute(
      path: '/home_cards/create_cards',
      builder: (context, state) {
        // ИЗМЕНЕНИЕ ЗДЕСЬ: Безопасно получаем int? из extra
        final walletId = state.extra as int?;
        return CreateCardsPage(title: 'Создание карты', initialWalletId: walletId);
      }, 
    ),
    GoRoute(
      path: '/home_wallets/create_wallets',
      builder: (context, state) => const CreateWalletsPage(title: 'Создание кошелька'), 
    ),
    GoRoute(
      path: '/home_wallets/wallets',
      builder: (context, state) {
        // Извлекаем объект кошелька из параметров перехода
        final wallet = state.extra as Wallet; 
        return WalletDetailsPage(wallet: wallet);
      },
    ),  
    GoRoute(
      path: '/home_cards/cards',
      builder: (context, state) {
        final card = state.extra as CardEntry;
        return CardDetailsPage(cardItem: card);
      }, 
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}