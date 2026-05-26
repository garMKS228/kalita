import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_sync_service.dart';
import 'package:flutter_application_1/services/push_notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполните все поля")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Полное сохранение оригинальной логики авторизации
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      
      if (user != null) {
        // Инициализация синхронизации базы данных
        final syncService = FirebaseSyncService(database);
        await syncService.pullDatabaseFromCloud(user.uid);

        // Регистрация токена пуш-уведомлений после успешного входа
        final pushService = PushNotificationService();
        await pushService.init(); 
        await pushService.checkAndShowWelcomeNotification();
        await Future.delayed(const Duration(milliseconds: 400));

        if (mounted) {
          context.go('/home_cards'); // Или твой оригинальный роут главного экрана
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка авторизации: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Фон из верстки
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25), // Отступы из верстки
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Вход',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ActayWide',
                ),
              ),
              const SizedBox(height: 40),
              _buildInputField('Email', _emailController),
              const SizedBox(height: 15),
              _buildInputField('Пароль', _passwordController, isPassword: true),
              const SizedBox(height: 40),
              _buildPrimaryButton('Войти'),
              const SizedBox(height: 24),
              _buildSecondaryButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Стилизованное поле ввода из файла login(verst) соединенное с оригинальным контроллером
  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          fontFamily: 'Actay',
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          hintStyle: const TextStyle(
            color: Colors.black26,
            fontFamily: 'Actay',
          ),
        ),
      ),
    );
  }

  // Главная кнопка из верстки с сохранением логики загрузки и обработки нажатия
  Widget _buildPrimaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF131313),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: _isLoading ? null : _login,
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : Text(text, style: const TextStyle(fontSize: 16, fontFamily: 'ActayWide')),
      ),
    );
  }

  // Нижняя ссылка перехода на регистрацию, оформленная по стилю макета верстки
  Widget _buildSecondaryButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.push('/register'),
        child: Text.rich(
          TextSpan(
            text: 'Нет аккаунта? ',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontFamily: 'Actay',
            ),
            children: [
              TextSpan(
                text: 'Создать',
                style: const TextStyle(
                  color: Color(0xFF6F48FF),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ActayWide',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}