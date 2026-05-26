import 'dart:io';
import 'package:pasteboard/pasteboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/database/database.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:drift/drift.dart' as drift;
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/firebase_sync_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

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

  final ScreenshotController screenshotController = ScreenshotController();

  // 12 гармоничных цветов ровно из твоей новой вёрстки
  final List<Color> _availableColors = [
    const Color(0xFF9276F6), // Фиолетовый (исходный)
    const Color(0xFFF0766E), // SPAR Красный
    const Color(0xFFD670F0), // Чижик Розовый
    const Color(0xFFFBAE7E), // Спортмастер Оранжевый
    const Color(0xFFE52D2D), // Магнит Красный
    const Color(0xFF4CAF50), // Зеленый
    const Color(0xFF2196F3), // Синий
    const Color(0xFF00BCD4), // Бирюзовый
    const Color(0xFFFFEB3B), // Желтый
    const Color(0xFFE91E63), // Яркий розовый
    const Color(0xFFFF9800), // Глубокий оранжевый
    const Color(0xFF495057), // Темно-серый
  ];

  @override
  void initState() {
    super.initState();
    isFavorite = widget.cardItem.is_favorite;
    _titleController = TextEditingController(text: widget.cardItem.title);
    _barcodeDataController = TextEditingController(text: widget.cardItem.barcode_data);
    _selectedColor = _getCardColor(widget.cardItem.color);
    _selectedType = widget.cardItem.barcode_type;
    _isQrFixed = _selectedType == 'QR Code';
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

  Barcode _getBarcodeType(String type) {
    switch (type) {
      case 'QR Code': return Barcode.qrCode();
      case 'EAN-13': return Barcode.ean13();
      case 'EAN-8': return Barcode.ean8();
      default: return Barcode.qrCode();
    }
  }

  void _handleTypeUpdate(String value) {
    if (_isQrFixed) {
      setState(() => _selectedType = 'QR Code');
      return;
    }
    setState(() {
      // Если только цифры и длина 8, то EAN-8, иначе EAN-13
      if (value.length == 8 && RegExp(r'^\d+$').hasMatch(value)) {
        _selectedType = 'EAN-8';
      } else {
        _selectedType = 'EAN-13';
      }
    });
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
            child: const Text("Отмена", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Удалить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await database.cardsDao.deleteCard(widget.cardItem.id);
      await FirebaseSyncService(database).deleteCard(widget.cardItem.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  void _saveChanges() async {
    final value = _barcodeDataController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные кода не могут быть пустыми')),
      );
      return;
    }

    // Если принудительный QR-код выключен, проверяем длину для EAN стандартов
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
          const SnackBar(content: Text('Штрихкод должен содержать ровно 8 или 13 символов')),
        );
        return;
      }
    }

    final updatedCard = widget.cardItem.copyWith(
      title: _titleController.text.trim(),
      barcode_data: value,
      barcode_type: _selectedType,
      color: drift.Value('#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}'),
    );

    await database.update(database.cards).replace(updatedCard);
    await FirebaseSyncService(database).updateCardInCloud(updatedCard);
    setState(() => isEditing = false);
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      _titleController.text = widget.cardItem.title;
      _barcodeDataController.text = widget.cardItem.barcode_data;
      _selectedColor = _getCardColor(widget.cardItem.color);
      _selectedType = widget.cardItem.barcode_type;
      _isQrFixed = _selectedType == 'QR Code';
    });
  }

  void _toggleFavorite() async {
    final newStatus = !isFavorite;
    final updatedCard = widget.cardItem.copyWith(is_favorite: newStatus);
    FirebaseSyncService(database).updateCardInCloud(updatedCard);
    setState(() => isFavorite = newStatus);
    await database.cardsDao.updateFavoriteStatus(widget.cardItem.id, newStatus);
  }

  Future<void> _shareCardBarcode() async {
    // 1. Делаем скриншот виджета
    final image = await screenshotController.capture();
    
    if (image != null) {
      // 2. Получаем временную директорию
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/barcode.png').create();
      await imagePath.writeAsBytes(image);

      // 3. Отправляем файл
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Штрих-код карты: ${widget.cardItem.title}',
      );
    }
  }

  void _showFullScreenBarcode() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'ActayWide'),
                    ),
                    const SizedBox(height: 20),
                    BarcodeWidget(
                      barcode: _getBarcodeType(_selectedType),
                      data: _barcodeDataController.text.isEmpty ? " " : _barcodeDataController.text,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.3,
                      drawText: true,
                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Actay'),
                    ),
                    const SizedBox(height: 20),
                    const Text("Нажмите, чтобы закрыть", style: TextStyle(color: Colors.grey, fontFamily: 'Actay')),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: _buildBottomPanel(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ШАПКА ИЗ VERSTKA
                _buildHeader(),
                
                const SizedBox(height: 15),
                
                // 2. СТИЛИЗОВАННАЯ КАРТА (Интегрирован бэкенд вывода кодов)
                _buildCreditCard(),
                
                const SizedBox(height: 30),
                
                // 3. ОВАЛЬНЫЕ КНОПКИ ДЕЙСТВИЙ В РЯД
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton(
                      'assets/images/heart_filled.svg', 
                      onTap: _toggleFavorite, 
                      iconColor: isFavorite ? const Color(0xFFFF3B30) : _selectedColor.withOpacity(0.4)
                    ),
                    const SizedBox(width: 12),
                    _actionButton('assets/images/share.svg', onTap: _shareCardBarcode, iconColor: _selectedColor),
                    const SizedBox(width: 12),
                    _actionButton(
                      'assets/images/edit.svg', 
                      onTap: () {
                        if (isEditing) {
                          _saveChanges();
                        } else {
                          setState(() => isEditing = true);
                        }
                      },
                      iconColor: isEditing ? Colors.green : _selectedColor
                    ),
                  ],
                ),
                
                const SizedBox(height: 35),
                
                // 4. ПОЛЯ ВВОДА / ИНФОРМАЦИИ
                _infoTile('Название', 'Введите название', _titleController, isEditing),
                
                // Лента выбора цвета
                _buildColorPicker(),
                
                const SizedBox(height: 20),
                
                // Кнопка QR-code (переключатель авторежима)
                _buildQrCodeButton(),
                
                const SizedBox(height: 14),
                
                _infoTile('QR код', 'Введите данные кода', _barcodeDataController, isEditing, isCode: true),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIconButton('assets/images/back.svg', iconSize: 13.0, onTap: () {
            if (isEditing) {
              _cancelEditing();
            } else {
              context.pop();
            }
          }),
          Text(
            _titleController.text.isEmpty ? 'карта' : _titleController.text.toLowerCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'ActayWide',
              color: Colors.black,
            ),
          ),
          _circleIconButton('assets/images/trash.svg', iconSize: 23.0, onTap: () {
            _deleteCard();
          }
          
      ),
        ]
      )
    );
  }

  Widget _buildCreditCard() {
    return Container(
      width: double.infinity,
      height: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _selectedColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleController.text.isEmpty ? 'Название' : _titleController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'ActayWide',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          Center(
            child: GestureDetector(
              onTap: _showFullScreenBarcode,
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _selectedType == 'QR Code'
                      ? QrImageView(
                          data: _barcodeDataController.text.isEmpty ? " " : _barcodeDataController.text,
                          version: QrVersions.auto,
                          size: 100.0,
                          gapless: false,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        )
                      : SizedBox(
                          width: 210,
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            child: BarcodeWidget(
                              barcode: _getBarcodeType(_selectedType),
                              data: _barcodeDataController.text.isEmpty ? " " : _barcodeDataController.text,
                              drawText: false,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final color = _availableColors[index];
          final isSelected = color.value == _selectedColor.value;
          
          return GestureDetector(
            onTap: isEditing 
                ? () => setState(() => _selectedColor = color) 
                : null,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrCodeButton() {
    return GestureDetector(
      onTap: isEditing
          ? () {
              setState(() {
                _isQrFixed = !_isQrFixed;
                _handleTypeUpdate(_barcodeDataController.text);
              });
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _isQrFixed ? const Color(0xFF131313) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isQrFixed ? 'QR-code (Принудительно)' : 'QR-code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Actay',
                color: _isQrFixed ? Colors.white : Colors.black,
              ),
            ),
            Icon(
              Icons.qr_code_scanner,
              color: _isQrFixed ? Colors.white : Colors.black45,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String assetPath, {required VoidCallback onTap, required Color iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            height: 24,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String hint, TextEditingController controller, bool enabled, {bool isCode = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: const TextStyle(fontSize: 11, color: Colors.black26, fontFamily: 'Actay')
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            readOnly: !enabled,
            onChanged: (value) {
              if (isCode) _handleTypeUpdate(value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500, 
              fontFamily: 'Actay',
              color: Colors.black
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(String assetPath, {double iconSize = 24.0, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
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
        child: Center(child: SvgPicture.asset(assetPath, height: iconSize)),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: SvgPicture.asset('assets/images/card_active.svg', height: 26),
                ),
                GestureDetector(
                  onTap: () => context.go('/home_wallets'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: SvgPicture.asset('assets/images/wallet.svg', height: 26),
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  
}