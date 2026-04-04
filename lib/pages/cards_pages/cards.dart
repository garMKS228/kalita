import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/database/database.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/widgets/ios_widgets.dart';
import 'package:barcode_widget/barcode_widget.dart';
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

  final List<String> _barcodeTypes = ['QR Code', 'EAN-13', 'Code 128', 'UPC-A'];

  final List<Color> _availableColors = [
    const Color(0xFF9276F6),
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.deepOrange,
    Colors.teal,
    Colors.blueGrey,
    const Color(0xFF222222),
  ];

  @override
  void initState() {
    super.initState();
    isFavorite = widget.cardItem.is_favorite;
    // Инициализируем контроллеры начальными данными
    _titleController = TextEditingController(text: widget.cardItem.title);
    _barcodeDataController = TextEditingController(text: widget.cardItem.barcode_data);
    _selectedColor = _getCardColor(widget.cardItem.color);
    _selectedType = widget.cardItem.barcode_type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeDataController.dispose();
    super.dispose();
  }

  Color _getCardColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF9276F6);
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      return const Color(0xFF9276F6);
    }
  }

  // Метод для отмены редактирования (возвращаем старые данные в UI)
  void _cancelEditing() {
    setState(() {
      _titleController.text = widget.cardItem.title;
      _barcodeDataController.text = widget.cardItem.barcode_data;
      _selectedColor = _getCardColor(widget.cardItem.color);
      _selectedType = widget.cardItem.barcode_type;
      isEditing = false;
    });
  }

  void _saveChanges() async {
    final hexColor = '#${_selectedColor.value.toRadixString(16).substring(2)}';
    
    // Обновляем в БД
    await (database.update(database.cards)..where((t) => t.id.equals(widget.cardItem.id))).write(
      CardsCompanion(
        title: drift.Value(_titleController.text),
        barcode_data: drift.Value(_barcodeDataController.text),
        barcode_type: drift.Value(_selectedType),
        color: drift.Value(hexColor),
      ),
    );

    // Просто выключаем режим редактирования. 
    // Теперь UI будет использовать актуальные значения из контроллеров.
    setState(() {
      isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Изменения сохранены")),
    );
  }

  Barcode _getBarcodeType(String dbType) {
    switch (dbType) {
      case 'EAN-13': return Barcode.ean13();
      case 'Code 128': return Barcode.code128();
      case 'UPC-A': return Barcode.upcA();
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

                // Карточка (всегда берем данные из контроллеров и переменных состояния)
                Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          _titleController.text, // <--- ИСПОЛЬЗУЕМ КОНТРОЛЛЕР
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(minHeight: 100, minWidth: 200),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: BarcodeWidget(
                            barcode: _getBarcodeType(_selectedType), // <--- ИСПОЛЬЗУЕМ СОСТОЯНИЕ
                            data: _barcodeDataController.text.isEmpty ? " " : _barcodeDataController.text, // <--- ИСПОЛЬЗУЕМ КОНТРОЛЛЕР
                            width: 200,
                            height: 80,
                            drawText: true,
                            errorBuilder: (context, error) => const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close, color: Colors.red, size: 40),
                                SizedBox(height: 4),
                                Text(
                                  "неправильный формат кода",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                    _buildIconButton(Icons.reply, () {}, iconColor: mainIconColor),
                    _buildIconButton(
                      isEditing ? Icons.close : Icons.auto_fix_high, 
                      () => isEditing ? _cancelEditing() : setState(() => isEditing = true), 
                      iconColor: isEditing ? Colors.red : mainIconColor
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _buildEditableField("Название", _titleController, !isEditing),
                const SizedBox(height: 12),
                
                if (isEditing) ...[
                  _buildTypePicker(),
                  const SizedBox(height: 12),
                  _buildColorPicker(),
                  const SizedBox(height: 20),
                ] else 
                  _buildStaticColorField(_selectedColor),

                const SizedBox(height: 12),
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

  // --- Вспомогательные виджеты ---

  Widget _buildTypePicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Тип штрихкода", style: TextStyle(color: Colors.grey, fontSize: 12)),
          DropdownButton<String>(
            value: _selectedType,
            isExpanded: true,
            underline: const SizedBox(),
            items: _barcodeTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) setState(() => _selectedType = newValue);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text("Цвет карты", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = _selectedColor.value == color.value;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String title, TextEditingController controller, bool readOnly, {bool isCode = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          readOnly 
            ? Text(controller.text, style: TextStyle(fontSize: isCode ? 18 : 20, fontWeight: FontWeight.bold))
            : TextField(
                controller: controller,
                onChanged: (val) => setState(() {}),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
          Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color iconColor = Colors.black87}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}