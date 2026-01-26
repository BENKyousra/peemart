import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peemart/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // TODO: Navigator vers Home
        print('Utilisateur connecté : ${user.email}');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Erreur de connexion';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ===== Gradient background =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 0, 1, 59),
                  Color.fromARGB(255, 0, 2, 105),
                ],
              ),
            ),
          ),

          // ===== Scroll pour mobile =====
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: screenWidth * 0.9,
                      constraints: const BoxConstraints(maxWidth: 470),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 0, 3, 172).withOpacity(0.25),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ===== Logo =====
                          Image.asset(
                            'assets/images/logo.png',
                            width: 90,
                            height: 90,
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Bienvenue sur PeeMart',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ===== Email =====
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              hint: 'Email',
                              icon: Icons.email,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ===== Password =====
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              hint: 'Mot de passe',
                              icon: Icons.lock,
                              suffix: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible =
                                        !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ===== Forgot password =====
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: mot de passe oublié
                              },
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),

                          // ===== Error message =====
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color:
                                       Color.fromARGB(255, 255, 31, 87),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // ===== Login button =====
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255),
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 0, 3, 172),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ===== Create account =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Pas encore de compte ?',
                                style: TextStyle(
                                    color: Colors.white70),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: page inscription
                                },
                                child: const Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 0, 169, 191),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Input style commun =====
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
