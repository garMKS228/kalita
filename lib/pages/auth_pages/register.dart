import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Заполните все поля");
      return;
    }

    if (password != confirmPassword) {
      _showError("Пароли не совпадают");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Регистрируем пользователя в Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Если все прошло успешно, Firebase сам авторизует пользователя.
      // GoRouter (если мы настроим redirect) сам перекинет нас на главную,
      // но для надежности можем сделать явный переход:
      if (mounted) {
        context.go('/home_cards');
      }
    } on FirebaseAuthException catch (e) {
      String message = "Произошла ошибка";
      if (e.code == 'weak-password') {
        message = "Слишком слабый пароль. Минимум 6 символов.";
      } else if (e.code == 'email-already-in-use') {
        message = "Аккаунт с таким Email уже существует.";
      } else if (e.code == 'invalid-email') {
        message = "Неверный формат Email.";
      }
      _showError(message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Основной цвет акцента (взял из твоего create_card.dart)
    const primaryColor = Color(0xFF9276F6); 

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC), // Твой стандартный фон
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Кнопка назад
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 32),
              
              // Заголовок
              const Text(
                "Создать аккаунт",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Зарегистрируйтесь, чтобы ваши карты всегда были под рукой",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Поля ввода
              _buildTextField(
                controller: _emailController,
                hint: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                hint: "Пароль",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: "Повторите пароль",
                icon: Icons.lock_reset_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 40),

              // Кнопка регистрации
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Зарегистрироваться",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Переход к логину
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Уже есть аккаунт? ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Переход на страницу логина (сделаем ее позже)
                      context.push('/login'); 
                    },
                    child: const Text(
                      "Войти",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет поля ввода в твоем стиле (белая плашка со скруглениями)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}