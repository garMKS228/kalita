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
      // Замените на ваш метод показа ошибки
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполните все поля")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Аутентификация
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        debugPrint("Авторизация успешна. Ждем синхронизации потоков Windows...");
        
        final pushService = PushNotificationService();
        await pushService.init(); 
        await pushService.checkAndShowWelcomeNotification();
        await Future.delayed(const Duration(milliseconds: 400));

        // 2. Скачиваем данные
        await FirebaseSyncService(database).pullDatabaseFromCloud(user.uid);

        // 3. Переходим на главную ТОЛЬКО если всё скачалось и виджет еще жив
        if (mounted) {
          context.go('/home_wallets');
        }
      }
    } catch (e) {
      debugPrint("Ошибка входа: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9276F6);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text("С возвращением!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _buildTextField(controller: _emailController, hint: "Email", icon: Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(controller: _passwordController, hint: "Пароль", icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Войти", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text("Нет аккаунта? Создать", style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}