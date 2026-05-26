import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Добавили для копирования в буфер обмена
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/main.dart'; // Для доступа к глобальной переменной 'database'

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Заглушка для кнопок, функционал которых пока не реализован («Оценить»)
  void _dummyAction(String actionName) {
    debugPrint('Нажата кнопка: $actionName');
  }

  // РЕАЛЬНАЯ ЛОГИКА ВЫХОДА ИЗ АККАУНТА (из файла коллег)
  void _logout(BuildContext context) async {
    try {
      // 1. Очищаем локальную базу данных Drift
      await database.clearAllData();

      // 2. Выходим из Firebase Auth
      await FirebaseAuth.instance.signOut();

      // 3. Перенаправляем пользователя на экран логина через GoRouter
      if (context.mounted) {
        context.go('/login');
      }
      debugPrint('База очищена, выход выполнен успешно');
    } catch (e) {
      debugPrint('Ошибка при выходе из аккаунта: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Твой светлый фон
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Твой плавный скролл
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // Твои отступы
            child: Column(
              children: [
                // 1. ШАПКА С ТВОИМ ДИЗАЙНОМ
                _buildHeader(context),
                
                const SizedBox(height: 40),
                
                // 2. ТВОЙ ЛОГОТИП, ИМЯ КОМАНДЫ И ПОЧТА ТЕКУЩЕГО АККАУНТА
                _buildLogoSection(),
                
                const SizedBox(height: 50),
                
                // 3. КНОПКИ МЕНЮ
                _buildMenuButton('Оценить', onTap: () => _dummyAction('Оценить')),
                const SizedBox(height: 15),
                
                // Логика копирования почты в буфер обмена и показ SnackBar
                _buildMenuButton(
                  'Связаться с нами', 
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'ptlir162@gmail.com'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Почта скопирована', 
                          style: TextStyle(fontFamily: 'Actay', color: Colors.white)
                        ),
                        backgroundColor: const Color(0xFF131313),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                
                _buildMenuButton('v 1.1.0', isVersion: true), // Информационная кнопка версии
                
                const SizedBox(height: 60), // Сбалансированный отступ до кнопки выхода
                
                // 4. КНОПКИ ВЫХОДА (Твой стиль + Логика коллег)
                _buildLogoutButton(context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Твоя кастомная шапка
  Widget _buildHeader(BuildContext context) {
    return Padding(
      // ИЗМЕНЕНО: top уменьшен с 42 до 10, чтобы поднять панель к статус-бару
      padding: const EdgeInsets.only(left: 0, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // При нажатии на стрелку назад возвращаемся на предыдущий экран
          _circleIconButton(
            'assets/images/back.svg', 
            iconSize: 13.0, 
            onTap: () => context.pop(),
          ),
          const Text(
            'настройки',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              fontFamily: 'ActayWide',
              color: Colors.black,
            ),
          ),
          // Фантомная кнопка справа для сохранения идеальной симметрии в Row
          Opacity(
            opacity: 0,
            child: _circleIconButton('assets/images/back.svg', iconSize: 18.0),
          ),
        ],
      ),
    );
  }

  // Твой красивый блок логотипа (теперь с выводом текущей почты)
  Widget _buildLogoSection() {
    // Получаем текущую почту из Firebase. Если её нет (например, зашли как гость) — пишем заглушку
    final String userEmail = FirebaseAuth.instance.currentUser?.email ?? 'no-email@kalita.com';

    return Column(
      children: [
        Container(
  height: 120,
  width: 120,
  child: Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15), // Радиус скругления самой иконки
      child: SvgPicture.asset(
        'assets/images/logo_wallet.svg', 
        height: 100,
      ),
    ),
  ),
),
        const SizedBox(height: 20),
        const Text(
          'kalita team',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'ActayWide',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8), // Отступ до email
        Text(
          userEmail,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            fontFamily: 'Actay',
          ),
        ),
      ],
    );
  }

  // Твой кастомный виджет для пунктов меню
  Widget _buildMenuButton(String text, {bool isVersion = false, VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      height: 64,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: isVersion ? null : onTap, // На версию нажать нельзя
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isVersion ? Colors.grey.withOpacity(0.6) : const Color(0xFF9094FB), // Твои цвета
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'ActayWide',
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Твоя кнопка «Выйти» с интегрированной логикой
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _logout(context), // Вызов метода очистки данных и разлогина!
          child: const Center(
            child: Text(
              'Выйти',
              style: TextStyle(
                color: Color(0xFFFF5A5A), // Красный цвет для кнопки выхода
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'ActayWide',
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Твой виджет круглых кнопок
  Widget _circleIconButton(String assetPath, {double iconSize = 20.0, VoidCallback? onTap}) {
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
        child: Center(child: SvgPicture.asset(assetPath, height: iconSize)),
      ),
    );
  }
}