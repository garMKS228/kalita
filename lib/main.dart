import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/database/database.dart';
import './pages/cards_pages/home_cards.dart'; 
import './pages/wallets_pages/home_wallets.dart';
import './pages/cards_pages/create_card.dart';
import './pages/wallets_pages/create_wallets.dart';
import './pages/cards_pages/cards.dart';

late AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  routes: [
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