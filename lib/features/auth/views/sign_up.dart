import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_map/features/auth/controller/auth_controller.dart';
import 'package:story_map/features/auth/views/sign_in.dart';
import 'package:story_map/l10n/app_localizations.dart';

class SignUp extends ConsumerWidget {
  SignUp({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    color: Colors.white.withOpacity(0.3),
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
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context)!.signUp, // "Kayıt Ol"
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
                                  return AppLocalizations.of(context)!.emailRequired; // "E-posta gerekli"
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.email, // "E-posta"
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
                                  return AppLocalizations.of(context)!.passwordRequired; // "Şifre gerekli"
                                } else if (value.length < 8) {
                                  return AppLocalizations.of(context)!.newPasswordCondition; // "Şifre en az 8 karakter olmalı"
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.password, // "Şifre"
                                prefixIcon: Icon(Icons.lock),
                                border: InputBorder.none,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Sign Up Button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .signUpWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(AppLocalizations.of(context)!.successRegister), // "Kayıt başarılı"
                                  backgroundColor: Colors.green,
                                ));

                                // Başarılı kayıt sonrası Sign In sayfasına yönlendir ve mesaj göster
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SignIn(showVerificationMessage: true),
                                  ),
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
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            child: Text(AppLocalizations.of(context)!.signUp), // "Kayıt Ol"
                          ),
                        ),

                        const SizedBox(height: 15),
                        

                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.alreadyHaveAccount, // "Zaten hesabınız var mı?",
                              style: TextStyle(fontSize: 17),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn(
                                            showVerificationMessage: true,
                                          )),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.signIn, //
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
