import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final supabase = Supabase.instance.client;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isSignUp = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _navigateToHomePage() {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  // LOGIN
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user != null) {
        // Vérifie si user existe dans users table
        final data =
            await supabase
                .from('users')
                .select()
                .eq('id', user.id)
                .maybeSingle();

        if (data == null) {
          // Ancien utilisateur → créer son enregistrement
          await supabase.from('users').insert({
            'id': user.id,
            'username': user.email?.split('@').first ?? 'Utilisateur',
            'email': user.email,
            'avatar_url':
                'https://static.vecteezy.com/system/resources/previews/000/288/638/non_2x/broker-vector-icon.jpg',
          });
        }

        if (!mounted) return;
        _navigateToHomePage();
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // SIGNUP
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'username': _usernameController.text.trim()},
      );

      final user = response.user;
      if (user != null) {
        await supabase.from('users').insert({
          'id': user.id,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'avatar_url':
              'https://static.vecteezy.com/system/resources/previews/000/288/638/non_2x/broker-vector-icon.jpg',
        });

        if (!mounted) return;
        _navigateToHomePage();
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 470,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 54,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          1,
                          25,
                          135,
                        ).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSignUp
                              ? 'Créer un compte'
                              : 'Bienvenue sur PeeMart',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),

                        if (_isSignUp)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextField(
                              controller: _usernameController,
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                hintText: 'Nom d\'utilisateur',
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white70,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
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

                        const SizedBox(height: 12),

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 10, 88),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : (_isSignUp ? _signUp : _login),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Color.fromARGB(255, 0, 3, 172),
                                    )
                                    : Text(
                                      _isSignUp
                                          ? 'Créer un compte'
                                          : 'Se connecter',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 0, 3, 172),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSignUp
                                  ? 'Vous avez un compte ?'
                                  : 'Pas encore de compte ?',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                  _errorMessage = '';
                                  _usernameController.clear();
                                  _emailController.clear();
                                  _passwordController.clear();
                                });
                              },
                              child: Text(
                                _isSignUp ? 'Se connecter' : 'Créer un compte',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 169, 191),
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
        ],
      ),
    );
  }
}
