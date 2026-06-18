import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_application_1/database/database.dart';
import 'package:flutter_application_1/widget/ios_widget.dart';
import 'package:flutter_application_1/pages/settings_pages/settings.dart';
import './pages/cards_pages/home_cards.dart'; 
import './pages/wallets_pages/home_wallets.dart';
import './pages/cards_pages/create_card.dart';
import './pages/wallets_pages/create_wallets.dart';
import './pages/cards_pages/cards.dart';
import './pages/wallets_pages/wallets.dart';
import './pages/auth_pages/login.dart';
import './pages/auth_pages/register.dart';
import './services/push_notification_service.dart';
import 'firebase_options.dart';

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

// Вспомогательная функция для создания анимации плавного скольжения страниц (Slide Transition)
CustomTransitionPage buildPageWithSlideTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  Offset begin = const Offset(1.0, 0.0), // По умолчанию выезд справа налево
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}

// 1. ВИДЖЕТ-ОБОЛОЧКА ДЛЯ ГЛАВНЫХ ЭКРАНОВ С ФУНКЦИОНАЛЬНОЙ ПАНЕЛЬЮ
class MainAppShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const MainAppShell({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context) {
    // Проверяем по текущему URL, на какой вкладке мы находимся
    final bool isCards = state.uri.toString().contains('cards');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Внутренний экран (меняется с анимацией слайда)
          child,

          // СТАТИЧНАЯ НИЖНЯЯ ПАНЕЛЬ (не участвует в анимации переключения экранов)
          Positioned(
            left: 20, right: 20, bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Оборачиваем свитч в GestureDetector, чтобы сделать его полностью рабочим
                GestureDetector(
                  onTap: () {
                    if (isCards) {
                      context.go('/home_wallets'); // Если были на картах — переходим в кошельки
                    } else {
                      context.go('/home_cards');   // Если были в кошельках — переходим на карты
                    }
                  },
                  child: AnimatedNavigationSwitch(initialIsCards: isCards),
                ),
                
                // КНОПКА ПЛЮСА (Выполняет разные функции в зависимости от активного экрана)
                GestureDetector(
                  onTap: () {
                    if (isCards) {
                      context.push("/home_cards/create_cards");
                    } else {
                      context.push("/home_wallets/create_wallets");
                    }
                  },
                  child: Container(
                    height: 64, width: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF131313),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/icon_plus.svg',
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 2. ОБНОВЛЕННЫЙ РОУТЕР
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
    // Авторизация и настройки (снаружи ShellRoute, чтобы там не было нижней панели)
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, state: state, child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, state: state, child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, state: state, child: const SettingsPage(),
      ),
    ),

    // ГЛАВНЫЕ ЭКРАНЫ ОБОРАЧИВАЕМ В SHELL ROUTE
    ShellRoute(
      builder: (context, state, child) => MainAppShell(state: state, child: child),
      routes: [
        GoRoute(
          path: '/home_cards',
          pageBuilder: (context, state) => buildPageWithSlideTransition(
            context: context, state: state, child: const HomeCardsPage(title: 'Мои Карты'),
          ),
        ),
        GoRoute(
          path: '/home_wallets',
          pageBuilder: (context, state) => buildPageWithSlideTransition(
            context: context, 
            state: state, 
            begin: const Offset(-1.0, 0.0), // Красивый выезд слева при переходе к кошелькам
            child: const HomeWalletsPage(title: 'Мои Кошельки'),
          ),
        ),
      ],
    ),

    // ВТОРОСТЕПЕННЫЕ ЭКРАНЫ ОСТАЮТСЯ СНАРУЖИ (панель автоматически скроется при переходе в детали/создание)
    GoRoute(
      path: '/home_cards/create_cards',
      pageBuilder: (context, state) {
        final walletId = state.extra as String?;
        return buildPageWithSlideTransition(
          context: context, state: state, child: CreateCardsPage(title: 'Создание карты', initialWalletId: walletId),
        );
      }, 
    ),
    GoRoute(
      path: '/home_wallets/create_wallets',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context, state: state, child: const CreateWalletsPage(title: 'Создание кошелька'),
      ),
    ),
    GoRoute(
      path: '/home_wallets/wallets',
      pageBuilder: (context, state) {
        final wallet = state.extra as Wallet; 
        return buildPageWithSlideTransition(
          context: context, state: state, child: WalletDetailsPage(wallet: wallet),
        );
      },
    ),  
    GoRoute(
      path: '/home_cards/cards',
      pageBuilder: (context, state) {
        final card = state.extra as CardEntry;
        return buildPageWithSlideTransition(
          context: context, state: state, child: CardDetailsPage(cardItem: card),
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