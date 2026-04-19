import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/database/database.dart';
import 'package:flutter_application_1/main.dart';
import 'package:drift/drift.dart' as drift;
// Исправлен путь к виджетам
import 'package:flutter_application_1/widgets/ios_widgets.dart';

class WalletDetailsPage extends StatefulWidget {
  final Wallet wallet;
  const WalletDetailsPage({super.key, required this.wallet});

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  bool isEditing = false;
  late TextEditingController _nameController;
  late Color _selectedColor;

  final List<Color> _availableColors = [
    const Color(0xFFF44336), const Color(0xFFE91E63), const Color(0xFF9C27B0),
    const Color(0xFF673AB7), const Color(0xFF3F51B5), const Color(0xFF2196F3),
    const Color(0xFF009688), const Color(0xFF4CAF50), const Color(0xFFFF9800),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    _selectedColor = Color(int.parse(widget.wallet.color.replaceFirst('#', '0xff')));
  }

  // МЕТОД СОХРАНЕНИЯ ИЗМЕНЕНИЙ
  void _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final colorHex = '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}';

    // ВАЖНО: используем copyWith, чтобы сохранился старый ID кошелька
    // Если id совпадает, Drift выполнит UPDATE вместо INSERT
    final updatedWallet = widget.wallet.copyWith(
      name: name,
      color: colorHex,
    );

    await database.walletsDao.updateWallet(updatedWallet);

    setState(() {
      isEditing = false;
    });
    
    // Возвращаемся назад или уведомляем пользователя
    if (mounted) {
      context.pop(); 
    }
  }

  void _deleteWallet() async {
    await database.walletsDao.deleteWallet(widget.wallet);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(isEditing ? "Редактирование" : widget.wallet.name),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteWallet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField("Название", _nameController, readOnly: !isEditing),
            const SizedBox(height: 20),
            if (isEditing) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Выберите цвет", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 12),
              _buildColorPicker(),
            ] else 
              _buildStaticColorField(_selectedColor),
            
            const SizedBox(height: 40),

            // Кнопка "Готово" или "Сохранить"
            if (isEditing)
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor, // Убрали const
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Сохранить", style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticColorField(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          const Text("Цвет", style: TextStyle(color: Colors.grey)),
          const Spacer(),
          Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableColors.map((color) {
        final isSelected = _selectedColor.value == color.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 45, height: 45,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }
}