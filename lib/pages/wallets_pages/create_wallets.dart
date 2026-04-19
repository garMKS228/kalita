import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/database/database.dart';
// Исправлен путь импорта в соответствии с вашей структурой
import 'package:flutter_application_1/widgets/ios_widgets.dart'; 
import 'package:provider/provider.dart';

class CreateWalletsPage extends StatefulWidget {
  final String title;
  final Wallet? wallet; // Добавляем возможность передать существующий кошелек

  const CreateWalletsPage({super.key, required this.title, this.wallet});

  @override
  State<CreateWalletsPage> createState() => _CreateWalletsPageState();
}

class _CreateWalletsPageState extends State<CreateWalletsPage> {
  final _nameController = TextEditingController();
  
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

  // Основная логика сохранения/обновления
  void _saveToDatabase() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final colorHex = '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}';

    if (widget.wallet == null) {
      // СОЗДАНИЕ НОВОГО
      final companion = WalletsCompanion(
        name: drift.Value(name),
        color: drift.Value(colorHex),
      );
      await database.walletsDao.insertWallet(companion);
    } else {
      // ОБНОВЛЕНИЕ СУЩЕСТВУЮЩЕГО (используем copyWith для сохранения id)
      final updatedWallet = widget.wallet!.copyWith(
        name: name,
        color: colorHex,
      );
      await database.walletsDao.updateWallet(updatedWallet);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Название кошелька",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Выберите цвет:"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: Colors.black, width: 3) 
                          : null,
                    ),
                    child: isSelected 
                        ? const Icon(Icons.check, color: Colors.white) 
                        : null,
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saveToDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor, // Убрали const, чтобы не было ошибки
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  widget.wallet == null ? "Создать кошелек" : "Сохранить изменения",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}