import 'dart:io';
import 'package:pasteboard/pasteboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/database/database.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/widgets/ios_widgets.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:drift/drift.dart' as drift;

bool walletsCardSwitch = true;

class CardDetailsPage extends StatefulWidget {
  final CardEntry cardItem;
  const CardDetailsPage({super.key, required this.cardItem});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  late bool isFavorite;
  bool isEditing = false;
  
  late TextEditingController _titleController;
  late TextEditingController _barcodeDataController;
  late Color _selectedColor;
  late String _selectedType;
  bool _isQrFixed = false;

  // Исходный список цветов из вашего кода
  final List<Color> _availableColors = [
    const Color(0xFFF44336), const Color(0xFFE91E63), const Color(0xFF9C27B0),
    const Color(0xFF673AB7), const Color(0xFF3F51B5), const Color(0xFF2196F3),
    const Color(0xFF009688), const Color(0xFF4CAF50), const Color(0xFFFF9800),
  ];

  final List<String> _barcodeTypes = ['QR Code', 'EAN-13', 'EAN-8'];
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    isFavorite = widget.cardItem.is_favorite;
    _titleController = TextEditingController(text: widget.cardItem.title);
    _barcodeDataController = TextEditingController(text: widget.cardItem.barcode_data);
    _selectedColor = _getCardColor(widget.cardItem.color);
    _selectedType = widget.cardItem.barcode_type;
    _isQrFixed = _selectedType == 'QR Code'; // Если карта уже QR, включаем фиксацию
    isFavorite = widget.cardItem.is_favorite;
  }

  Color _getCardColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF9276F6);
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return const Color(0xFF9276F6);
    }
  }

  void _deleteCard() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Удалить карту?"),
        content: const Text("Вы уверены, что хотите удалить эту карту?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Удалить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await database.cardsDao.deleteCard(widget.cardItem);
      if (mounted) {
        context.pop(); // Возврат на список карт
      }
    }
  }
  
  void _saveChanges() async {
    final value = _barcodeDataController.text;

    // Логика валидации
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные кода не могут быть пустыми')),
      );
      return;
    }

    // Если фиксация QR выключена (авторежим), проверяем на 8 или 13 цифр
    if (!_isQrFixed) {
      bool isDigits = RegExp(r'^\d+$').hasMatch(value);
      if (!isDigits) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('В авторежиме разрешены только цифры')),
        );
        return;
      }
      if (value.length != 8 && value.length != 13) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите ровно 8 или 13 цифр (или включите QR)')),
        );
        return;
      }
    }

  // Если проверки пройдены, сохраняем
  final updatedCard = widget.cardItem.copyWith(
    title: _titleController.text,
    barcode_data: value,
    barcode_type: _selectedType,
    color: drift.Value('#${_selectedColor.value.toRadixString(16).substring(2)}'),
  );

  await database.update(database.cards).replace(updatedCard);
  setState(() => isEditing = false);
}
  

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      _titleController.text = widget.cardItem.title;
      _barcodeDataController.text = widget.cardItem.barcode_data;
      _selectedColor = _getCardColor(widget.cardItem.color);
      _selectedType = widget.cardItem.barcode_type;
    });
  }

  // Копирование штрихкода как КАРТИНКИ в буфер
  Future<void> _copyBarcodeToClipboard() async {
    final image = await screenshotController.capture();
    if (image != null) {
      await Pasteboard.writeImage(image);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Штрихкод скопирован в буфер обмена как изображение'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Barcode _getBarcodeType(String type) {
    switch (type) {
      case 'QR Code': return Barcode.qrCode();
      case 'EAN-13': return Barcode.ean13();
      case 'EAN-8': return Barcode.ean8();
      default: return Barcode.qrCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainIconColor = Color(0xFF9276F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(Icons.arrow_back, () => context.pop()),
                    Text(
                      isEditing ? "Редактирование" : "Детали карты",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    isEditing 
                      ? _buildIconButton(Icons.check, _saveChanges, iconColor: Colors.green)
                      : _buildIconButton(Icons.search, () {}),
                  ],
                ),

                const SizedBox(height: 30),

                // Динамическая карточка без фиксированной высоты
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _showFullScreenBarcode, // Нажатие открывает во весь экран
                              child: Screenshot(
                                controller: screenshotController,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: BarcodeWidget(
                                    barcode: _getBarcodeType(_selectedType),
                                    data: _barcodeDataController.text.isEmpty ? " " : _barcodeDataController.text,
                                    width: 250,
                                    height: 90,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Три кнопки в ряд: Избранное, Копировать, Редактировать
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(
                      isFavorite ? Icons.favorite : Icons.favorite_border, 
                      () async {
                        final newStatus = !isFavorite;
                        setState(() => isFavorite = newStatus);
                        await database.cardsDao.updateFavoriteStatus(widget.cardItem.id, newStatus);
                      }, 
                      iconColor: mainIconColor
                    ),
                    _buildIconButton(Icons.copy, _copyBarcodeToClipboard, iconColor: mainIconColor),
                    _buildIconButton(
                      isEditing ? Icons.close : Icons.auto_fix_high, 
                      () => isEditing ? _cancelEditing() : setState(() => isEditing = true), 
                      iconColor: isEditing ? Colors.red : mainIconColor
                    ),
                    _buildIconButton(
                      Icons.delete_outline, 
                      _deleteCard, 
                      iconColor: Colors.red
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _buildEditableField("Название", _titleController, !isEditing),
                const SizedBox(height: 12),

                if (isEditing) ...[
                  // Кнопка фиксации QR 
                  Text(
                    "Тип кода: ${_isQrFixed ? 'QR Code' : 'Автоматически ($_selectedType)'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isQrFixed = !_isQrFixed;
                        _handleTypeUpdate(_barcodeDataController.text);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isQrFixed ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _isQrFixed ? Colors.black : Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code, color: _isQrFixed ? Colors.white : Colors.black, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "QR Code",
                            style: TextStyle(
                              color: _isQrFixed ? Colors.white : Colors.black,
                              fontWeight: _isQrFixed ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildColorPicker(), // Оставляем выбор цвета в режиме редактирования
                  const SizedBox(height: 12),
                ] else ...[
                  _buildStaticColorField(_selectedColor), // Показываем цвет в обычном режиме
                  const SizedBox(height: 12),
                ],
                _buildEditableField("Данные кода", _barcodeDataController, !isEditing, isCode: true),
              ],
            ),
          ),
          if (!isEditing)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: IOSNavigationSwitch(
                  path: '/home_wallets',
                  value: walletsCardSwitch,
                  onChanged: (bool val) => setState(() => walletsCardSwitch = val),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullScreenBarcode() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black.withOpacity(0.9), // Глубокий темный фон
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // Закрыть при тапе в любое место
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _titleController.text,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    BarcodeWidget(
                      barcode: _getBarcodeType(_selectedType),
                      data: _barcodeDataController.text.isEmpty ? " " : _barcodeDataController.text,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.3,
                      drawText: true,
                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text("Нажмите, чтобы закрыть", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTypeUpdate(String value) {
    if (_isQrFixed) {
      setState(() => _selectedType = 'QR Code');
      return;
    }

    setState(() {
      // Авто-определение: 8 цифр -> EAN-8, иначе EAN-13
      if (value.length == 8 && RegExp(r'^\d+$').hasMatch(value)) {
        _selectedType = 'EAN-8';
      } else {
        _selectedType = 'EAN-13';
      }
    });
  }

  Widget _buildTypePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          items: _barcodeTypes.map((String type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedType = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final color = _availableColors[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 45,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: _selectedColor == color ? Border.all(color: Colors.black, width: 2.5) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool readOnly, {bool isCode = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: readOnly,
            // ИЗМЕНЕНИЯ ЗДЕСЬ:
            onChanged: (value) {
              if (isCode) _handleTypeUpdate(value); // Запускаем проверку длины (8 или 13 цифр)
              setState(() {}); // Перерисовываем экран
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(fontSize: isCode ? 18 : 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticColorField(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          const Text("Цвет", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color iconColor = Colors.black87}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}