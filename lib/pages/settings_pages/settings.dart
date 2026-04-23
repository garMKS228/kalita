import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  
  // Заглушка для кнопок, функционал которых пока не нужен
  void _dummyAction(String actionName) {
    debugPrint('Нажата кнопка: $actionName');
  }

  // Функционал выхода из аккаунта
  void _logout(BuildContext context) async {
  try {
    // 1. Сначала инициируем выход в Firebase
    await FirebaseAuth.instance.signOut();

    // 2. Ждем завершения текущего цикла отрисовки
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 3. Только теперь делаем переход
        if (context.mounted) {
          context.go('/login');
        }
      });
    }
    
    debugPrint('Успешный выход');
  } catch (e) {
    debugPrint('Ошибка при выходе: $e');
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Светлый фон
      appBar: AppBar(
        title: const Text(
          'настройки',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Заглушка для аватарки в правом верхнем углу
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _dummyAction('Профиль'),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Text('🐷', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
      
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // Иконка и название приложения
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.account_balance_wallet, size: 40, color: Colors.indigoAccent),
                ),
                const SizedBox(height: 8),
                const Text(
                  'калита',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Блок с кнопками-заглушками
          _buildMenuButton('Язык', () => _dummyAction('Язык')),
          _buildMenuButton('Поддержать нас', () => _dummyAction('Поддержать нас')),
          _buildMenuButton('Оценить', () => _dummyAction('Оценить')),
          _buildMenuButton('Поделиться', () => _dummyAction('Поделиться')),
          _buildMenuButton('Поддержка', () => _dummyAction('Поддержка')),
          _buildMenuButton('Связаться с нами', () => _dummyAction('Связаться с нами')),
          _buildMenuButton('Политика конфиденциальности', () => _dummyAction('Политика конфиденциальности')),
          
          // Версия (без клика)
          _buildMenuButton('v 0.0.4', null),

          const SizedBox(height: 8),

          // Кнопка Выхода (с функционалом)
          InkWell(
            onTap: () => _logout(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Выйти',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Подвал
          const Center(
            child: Text(
              'Спасибо, что пользуетесь нашим приложением.\nС уважением, kalita team',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Универсальный виджет для кнопок меню
  Widget _buildMenuButton(String title, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.indigo,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}