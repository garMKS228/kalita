import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/ios_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/main.dart'; 
import 'package:flutter_application_1/database/database.dart';

// Глобальная переменная для управления состоянием свитча
bool walletsCardSwitch = true;

class HomeCardsPage extends StatefulWidget {
  const HomeCardsPage({super.key, required this.title});
  final String title;

  @override
  State<HomeCardsPage> createState() => _HomeCardsPageState();
}

class _HomeCardsPageState extends State<HomeCardsPage> {
  
  // Вспомогательная функция для конвертации HEX-строки из БД в объект Color
  Color _getCardColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blueAccent;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          // 1. ОСНОВНОЙ КОНТЕНТ
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                const Text(
                  "Мои карты",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Стрим с данными из таблицы Cards
                StreamBuilder<List<CardEntry>>(
                  stream: database.cardsDao.watchAllCards(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final cards = snapshot.data!;
                    
                    if (cards.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(child: Text("Список карт пуст")),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cards.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return _buildCardItem(card);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. КНОПКА ДОБАВЛЕНИЯ (Floating Action Button)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => context.push("/home_cards/create_cards"),
              child: const Icon(Icons.add),
            ),
          ),

          // 3. IOS SWITCH (Навигация)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: IOSNavigationSwitch(
                path: '/home_wallets',
                value: walletsCardSwitch,
                onChanged: (bool val) {
                  setState(() {
                    walletsCardSwitch = !val;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет отдельной карточки в списке
  Widget _buildCardItem(CardEntry card) {
    final Color cardColor = _getCardColor(card.color);
    
    return GestureDetector(
      onTap: () => context.push("/home_cards/cards", extra: card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Иконка категории или просто иконка карты
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card, color: Colors.white),
            ),
            const SizedBox(width: 16),
            // Текстовая информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    card.barcode_type,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}