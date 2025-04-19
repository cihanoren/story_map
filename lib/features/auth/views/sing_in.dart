import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:story_map/features/auth/controller/auth_controller.dart';
import 'package:story_map/features/auth/controller/auth_google.dart';
import 'package:story_map/features/auth/views/sing_up.dart';
import 'package:story_map/features/home/views/home.dart';

class SignIn extends ConsumerStatefulWidget {
  final bool showVerificationMessage;

  const SignIn({super.key, this.showVerificationMessage = false});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _shouldShowVerification = false;

  @override
  void initState() {
    super.initState();
    _shouldShowVerification = widget.showVerificationMessage;
    if (_shouldShowVerification) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Email verification link sent. Please verify your email."),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _shouldShowVerification = false; // Bir kez gösterdikten sonra sıfırla
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Arka plan resmi
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sign_in.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Flu ve şeffaf container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Sign In",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Email Input
                        Card(
                          color: Colors.white.withOpacity(0.7),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "E-mail",
                                prefixIcon: Icon(Icons.email),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Password Input
                        Card(
                          color: Colors.white.withOpacity(0.7),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                border: InputBorder.none,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Sign In Button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .signInWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );

                                // ✅ SharedPreferences: Oturum bilgisini sakla
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool("is_logged_in", true);

                                // Ana sayfaya yönlendir
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Home()),
                                  (route) => false,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: ${e.toString()}"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            child: Text("Sign In"),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Google İle Giriş Butonu
                        SignInButton(
                          Buttons.google,
                          text: "Continue with Google",
                          onPressed: () async {
                            final googleAuthService = GoogleAuthService();
                            final userCredential =
                                await googleAuthService.signInWithGoogle();

                            if (userCredential != null) {
                              // ✅ Oturum bilgisini sakla
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool("is_logged_in", true);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Google Sign-In Failed"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                        ),

                        SizedBox(height: 5),

                        // 📌 Anonim Giriş Butonu
                        ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .signInAnonymously();

                            // ✅ Oturum bilgisini sakla
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool("is_logged_in", true);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Home()),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            "Misafir Olarak Giriş Yap",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(fontSize: 17),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.indigoAccent,
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
