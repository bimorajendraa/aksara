import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/hash.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;
  bool isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final rawPassword = _passwordController.text.trim();
    final passwordHashed = hashPassword(rawPassword);
    if (email.isEmpty || rawPassword.isEmpty) {
      _showMessage('Email dan password tidak boleh kosong!');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('akun')
          .select()
          .eq('email', email)
          .eq('password', passwordHashed)
          .maybeSingle();

      if (response != null) {
        _showMessage('Selamat datang, ${response['username']}!');

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage('Email atau password salah!');
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEE9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset("assets/images/aksara_logo.png", width: 150),
              ),
              const SizedBox(height: 40),
              const Text(
                "Hi, Welcome\nBack",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              _roundedInput(
                icon: Icons.email_outlined,
                hint: "Email",
                controller: _emailController,
              ),
              const SizedBox(height: 20),

              _roundedInput(
                icon: Icons.lock_outline,
                hint: "Password",
                controller: _passwordController,
                obscure: !showPassword,
                suffix: GestureDetector(
                  onTap: () => setState(() => showPassword = !showPassword),
                  child: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),

              _mainButton("Login", onPressed: _signIn),
              const SizedBox(height: 25),

              const Center(
                child: Text(
                  "or continue with",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 25),

              _googleButton(),
              const SizedBox(height: 25),

              const Center(
                child: Text.rich(
                  TextSpan(
                    text: "Don’t have an account? ",
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundedInput({
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextEditingController? controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black45),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  Widget _mainButton(String text, {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/icons/google.png", width: 22),
          const SizedBox(width: 10),
          const Text(
            "Google",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
