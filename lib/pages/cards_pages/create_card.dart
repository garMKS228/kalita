import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/widgets/ios_widgets.dart';
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
 
  
  final List<Color> _availableColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.teal, Colors.green,
    Colors.orange, Colors.brown, Colors.black,
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
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTopButton(Icons.arrow_back, () => context.pop()),
                    const SizedBox(width: 20),
                    Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                
                _buildLabel("Название карты"),
                _buildTextField(_titleController, "Напр: Пятерочка"),
                
                
                const SizedBox(height: 20),
                _buildLabel("Данные штрих-кода (номер)"),
                _buildTextField(
                  _barcodeDataController, 
                  "Введите номер", 
                  errorText: _barcodeError,
                  onChanged: (value) => _autoDetectType(value), // Обязательно добавь это!
                ),
                
                const SizedBox(height: 30),
                // Показываем текущий статус, чтобы было понятно, что происходит под капотом
                _buildLabel("Тип кода: ${_isQrFixed ? 'QR Code' : 'Авто ($_selectedType)'}"),
                const SizedBox(height: 10),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isQrFixed = !_isQrFixed; // Переключаем фиксацию
                        // Сразу обновляем тип на основе текущего текста
                        _autoDetectType(_barcodeDataController.text); 
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isQrFixed ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _isQrFixed ? Colors.black : Colors.grey.shade300),
                      ),
                      child: Text(
                        "QR Code", // Текст на кнопке
                        style: TextStyle(
                          color: _isQrFixed ? Colors.white : Colors.black87,
                          fontWeight: _isQrFixed ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                _buildLabel("Цвет карты"),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableColors.length,
                    itemBuilder: (context, index) {
                      final color = _availableColors[index];
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: isSelected ? 3 : 0,
                            ),
                          ),
                          child: isSelected 
                            ? const Icon(Icons.check, color: Colors.white, size: 22) 
                            : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _saveToDatabase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Создать", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IOSNavigationSwitch(
                path: '/home_wallets',
                value: WalletsCardSwitch,
                onChanged: (bool val) {
                  setState(() {
                    WalletsCardSwitch = !val; 
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
    );
  }

  void _autoDetectType(String value) {
    // Если включена фиксация, всегда сохраняем как QR Code
    if (_isQrFixed) {
      setState(() {
        _selectedType = 'QR Code';
        _barcodeError = null; // Принудительно убираем ошибку
      });
      return;
    }

    // Если фиксация отключена, считаем цифры
    setState(() {
      if (value.length == 8 && RegExp(r'^\d+$').hasMatch(value)) {
        _selectedType = 'EAN-8';
      } else if (value.length > 8 && RegExp(r'^\d+$').hasMatch(value)) {
        _selectedType = 'EAN-13';
      } else {
        _selectedType = 'EAN-8'; 
      }
    });

    // Динамическая проверка: чтобы ошибка исчезала прямо во время ввода
    _validateBeforeSave();
  }

  Widget _buildChipUI(String text, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {String? errorText, void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged, // Добавлено отслеживание ввода
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
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