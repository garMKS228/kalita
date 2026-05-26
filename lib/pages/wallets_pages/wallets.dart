import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_application_1/database/database.dart';
import 'package:flutter_application_1/main.dart';
import '../../services/firebase_sync_service.dart';

class WalletDetailsPage extends StatefulWidget {
  final Wallet wallet;
  const WalletDetailsPage({super.key, required this.wallet});

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  // Твои пути к кастомным SVG-иконкам
  final String _backIconPath = 'assets/images/back.svg';
  final String _trashIconPath = 'assets/images/trash.svg';

  late TextEditingController _nameController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    // Инициализация данных кошелька из оригинального файла коллег
    _nameController = TextEditingController(text: widget.wallet.name);
    _selectedColor = Color(int.parse(widget.wallet.color.replaceFirst('#', '0xff')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // МЕТОД СОХРАНЕНИЯ: Полностью по логике оригинального файла wallets.dart и firebase_sync_service.dart
  void _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Форматирование HEX-строки цвета точно как у коллег
    final colorHex = '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}';

    // Используем оригинальный метод copyWith
    final updatedWallet = widget.wallet.copyWith(
      name: name,
      color: colorHex,
    );

    // Локальное обновление через DAO коллег
    await database.walletsDao.updateWallet(updatedWallet);
    
    // Вызов оригинального метода из предоставленного файла firebase_sync_service
    await FirebaseSyncService(database).updateWalletInCloud(updatedWallet);

    if (mounted) {
      context.pop(); // Возврат назад через go_router
    }
  }

  // МЕТОД УДАЛЕНИЯ: Интеграция оригинальной логики удаления в диалоговое окно
  void _deleteWallet() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          "Удалить кошелек?", 
          style: TextStyle(fontFamily: 'ActayWide', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Все карты внутри этого кошелька станут общими.", 
          style: TextStyle(fontFamily: 'Actay'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Отмена", style: TextStyle(color: Colors.grey, fontFamily: 'Actay')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Закрываем диалог

              // 1. Ищем ВСЕ карты, которые привязаны к этому кошельку
              final cardsToUnbind = await (database.select(database.cards)
                    ..where((tbl) => tbl.wallet_id.equals(widget.wallet.id))).get();
              
              // 2. Отвязываем их ЛОКАЛЬНО И В FIREBASE по очереди
              for (var c in cardsToUnbind) {
                // drift.Value(null) затирает привязку
                final unbinded = c.copyWith(wallet_id: const drift.Value(null));
                await database.update(database.cards).replace(unbinded);
                await FirebaseSyncService(database).updateCardInCloud(unbinded);
              }

              // 3. Локальное удаление самого кошелька
              await database.walletsDao.deleteWallet(widget.wallet.id);
              
              // 4. Удаление кошелька из Firebase (если метод называется по-другому, поправь название)
              await FirebaseSyncService(database).deleteWallet(widget.wallet.id);

              // 5. Выходим с экрана редактирования
              if (mounted) {
                context.pop(); 
              }
            },
            child: const Text("Удалить", style: TextStyle(color: Colors.red, fontFamily: 'Actay', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Твой светлый фон из wallets_redact.dart
      body: SafeArea(
        child: Stack(
          children: [
            // Основной контент с возможностью скролла
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // Нижний отступ равен 100, чтобы контент не перекрывался прижатой кнопкой
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Твоя шапка с кастомными SVG кругляшками
                  _buildHeader(context),
                  
                  const SizedBox(height: 30),
                  
                  // Твоё кастомное поле ввода названия
                  _buildNameInput(),
                ],
              ),
            ),
            
            // Фиксированная кнопка "Сохранить" в самом низу экрана
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildSaveButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Твой виджет шапки с интеграцией оригинальных методов навигации и удаления
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 42, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIconButton(
            _backIconPath,
            iconSize: 20.0, 
            onTap: () {
              context.pop(); // Безопасный возврат назад через go_router
            },
          ),
          const Text(
            'редактирование кошелька',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'ActayWide',
            ),
          ),
          // ПРОВЕРКА: Если Избранное — прячем корзину, но оставляем невидимый блок 48px для идеальной симметрии заголовка
          if (widget.wallet.name == 'Избранное')
            const SizedBox(width: 48)
          else
            _circleIconButton(
              _trashIconPath,
              iconSize: 22.0,
              iconColor: const Color(0xFF121212), // Оригинальный темный цвет
              onTap: _deleteWallet, // Вызов диалога удаления
            ),
        ],
      ),
    );
  }

  // Твой вспомогательный виджет круглой кнопки для SVG
  Widget _circleIconButton(String assetPath, {required double iconSize, Color? iconColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
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
            assetPath,
            height: iconSize,
            colorFilter: iconColor != null 
                ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                : null,
          ),
        ),
      ),
    );
  }

  // Твой дизайн поля ввода
  Widget _buildNameInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Название',
            style: TextStyle(
              color: Color(0xFFA1A4D9),
              fontSize: 12,
              fontFamily: 'Actay',
            ),
          ),
          TextField(
            controller: _nameController,
            // ПРОВЕРКА: Блокируем клавиатуру и редактирование, если это Избранное
            readOnly: widget.wallet.name == 'Избранное',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Actay',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // Твоя фиолетовая кнопка "Сохранить" с новым цветом #9276F6
  Widget _buildSaveButton() {
    const Color buttonColor = Color(0xFF9276F6);

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _saveChanges, // Вызов метода сохранения
          child: const Center(
            child: Text(
              'Сохранить',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'ActayWide',
              ),
            ),
          ),
        ),
      ),
    );
  }
}