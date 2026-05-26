import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/main.dart'; 
import 'package:flutter_application_1/database/database.dart';
import '../../services/firebase_sync_service.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

bool WalletsCardSwitch = true;

class CreateCardsPage extends StatefulWidget {
  final String title;
  final String? initialWalletId; // Может быть null

  const CreateCardsPage({super.key, required this.title, this.initialWalletId});

  @override
  State<CreateCardsPage> createState() => _CreateCardsPageState();
}

class _CreateCardsPageState extends State<CreateCardsPage> {
  final _titleController = TextEditingController();
  final _barcodeDataController = TextEditingController();

  String? _barcodeError;
  bool _isQrFixed = false; // Добавляем флаг фиксации QR
  String _selectedType = 'EAN-8'; // Стартовый тип для автоопределения
  
  // Кастомные пути к иконкам
  final String _backIconPath = 'assets/images/back.svg';
  
  final List<Color> _availableColors = [
    const Color(0xFFF44336), // Красный
    const Color(0xFFE91E63), // Розовый
    const Color(0xFF9C27B0), // Пурпурный
    const Color(0xFF673AB7), // Фиолетовый
    const Color(0xFF3F51B5), // Индиго
    const Color(0xFF2196F3), // Синий
    const Color(0xFF009688), // Бирюзовый
    const Color(0xFF4CAF50), // Зеленый
    const Color(0xFFFF9800), // Оранжевый
  ];
  Color _selectedColor = const Color(0xFF9276F6);

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeDataController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _saveToDatabase() async {
    final title = _titleController.text.trim();
    final barcodeData = _barcodeDataController.text.trim();
    final String newId = const Uuid().v4();

    if (title.isEmpty) {
      _showError("Заполните название карты");
      return;
    }

    // ВЫЗЫВАЕМ ВАЛИДАТОР ЗДЕСЬ!
    if (!_validateBeforeSave()) {
      return; // Если есть ошибка (например, не 13 цифр) — выходим
    }

    final companion = CardsCompanion(
      id: drift.Value(newId),
      title: drift.Value(title),
      barcode_data: drift.Value(barcodeData),
      barcode_type: drift.Value(_selectedType),
      color: drift.Value('0x${_selectedColor.value.toRadixString(16).toUpperCase()}'),
      wallet_id: drift.Value(widget.initialWalletId),
    );

    try {
      await database.into(database.cards).insert(companion);
      final newCard = await database.cardsDao.getCardById(newId);
      
      final syncService = FirebaseSyncService(database);
      await syncService.pushCard(newCard);

      if (mounted) context.pop();
    } catch (e) {
      _showError("Ошибка при сохранении: $e");
    }
  }
  
  bool _validateBeforeSave() {
    final value = _barcodeDataController.text.trim();
    String? error;

    if (value.isEmpty) {
      error = 'Поле не может быть пустым';
    } else if (!_isQrFixed) { 
      // ВАЛИДАЦИЯ РАБОТАЕТ ТОЛЬКО ЕСЛИ QR-КНОПКА ВЫКЛЮЧЕНА
      if (!RegExp(r'^\d+$').hasMatch(value)) {
        error = 'Разрешены только цифры';
      } else if (value.length != 8 && value.length != 13) {
        error = 'Должно быть 8 или 13 цифр';
      }
    }

    setState(() {
      _barcodeError = error;
    });

    return error == null; // Возвращает true, если ошибок нет
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Светлый фон по дизайну
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Шапка со строго центрированным заголовком в нижнем регистре
                  Padding(
                    // ИЗМЕНЕНО: top уменьшен с 42 до 10, чтобы поднять панель к статус-бару
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _circleIconButton(_backIconPath,
                          iconSize: 13.0,
                            onTap: () {
                              context.pop();
                            },
                          ),
                        ),
                        Text(
                          'создание карты',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ActayWide',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Карточка ввода названия карты
                  _buildCombinedField("Название", _titleController, "Введите название"),
                  
                  const SizedBox(height: 20),
                  
                  // Карточка ввода штрих-кода
                  _buildCombinedField(
                    "Данные штрих-кода (номер)", 
                    _barcodeDataController, 
                    "Введите номер",
                    errorText: _barcodeError,
                    onChanged: (value) => _autoDetectType(value),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Подзаголовок для типа кода
                  Text(
                    _isQrFixed ? "Тип кода: Фиксированный (QR)" : "Тип кода: Авто ($_selectedType)",
                    style: const TextStyle(
                      color: Color(0xFFA1A4D9), // Цвет изменен по запросу
                      fontSize: 12,
                      fontFamily: 'Actay',
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Кнопка QR Code
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isQrFixed = !_isQrFixed; // Переключаем фиксацию
                        _autoDetectType(_barcodeDataController.text); 
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isQrFixed ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: _isQrFixed ? Colors.black : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        "QR код",
                        style: TextStyle(
                          color: _isQrFixed ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontFamily: 'Actay',
                          fontWeight: _isQrFixed ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Выбор цвета
                  const Text(
                    'Цвет карты',
                    style: TextStyle(
                      color: Color(0xFFA1A4D9), // Цвет изменен по запросу
                      fontSize: 12,
                      fontFamily: 'Actay',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 46,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableColors.length,
                      itemBuilder: (context, index) {
                        final color = _availableColors[index];
                        final isSelected = _selectedColor.value == color.value;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: isSelected 
                              ? const Center(child: Icon(Icons.check, color: Colors.white, size: 20)) 
                              : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20), // Небольшой аккуратный отступ перед краем скролла
                ],
              ),
            ),
          ),
          
          // Левый нижний переключатель навигации поверх контента
          
        ],
      ),
      // Кастомная фиолетовая нижняя кнопка "Создать" теперь прижата к низу через bottomNavigationBar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0), // Отступы слева, справа и снизу
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF9276F6),
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
                onTap: _saveToDatabase,
                child: const Center(
                  child: Text(
                    'Создать',
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
          ),
        ),
      ),
    );
  }

  // Метод сборки полей с подписью цвета 0xFFA1A4D9 внутри белой карточки
  Widget _buildCombinedField(String label, TextEditingController controller, String hint, {String? errorText, void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFA1A4D9), // Цвет изменен на A1A4D9
                  fontSize: 12,
                  fontFamily: 'Actay',
                ),
              ),
              TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Actay',
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  // Виджет круглой кнопки для кастомной SVG иконки возврата
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

  void _autoDetectType(String value) {
    if (_isQrFixed) {
      setState(() {
        _selectedType = 'QR Code';
        _barcodeError = null;
      });
      return;
    }

    setState(() {
      if (value.length == 8 && RegExp(r'^\d+$').hasMatch(value)) {
        _selectedType = 'EAN-8';
      } else if (value.length > 8 && RegExp(r'^\d+$').hasMatch(value)) {
        _selectedType = 'EAN-13';
      } else {
        _selectedType = 'EAN-8'; 
      }
    });

    _validateBeforeSave();
  }
}