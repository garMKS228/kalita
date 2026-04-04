import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/ios_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/main.dart'; 
import 'package:flutter_application_1/database/database.dart';

class HomeWalletsPage extends StatefulWidget {
  const HomeWalletsPage({super.key, required this.title});
  final String title;

  @override
  State<HomeWalletsPage> createState() => _HomeWalletsPageState();
}

class _HomeWalletsPageState extends State<HomeWalletsPage> {
  bool walletsSwitch = false; 
  int? expandedWalletId; // Для отслеживания раскрытого кошелька

  Color _getWalletColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blueAccent;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blueAccent;
    }
  }

  // Диалог привязки существующей карты
  void _showBindCardDialog(int walletId) async {
    final freeCards = await database.cardsDao.getFreeCards();
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Привязать карту", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (freeCards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Нет свободных карт для добавления", style: TextStyle(color: Colors.grey)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: freeCards.length,
                    itemBuilder: (context, index) {
                      final card = freeCards[index];
                      return ListTile(
                        leading: Icon(Icons.credit_card, color: _getWalletColor(card.color)),
                        title: Text(card.title),
                        trailing: const Icon(Icons.add_circle_outline, color: Colors.black),
                        onTap: () async {
                          await database.cardsDao.bindCardToWallet(card.id, walletId);
                          Navigator.pop(context);
                          setState(() {}); // Обновляем UI кошельков
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 120),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopButton(Icons.arrow_back, () => context.go('/home_cards')),
                    const Text("Мои Кошельки", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    _buildTopButton(Icons.search, () {}),
                  ],
                ),
                const SizedBox(height: 25),
                
                StreamBuilder<List<Wallet>>(
                  stream: database.walletsDao.watchAllWallets(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final wallets = snapshot.data!;
                    if (wallets.isEmpty) return const Center(child: Text("Нет кошельков"));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        final wallet = wallets[index];
                        final isExpanded = expandedWalletId == wallet.id;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => expandedWalletId = isExpanded ? null : wallet.id),
                              child: _buildWalletCard(wallet, isExpanded),
                            ),
                            if (isExpanded) _buildWalletDetails(wallet.id),
                            const SizedBox(height: 16), // Отступ между кошельками
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => context.push("/home_wallets/create_wallets"),
              child: const Icon(Icons.add),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: IOSNavigationSwitch(
                path: '/home_cards',
                value: walletsSwitch,
                onChanged: (bool val) => setState(() => walletsSwitch = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(Wallet wallet, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getWalletColor(wallet.color),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _getWalletColor(wallet.color).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wallet.name.toLowerCase(),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          const Text("активен", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  // Детали внутри кошелька: Кнопки и список его карт
  Widget _buildWalletDetails(int walletId) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => context.push('/home_cards/create_cards', extra: walletId),
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text("Создать", style: TextStyle(color: Colors.black)),
              ),
              TextButton.icon(
                onPressed: () => _showBindCardDialog(walletId),
                icon: const Icon(Icons.link, color: Colors.black),
                label: const Text("Привязать", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          const Divider(),
          StreamBuilder<List<CardEntry>>(
            // Получаем карты именно для этого кошелька
            stream: (database.select(database.cards)..where((t) => t.wallet_id.equals(walletId))).watch(),
            builder: (context, snapshot) {
              final cards = snapshot.data ?? [];
              if (cards.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("В этом кошельке пока нет карт", style: TextStyle(color: Colors.grey)),
                );
              }
              return Column(
                children: cards.map((card) => ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(card.title),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.push("/home_cards/cards", extra: card),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}