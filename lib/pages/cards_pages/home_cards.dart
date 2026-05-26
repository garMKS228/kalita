import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/database/database.dart';
import 'package:flutter_application_1/main.dart'; // Отсюда берется глобальный объект database
import 'package:flutter_application_1/widget/ios_widget.dart';

class HomeCardsPage extends StatefulWidget {
  const HomeCardsPage({super.key, required this.title});
  final String title;

  @override
  State<HomeCardsPage> createState() => _HomeCardsPageState();
}

class _HomeCardsPageState extends State<HomeCardsPage> {
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Конвертер цвета из строки HEX (БД) в объект Color (Flutter)
  Color _getCardColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blueAccent;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blueAccent;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Устанавливаем системный стиль для статус-бара
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Светлый фон из homecards
      body: Stack(
        children: [
          // 1. ДИНАМИЧЕСКИЙ СПИСОК КАРТ ИЗ БАЗЫ ДАННЫХ
          StreamBuilder<List<CardEntry>>(
            // Используем метод вашей БД для отслеживания карт в реальном времени
            stream: database.cardsDao.watchAllCards(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final cards = snapshot.data ?? [];

              // Фильтруем карты по поисковому запросу, если поиск активен
              final filteredCards = cards.where((card) {
                return card.title.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredCards.isEmpty) {
                return Center( // Центрирует всю колонку на экране
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрирует элементы по вертикали внутри колонки
                    crossAxisAlignment: CrossAxisAlignment.center, // Центрирует элементы по горизонтали
                    children: [
                      Padding(
                        // Обрати внимание: у тебя тут стоял отступ справа 50.0. 
                        // Если картинка визуально смещена вбок, лучше сделать right: 0 или EdgeInsets.zero
                        padding: const EdgeInsets.only(right: 50.0), 
                        child: SvgPicture.asset(
                          'assets/images/card_illustration.svg',
                          width: 320,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Выгодно с картой',
                        textAlign: TextAlign.center, // Текст тоже выравниваем по центру
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'ActayWide'),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Создавайте и кастомизируйте карты',
                        textAlign: TextAlign.center, // Текст тоже выравниваем по центру
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontFamily: 'Actay',
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            context.push("/home_cards/create_cards");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF131313),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Добавить карту',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'ActayWide'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    // Отступ сверху 140, чтобы первая карта была видна под шапкой, и 150 снизу для панели
                    padding: const EdgeInsets.fromLTRB(16, 140, 16, 150),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final card = filteredCards[index];
                          // Проверяем, является ли карта последней в списке
                          final isLast = index == filteredCards.length - 1;

                          return _buildCardItem(card, isLast: isLast);
                        },
                        childCount: filteredCards.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. ФИКСИРОВАННАЯ ВЕРХНЯЯ ШАПКА (ВИЗУАЛ ИЗ homecards)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 130,
              // ИЗМЕНЕНО: top уменьшен до 10, чтобы поднять панель к статус-бару по аналогии с прошлым кодом
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
                          'мои карты', 
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

          // 3. НИЖНЯЯ ПЛАВАЮЩАЯ ПАНЕЛЬ С КНОПКОЙ ДОБАВЛЕНИЯ (ИЗ homecards)
          Positioned(
            left: 20, right: 20, bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Навигационный таб-бар (Карты / Кошелек)
                AnimatedNavigationSwitch(initialIsCards: true),

                // КРУГЛАЯ КНОПКА ПЛЮС ДЛЯ СОЗДАНИЯ КАРТЫ
                GestureDetector(
                  onTap: () {
                    context.push("/home_cards/create_cards"); // Переход на страницу создания карты
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
  
  // Интегрированный метод отображения карт (Визуал homecards + Данные из БД)
  Widget _buildCardItem(CardEntry card, {required bool isLast}) {
    final Color cardColor = _getCardColor(card.color);
    return Align(
      heightFactor: isLast ? 1.0 : 0.6, // Эффект красивого каскадного наслоения
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => context.push("/home_cards/cards", extra: card), // Переход в детали
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ActayWide',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      card.barcode_type,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для круглых кнопок в шапке
  Widget _buildCircleIcon(IconData icon) {
    return Container(
      height: 50, width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF131313), size: 24),
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
          hintText: "Поиск карты...",
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
}