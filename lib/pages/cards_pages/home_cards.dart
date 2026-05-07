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
  
  Color _getCardColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blueAccent;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blueAccent;
    }
  }

  bool _isSearching = false;
String _searchQuery = "";
final TextEditingController _searchController = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF7F8FC),
    body: Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isSearching) // Скрываем заголовок при поиске
                const Text(
                  "Мои карты",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              const SizedBox(height: 20),
              
              StreamBuilder<List<CardEntry>>(
                stream: database.cardsDao.watchAllCards(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  // ФИЛЬТРАЦИЯ
                  final cards = snapshot.data!.where((c) {
                    return c.title.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (cards.isEmpty) return const Center(child: Text("Карт не найдено"));

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cards.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildCardItem(cards[index]),
                  );
                },
              ),
            ],
          ),
        ),

        // ВЕРХНИЕ КНОПКИ
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: _isSearching 
            ? _buildSearchField() // Тот же метод, что и в кошельках
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton(Icons.account_circle, () => context.push('/settings')),
                  _buildTopButton(Icons.search, () => setState(() => _isSearching = true)),
                ],
              ),
        ),

        

          // 2. КНОПКА ДОБАВЛЕНИЯ
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => context.push("/home_cards/create_cards"),
              child: const Icon(Icons.add),
            ),
          ),

          // 3. IOS NAVIGATION SWITCH
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: IOSNavigationSwitch(
                path: '/home_wallets',
                value: walletsCardSwitch,
                onChanged: (bool val) {
                  setState(() {
                    walletsCardSwitch = val;
                  });
                },
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSearchField() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
    ),
    child: TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Поиск карты...",
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = "";
              _searchController.clear();
            });
          },
        ),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    ),
  );
}
  // Виджет круглой кнопки сверху
  Widget _buildTopButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    card.barcode_type,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
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