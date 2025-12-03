import 'package:flutter/material.dart';
import 'package:aksara/auth/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showPassword = false;
  bool isLoading = false;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      _showMessage("Semua field wajib diisi!");
      return;
    }

    setState(() => isLoading = true);

    final auth = AuthService();

    final error = await auth.register(
      email: email,
      username: username,
      password: password,
    );

    if (error != null) {
      _showMessage(error);
    } else {
      _showMessage("Akun berhasil dibuat! Silakan login.");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    }

    setState(() => isLoading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                "Create Your\nAccount !",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 40),

              _roundedInput(
                icon: Icons.email_outlined,
                hint: "Enter your email",
                controller: _emailController,
              ),

              const SizedBox(height: 20),

              _roundedInput(
                icon: Icons.person_outline,
                hint: "Username",
                controller: _usernameController,
              ),

              const SizedBox(height: 20),

              _roundedInput(
                icon: Icons.lock_outline,
                hint: "Password",
                obscure: !showPassword,
                controller: _passwordController,
                suffix: GestureDetector(
                  onTap: () => setState(() => showPassword = !showPassword),
                  child: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _mainButton("Sign Up", onPressed: _signUp),

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
                    text: "Already have an account? ",
                    children: [
                      TextSpan(
                        text: "Login",
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
                hintText: hint,
                border: InputBorder.none,
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
              ? const CircularProgressIndicator(color: Colors.white)
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
}
