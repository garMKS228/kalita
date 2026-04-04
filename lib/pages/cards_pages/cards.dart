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
  
  // Состояния для режима редактирования
  bool isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _barcodeDataController;
  late Color _selectedColor;

  // Список доступных цветов для выбора
  final List<Color> _availableColors = [
    const Color(0xFF9276F6), // Стандартный фиолетовый
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.deepOrange,
    Colors.teal,
    Colors.blueGrey,
    const Color(0xFF222222), // Почти черный
  ];

  @override
  void initState() {
    super.initState();
    isFavorite = widget.cardItem.is_favorite;
    _titleController = TextEditingController(text: widget.cardItem.title);
    _barcodeDataController = TextEditingController(text: widget.cardItem.barcode_data);
    _selectedColor = _getCardColor(widget.cardItem.color);
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

  void _toggleFavorite() async {
    final newStatus = !isFavorite;
    setState(() => isFavorite = newStatus);
    await database.cardsDao.updateFavoriteStatus(widget.cardItem.id, newStatus);
  }

  // Сохранение изменений в базу данных
  void _saveChanges() async {
    final hexColor = '#${_selectedColor.value.toRadixString(16).substring(2)}';
    
    await (database.update(database.cards)..where((t) => t.id.equals(widget.cardItem.id))).write(
      CardsCompanion(
        title: drift.Value(_titleController.text),
        barcode_data: drift.Value(_barcodeDataController.text),
        color: drift.Value(hexColor),
      ),
    );

    setState(() => isEditing = false);
  }

  // Определение типа штрихкода для виджета
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
                // Шапка экрана
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

                // Визуальное представление карты
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
                      // Название карты сверху
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          isEditing ? _titleController.text : widget.cardItem.title,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 24, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      // Штрихкод в центре с обработкой ошибок
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(minHeight: 100, minWidth: 200),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: BarcodeWidget(
                            barcode: _getBarcodeType(widget.cardItem.barcode_type),
                            data: isEditing 
                                ? (_barcodeDataController.text.isEmpty ? " " : _barcodeDataController.text) 
                                : widget.cardItem.barcode_data,
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
                                  style: TextStyle(
                                    color: Colors.red, 
                                    fontSize: 11, 
                                    fontWeight: FontWeight.bold
                                  ),
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

                // Кнопки действий
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(
                      isFavorite ? Icons.favorite : Icons.favorite_border, 
                      _toggleFavorite, 
                      iconColor: mainIconColor
                    ),
                    _buildIconButton(Icons.reply, () {}, iconColor: mainIconColor),
                    _buildIconButton(
                      isEditing ? Icons.close : Icons.auto_fix_high, 
                      () => setState(() => isEditing = !isEditing), 
                      iconColor: isEditing ? Colors.red : mainIconColor
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Поля ввода/просмотра
                _buildEditableField("Название", _titleController, !isEditing),
                
                const SizedBox(height: 12),
                
                // Секция выбора цвета (видна только при редактировании)
                if (isEditing) ...[
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
                            child: isSelected 
                                ? const Icon(Icons.check, color: Colors.white, size: 24) 
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else 
                  _buildStaticColorField(_selectedColor),

                const SizedBox(height: 12),
                _buildEditableField("Данные кода", _barcodeDataController, !isEditing, isCode: true),
              ],
            ),
          ),
          
          // Нижний переключатель навигации (скрывается при редактировании)
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

  // Виджет поля, который меняется с текста на TextField
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
            ? Text(
                controller.text, 
                style: TextStyle(
                  fontSize: isCode ? 18 : 20, 
                  fontWeight: FontWeight.bold
                )
              )
            : TextField(
                controller: controller,
                autofocus: false,
                onChanged: (val) => setState(() {}), // Для живого обновления штрихкода
                decoration: const InputDecoration(
                  border: InputBorder.none, 
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  fontSize: isCode ? 18 : 20, 
                  fontWeight: FontWeight.bold
                ),
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
          Text(
            "#${color.value.toRadixString(16).substring(2).toUpperCase()}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
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
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}