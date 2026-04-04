import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/database/database.dart';

class CreateWalletsPage extends StatefulWidget {
  final String title;
  const CreateWalletsPage({super.key, required this.title});

  @override
  State<CreateWalletsPage> createState() => _CreateWalletsPageState();
}

class _CreateWalletsPageState extends State<CreateWalletsPage> {
  final _nameController = TextEditingController();
  
  // Палитра цветов точь-в-точь как на твоем макете
  final List<Color> _colors = [
    const Color(0xFFF44336), // Красный
    const Color(0xFFE91E63), // Розовый
    const Color(0xFF9C27B0), // Фиолетовый
    const Color(0xFF673AB7), // Темно-фиолетовый
    const Color(0xFF3F51B5), // Индиго
    const Color(0xFF2196F3), // Синий 
    const Color(0xFF009688), // Изумрудный
    const Color(0xFF4CAF50), // Зеленый
    const Color(0xFFFF9800), // Оранжевый
    const Color(0xFF795548), // Коричневый
    const Color(0xFF000000), // Черный
  ];
  
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    // По умолчанию выбираем синий цвет
    _selectedColor = _colors[5]; 
  }

  Future<void> _saveToDatabase() async {
    if (_nameController.text.isEmpty) return;

    // Надежно превращаем цвет в 6-значный HEX формат (например: #2196f3)
    String colorHex = '#${_selectedColor.value.toRadixString(16).substring(2, 8)}';

    await database.walletsDao.insertWallet(
      WalletsCompanion(
        name: drift.Value(_nameController.text),
        color: drift.Value(colorHex), // Отправляем цвет в базу!
      ),
    );
    
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Название кошелька",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            const Text("Выберите цвет кошелька:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            
            // Горизонтальная прокрутка цветов
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color; // Меняем активный цвет
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected 
                            ? Border.all(color: Colors.black, width: 3) // Обводка если выбран
                            : null,
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white, size: 24) 
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 50),
            
            Center(
              child: ElevatedButton(
                onPressed: _saveToDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor, // Кнопка подстраивается под выбранный цвет
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Создать кошелек", 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}