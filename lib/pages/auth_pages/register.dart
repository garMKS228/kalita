import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/push_notification_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Валидатор из оригинального файла
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // Оригинальная логика регистрации с отправкой email-верификации и пушами
  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполните все поля")),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Некорректный формат Email (кириллица запрещена)")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пароли не совпадают")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Создание пользователя в Firebase
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Отправление ссылки подтверждения на почту
        await user.sendEmailVerification();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ссылка для подтверждения отправлена на вашу почту!")),
          );
        }

        final pushService = PushNotificationService();

        await pushService.init(); 
        await pushService.checkAndShowWelcomeNotification();
        await Future.delayed(const Duration(milliseconds: 400));

        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка при регистрации: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Из верстки
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25), // Из верстки
          child: SingleChildScrollView( // Защита от перекрытия экранной клавиатурой
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Регистрация',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ActayWide',
                  ),
                ),
                const SizedBox(height: 40),
                // Выводим поля, необходимые для функционала, используя визуал из верстки
                _buildInputField('Email', _emailController),
                const SizedBox(height: 15),
                _buildInputField('Пароль', _passwordController, isPassword: true),
                const SizedBox(height: 15),
                _buildInputField('Повторить пароль', _confirmPasswordController, isPassword: true),
                const SizedBox(height: 40),
                _buildPrimaryButton('Создать аккаунт'),
                const SizedBox(height: 24),
                _buildSecondaryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Контейнер и стиль текстового поля полностью скопированы из register(verst)
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

  // Кнопка полностью соответствует дизайну register(verst)
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
        onPressed: _isLoading ? null : _register,
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : Text(text, style: const TextStyle(fontSize: 16, fontFamily: 'ActayWide')),
      ),
    );
  }

  // Кнопка перехода назад на экран логина по стилю макета
  Widget _buildSecondaryButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(), // Возврат на экран входа
        child: Text.rich(
          TextSpan(
            text: 'Уже есть аккаунт? ',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontFamily: 'Actay',
            ),
            children: [
              TextSpan(
                text: 'Войти',
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