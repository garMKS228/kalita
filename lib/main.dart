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
import 'package:firebase_messaging/firebase_messaging.dart';
import './services/push_notification_service.dart';


CustomTransitionPage buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  Offset begin = const Offset(1.0, 0.0), // По умолчанию экран выезжает справа налево
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin, // Используем переданное значение
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation),
          child: child,
        );
      },
    );
  }

late AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase успешно инициализирован!");
    await PushNotificationService().init();

    // Слушаем пуши, когда приложение ОТКРЫТО (в фокусе)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Получен пуш в открытом приложении: ${message.notification?.title}');
      // Здесь потом можно добавить показ SnackBar, чтобы юзер увидел уведомление прямо в приложении
    });
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
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, 
        state: state, 
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, 
        state: state, 
        child: const SettingsPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, 
        state: state, 
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/home_cards',
      // Для главных экранов (табов) иногда лучше использовать FadeTransition (растворение) или вообще отключить анимацию, 
      // но если хотите сдвиг везде — оставляем так.
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, 
        state: state, 
        child: const HomeCardsPage(title: 'Мои Карты'),
      ),
    ),
    GoRoute(
      path: '/home_wallets',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, 
        state: state, 
        child: const HomeWalletsPage(title: 'Мои Кошельки'),
        begin: Offset(-1.0, 0.0)
      ),
    ),
    GoRoute(
      path: '/home_cards/create_cards',
      pageBuilder: (context, state) {
        final walletId = state.extra as String?;
        return buildPageWithSlideTransition(
          context: context, 
          state: state, 
          child: CreateCardsPage(title: 'Создание карты', initialWalletId: walletId),
        );
      }, 
    ),
    GoRoute(
      path: '/home_wallets/create_wallets',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, 
        state: state, 
        child: const CreateWalletsPage(title: 'Создание кошелька'),
      ),
    ),
    GoRoute(
      path: '/home_wallets/wallets',
      pageBuilder: (context, state) {
        final wallet = state.extra as Wallet; 
        return buildPageWithSlideTransition(
          context: context, 
          state: state, 
          child: WalletDetailsPage(wallet: wallet),
        );
      },
    ),  
    GoRoute(
      path: '/home_cards/cards',
      pageBuilder: (context, state) {
        final card = state.extra as CardEntry;
        return buildPageWithSlideTransition(
          context: context, 
          state: state, 
          child: CardDetailsPage(cardItem: card),
        );
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