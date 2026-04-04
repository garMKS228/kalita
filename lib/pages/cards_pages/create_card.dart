import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/widgets/ios_widgets.dart';
import 'package:flutter_application_1/main.dart'; 
import 'package:flutter_application_1/database/database.dart';
import 'package:drift/drift.dart' as drift;

bool WalletsCardSwitch = true;

class CreateCardsPage extends StatefulWidget {
  final String title;
  final int? initialWalletId; // Может быть null

  const CreateCardsPage({super.key, required this.title, this.initialWalletId});

  @override
  State<CreateCardsPage> createState() => _CreateCardsPageState();
}

class _CreateCardsPageState extends State<CreateCardsPage> {
  final _titleController = TextEditingController();
  final _barcodeDataController = TextEditingController();
  
  final List<String> _barcodeTypes = ['QR Code', 'EAN-13', 'Code 128', 'UPC-A'];
  String _selectedType = 'QR Code';
  
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

  Future<void> _saveToDatabase() async {
    if (_titleController.text.isEmpty || _barcodeDataController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните название и данные кода')),
      );
      return;
    }

    String colorHex = '#${_selectedColor.value.toRadixString(16).substring(2)}';

    await database.cardsDao.insertCard(
      CardsCompanion(
        title: drift.Value(_titleController.text),
        barcode_data: drift.Value(_barcodeDataController.text),
        barcode_type: drift.Value(_selectedType),
        color: drift.Value(colorHex),
        wallet_id: drift.Value(widget.initialWalletId), // Если null, будет свободной
      ),
    );

    if (mounted) context.pop();
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
                _buildTextField(_barcodeDataController, "123456789..."),
                
                const SizedBox(height: 30),
                _buildLabel("Тип кода"),
                const SizedBox(height: 10),
                
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _barcodeTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedType == _barcodeTypes[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = _barcodeTypes[index]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              _barcodeTypes[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

  Widget _buildTextField(TextEditingController controller, String hint) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(18),
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
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