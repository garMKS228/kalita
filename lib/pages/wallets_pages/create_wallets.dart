import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/database/database.dart';
import '../../services/firebase_sync_service.dart';
import 'package:uuid/uuid.dart';

class CreateWalletsPage extends StatefulWidget {
  final String title;
  final Wallet? wallet; // Добавляем возможность передать существующий кошелек

  const CreateWalletsPage({super.key, required this.title, this.wallet});

  @override
  State<CreateWalletsPage> createState() => _CreateWalletsPageState();
}

class _CreateWalletsPageState extends State<CreateWalletsPage> {
  final _nameController = TextEditingController();
  
  // Твой путь к кастомной SVG-иконке стрелочки назад
  final String _backIconPath = 'assets/images/back.svg';
  
  final List<Color> _colors = [
    const Color(0xFFF44336),
    const Color(0xFFE91E63),
    const Color(0xFF9C27B0),
    const Color(0xFF673AB7),
    const Color(0xFF3F51B5),
    const Color(0xFF2196F3),
    const Color(0xFF009688),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
  ];

  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    // Если мы редактируем, заполняем данные старого кошелька
    if (widget.wallet != null) {
      _nameController.text = widget.wallet!.name;
      _selectedColor = Color(int.parse(widget.wallet!.color.replaceFirst('#', '0xff')));
    } else {
      _selectedColor = _colors[5]; // По умолчанию синий
    }
  }

  // Основная логика сохранения/обновления (названия и логика полностью сохранены)
  void _saveToDatabase() async {
    final name = _nameController.text.trim();
    final String walletId = widget.wallet?.id ?? const Uuid().v4();
    if (name.isEmpty) return;

    final companion = WalletsCompanion(
      id: drift.Value(walletId),
      name: drift.Value(name),
      color: drift.Value('0x${_selectedColor.value.toRadixString(16).toUpperCase()}'),
    );

    try {
      final syncService = FirebaseSyncService(database);
      
      if (widget.wallet == null) {
        // Создание нового
        await database.into(database.wallets).insert(companion);
        final newWallet = await (database.select(database.wallets)..where((t) => t.id.equals(walletId))).getSingle();
        await syncService.pushWallet(newWallet);
      } else {
        // Редактирование существующего
        await (database.update(database.wallets)..where((t) => t.id.equals(widget.wallet!.id)))
            .write(companion);
        
        final updatedWallet = await (database.select(database.wallets)..where((t) => t.id.equals(widget.wallet!.id))).getSingle();
        await syncService.pushWallet(updatedWallet);
      }
      
      if (mounted) context.pop();
    } catch (e) {
      print("Ошибкасохранениякошелька: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Твой светлый фон из дизайна
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Кастомная верхняя шапка со строго центрированным заголовком
              Padding(
                // ИЗМЕНЕНО: Отступ сверху уменьшен до 10, чтобы панель стала выше к статус-бару
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _circleIconButton(
                        _backIconPath,
                        iconSize: 13.0,
                        onTap: () {
                          context.pop();
                        },
                      ),
                    ),
                    Text(
                      widget.wallet == null ? 'создание кошелька' : 'редактирование',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ActayWide',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 2. Скругленная карточка ввода названия с подсказкой внутри
              Container(
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
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Actay',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Введите название',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // 3. Большая кастомная фиолетовая кнопка зафиксирована снизу экрана
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0), // Отступы слева, справа и снизу экрана
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF9276F6), // Твой фиолетовый цвет с макета
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9276F6).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: _saveToDatabase, // Твой оригинальный метод сохранения
                child: Center(
                  child: Text(
                    widget.wallet == null ? 'Создать' : 'Сохранить изменения',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ActayWide',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Круглая кнопка для кастомной SVG иконки возврата
  Widget _circleIconButton(String assetPath, {required double iconSize, VoidCallback? onTap}) {
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
          ),
        ),
      ),
    );
  }
}