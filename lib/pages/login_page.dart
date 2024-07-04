import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';
import 'package:p_trade/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;


  final auth = FirebaseAuth.instance;
  bool isLoading = false;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/icons/app_logo.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Login To Continue...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                icon: Icon(Icons.email_outlined),
                                label: Text('Email'),
                                hintText: "Enter Your Email Address"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock_outline),
                              label: Text('Password'),
                              hintText: "Enter Your Password",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                                icon: Icon(isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                              ),
                            ),
                            obscureText: !isPasswordVisible,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          isLoading
                              ? CircularProgressIndicator.adaptive()
                              : MyElevatedButton(
                                  label: 'Login',
                                  onPressed: () async {
                                    String emailAddress = emailController.text;
                                    String password = passwordController.text;
                                    try {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                        email: emailAddress,
                                        password: password,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                      // Navigate to home page if sign-in is successful
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('Login Successfully!')));
                                    } on FirebaseAuthException catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (e.code == 'user-not-found') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'No user found for that email.')),
                                        );
                                      } else if (e.code == 'wrong-password') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Invalid password.')),
                                        );
                                      } else if (e.code == 'channel-error') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Invalid user credentials.')));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Error: ${e.message}')),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'An unexpected error occurred: $e')),
                                      );
                                    }
                                  },
                                ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t Have an Account | '),
                        TextButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            );
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            'Signup',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Theme.of(context).colorScheme.primary),
                          ),
                          style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
