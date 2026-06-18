import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/main.dart'; 
import 'package:flutter_application_1/database/database.dart';
import '../../services/firebase_sync_service.dart';
import 'dart:ui';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_application_1/widget/ios_widget.dart';

class HomeWalletsPage extends StatefulWidget {
  const HomeWalletsPage({super.key, required this.title});
  final String title;

  @override
  State<HomeWalletsPage> createState() => _HomeWalletsPageState();
}

class _HomeWalletsPageState extends State<HomeWalletsPage> {
  String? expandedWalletId; // ID развернутого кошелька
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Универсальный парсер цветов для карт и кошельков
  Color _parseColor(String? hex, Color defaultColor) {
    if (hex == null || hex.isEmpty) return defaultColor;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return defaultColor;
    }
  }

  // Диалог привязки существующей карты
  void _showBindCardDialog(String walletId) async {
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
              const Text("Привязать карту", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'ActayWide')),
              const SizedBox(height: 16),
              if (freeCards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Нет свободных карт для добавления", style: TextStyle(color: Colors.grey, fontFamily: 'Actay')),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: freeCards.length,
                    itemBuilder: (context, index) {
                      final card = freeCards[index];
                      return ListTile(
                        leading: Icon(Icons.credit_card, color: _parseColor(card.color, const Color(0xFF131313))),
                        title: Text(card.title, style: const TextStyle(fontFamily: 'Actay', fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.add_circle_outline, color: Colors.black),
                        onTap: () async {
                          // 1. Привязываем карту к кошельку в локальной БД
                          await database.cardsDao.bindCardToWallet(card.id, walletId);
                          
                          // 2. Вытягиваем свежую карту из БД (уже с новым wallet_id)
                          final updatedCard = await database.cardsDao.getCardById(card.id);
                          
                          // 3. Синхронизируем изменения с Firebase
                          await FirebaseSyncService(database).updateCardInCloud(updatedCard);

                          if (mounted) {
                            Navigator.pop(context);
                            setState(() {}); // Обновляем UI
                          }
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
    // Прозрачный статус-бар
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // 1. ОСНОВНОЙ СПИСОК КОШЕЛЬКОВ
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                // 130 сверху — идеальный отступ, чтобы верхний элемент списка 
                // изначально стоял ровно под градиентной плашкой шапки
                padding: const EdgeInsets.fromLTRB(16, 90, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    StreamBuilder<List<Wallet>>(
                      stream: database.walletsDao.watchAllWallets(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.black));
                        
                        // ФИЛЬТРАЦИЯ
                        final wallets = snapshot.data!.where((w) {
                          return w.name.toLowerCase().contains(_searchQuery.toLowerCase());
                        }).toList();

                        // СОРТИРОВКА (Избранное наверху)
                        wallets.sort((a, b) {
                          if (a.name.toLowerCase() == 'избранное') return -1;
                          if (b.name.toLowerCase() == 'избранное') return 1;
                          return 0;
                        });

                        if (wallets.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text("Ничего не найдено", style: TextStyle(fontFamily: 'Actay', color: Colors.grey)),
                            )
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: wallets.length,
                          itemBuilder: (context, index) {
                            final wallet = wallets[index];
                            final isExpanded = expandedWalletId == wallet.id;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: _buildWalletSection(wallet, isExpanded),
                            );
                          },
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // 2. ВЕРХНЯЯ ПАНЕЛЬ С ГРАДИЕНТНЫМ ЗАТУМАНИВАНИЕМ И ФИКСИРОВАННЫМИ ОТСТУПАМИ
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 130,
              // Фиксированный отступ: 50 сверху до иконок, 16 по бокам, 10 снизу
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFF8F9FA).withOpacity(0.9),
                    const Color(0xFFF8F9FA).withOpacity(0.0),
                  ],
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSearching
                  ? _buildSearchField()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleIconAsset('assets/images/settings.svg', onTap: () => context.push('/settings')),
                        const Text(
                          'мои кошельки', 
                          style: TextStyle(
                            fontSize: 23, 
                            fontWeight: FontWeight.bold, 
                            fontFamily: 'ActayWide',
                            color: Color(0xFF131313),
                          ),
                        ),
                        _circleIconAsset('assets/images/icon_search.svg', onTap: () => setState(() => _isSearching = true)),
                      ],
                    ),
              ),
            ),
          ),

        
        ],
      ),
    );
  }

  // --- БЛОК ОДНОГО КОШЕЛЬКА С ВЛОЖЕННЫМИ КАРТАМИ ---
  Widget _buildWalletSection(Wallet wallet, bool isExpanded) {
    final isFavoriteWallet = wallet.name.toLowerCase() == 'избранное';

    return StreamBuilder<List<CardEntry>>(
      stream: isFavoriteWallet 
          ? (database.select(database.cards)..where((t) => t.is_favorite.equals(true))).watch()
          : (database.select(database.cards)..where((t) => t.wallet_id.equals(wallet.id))).watch(),
      builder: (context, snapshot) {
        final cards = snapshot.data ?? [];
        
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletDetailsScreen(wallet: wallet),
                  ),
                );
              },
              onLongPress: () => context.push('/home_wallets/wallets', extra: wallet),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 343 / 240,
                    child: Stack(
                      children: [
                        // Задняя стенка кошелька
                        Positioned.fill(
                          child: SvgPicture.asset('assets/images/wallet_back.svg', fit: BoxFit.contain),
                        ),
                        
                        // Кусочек верхней карты внутри кармашка кошелька
                        if (cards.isNotEmpty)
                          Positioned(
                            top: 15, left: 14, right: 14,
                            child: _buildCardPreview(cards.first),
                          ),

                        // Передняя стенка кошелька
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: SvgPicture.asset('assets/images/wallet_front.svg', fit: BoxFit.fitWidth),
                        ),
                        
                        // ВЫПАДАЮЩИЕ КНОПКИ ПО НАЖАТИЮ НА ПЛЮСИК (Кроме Избранного)
                        if (!isFavoriteWallet)
                        Positioned(
                          bottom: 15, right: 18,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              popupMenuTheme: PopupMenuThemeData(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                            child: PopupMenuButton<String>(
                              offset: const Offset(-20, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              onSelected: (value) {
                                if (value == 'create') {
                                  context.push('/home_cards/create_cards', extra: wallet.id);
                                } else if (value == 'bind') {
                                  _showBindCardDialog(wallet.id);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'create',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, color: Color(0xFF131313), size: 20),
                                      SizedBox(width: 10),
                                      Text("Создать карту", style: TextStyle(fontFamily: 'Actay', fontWeight: FontWeight.bold, color: Color(0xFF131313))),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'bind',
                                  child: Row(
                                    children: [
                                      Icon(Icons.link, color: Color(0xFF131313), size: 20),
                                      SizedBox(width: 10),
                                      Text("Привязать карту", style: TextStyle(fontFamily: 'Actay', fontWeight: FontWeight.bold, color: Color(0xFF131313))),
                                    ],
                                  ),
                                ),
                              ],
                              child: SvgPicture.asset('assets/images/icon_plus_small.svg', width: 32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Название кошелька и счетчик
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        wallet.name.toLowerCase(), 
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'ActayWide')
                      ),
                      const SizedBox(width: 12),
                      _buildCounter(cards.length.toString()),
                    ],
                  ),
                ],
              ),
            ),
            
            // СПИСОК КАРТ СТРОГО В ВИЗУАЛЬНОМ СТИЛЕ HOME_WALLETS(VERST)
            if (isExpanded) ...[
              const SizedBox(height: 16),
              if (cards.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    isFavoriteWallet ? "У вас пока нет избранных карт" : "В этом кошельке пока нет карт", 
                    style: const TextStyle(color: Colors.grey, fontFamily: 'Actay', fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  itemBuilder: (context, cardIndex) {
                    final card = cards[cardIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => context.push("/home_cards/cards", extra: card),
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: _parseColor(card.color, Colors.blueAccent), 
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  card.title, 
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                    fontFamily: 'ActayWide'
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                card.is_favorite ? Icons.favorite : Icons.favorite_border, 
                                color: Colors.white, 
                                size: 22
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        );
      },
    );
  }
 // --- ВСПОМОГАТЕЛЬНЫЕ UI ЭЛЕМЕНТЫ ---

  Widget _buildCardPreview(CardEntry card) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _parseColor(card.color, Colors.blueAccent), 
        borderRadius: BorderRadius.circular(22)
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              card.title, 
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'ActayWide'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildCounter(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(16)),
      child: Text(count, style: const TextStyle(color: Color(0xFF9575CD), fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20)],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(fontFamily: 'Actay'),
        decoration: InputDecoration(
          hintText: "Поиск кошелька...",
          hintStyle: const TextStyle(fontFamily: 'Actay', color: Colors.grey),
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


  Widget _circleIconAsset(String asset, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            asset, 
            width: 24,
            errorBuilder: (c,e,s) => const Icon(Icons.circle, color: Colors.black12),
          )
        ),
      ),
    );
  }
}

class WalletDetailsScreen extends StatelessWidget {
  final Wallet wallet;
  const WalletDetailsScreen({super.key, required this.wallet});

  Color _parseColor(String? hex, Color defaultColor) {
    if (hex == null || hex.isEmpty) return defaultColor;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavoriteWallet = wallet.name.toLowerCase() == 'избранное';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя панель: Кнопка назад и Название кошелька
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50, width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                                  child: Center(
                        child: SvgPicture.asset(
                          'assets/images/back.svg', // Укажите ваш путь к SVG-файлу
                          width: 13, // Задайте нужную ширину иконки
                          height: 13, // Задайте нужную высоту иконки
                          // Если нужно перекрасить SVG в определенный цвет (например, ваш Color(0xFF131313)):
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF131313), 
                            BlendMode.srcIn,
                          ),
                          // Резервный вариант на случай ошибки загрузки (например, если опечатались в пути)
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.arrow_back_ios_new, 
                            size: 20, 
                            color: Color(0xFF131313),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    wallet.name.toLowerCase(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'ActayWide'),
                  ),
                ],
              ),
            ),

            // Список карт этого кошелька из БД
            Expanded(
              child: StreamBuilder<List<CardEntry>>(
                stream: isFavoriteWallet 
                    ? (database.select(database.cards)..where((t) => t.is_favorite.equals(true))).watch()
                    : (database.select(database.cards)..where((t) => t.wallet_id.equals(wallet.id))).watch(),
                builder: (context, snapshot) {
                  final cards = snapshot.data ?? [];

                  if (cards.isEmpty) {
                    return Center(
                      child: Text(
                        isFavoriteWallet ? "У вас пока нет избранных карт" : "В этом кошельке пока нет карт",
                        style: const TextStyle(color: Colors.grey, fontFamily: 'Actay', fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final cardColor = _parseColor(card.color, Colors.blueAccent);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () => context.push("/home_cards/cards", extra: card),
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: cardColor.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Расталкивает элементы по вертикали
                              children: [
                                // ВЕРХНЯЯ ЧАСТЬ: Название карты
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        card.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'ActayWide',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // НИЖНЯЯ ЧАСТЬ: Кнопка "Отвязать"
                                if (!isFavoriteWallet)
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          // Оборачиваем null в drift.Value, чтобы стереть привязку
                                          final unbindedCard = card.copyWith(
                                            wallet_id: const drift.Value(null), 
                                          );
                                          
                                          // 1. Отвязываем локально
                                          await database.update(database.cards).replace(unbindedCard);
                                          
                                          // 2. Отвязываем в Firebase (отправляем туда null)
                                          await FirebaseSyncService(database).updateCardInCloud(unbindedCard);
                                          
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Карта отвязана от кошелька')),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25), // Полупрозрачный белый фон кнопки
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Отвязать',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'ActayWide',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}