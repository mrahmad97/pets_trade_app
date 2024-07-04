import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  final auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter an email";
    }
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }
  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your full name";
    }
    final RegExp nameRegExp = RegExp(
      r"^[a-zA-Z\s]+$",
    );
    if (!nameRegExp.hasMatch(value)) {
      return "Name can only contain letters and spaces";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/app_logo.png',
                      width: 70,
                      height: 70,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            validator: validateFullName,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                icon: Icon(Icons.person),
                                label: Text('Full Name'),
                                hintText: 'Enter your name'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: emailController,
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                icon: Icon(Icons.email),
                                label: Text('Email Address'),
                                hintText: 'Enter Your email Address'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (value!.length < 6) {
                                return "Please Enter password of min length 6";
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                icon: Icon(Icons.lock),
                                label: Text('Password'),
                                hintText: 'Enter Password'),
                            obscureText: !isPasswordVisible,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: confirmPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                icon: Icon(Icons.lock),
                                label: Text('Confirm Password'),
                                hintText: 'Confirm Password'),
                            obscureText: !isPasswordVisible,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          isLoading
                              ? Center(
                                  child: CircularProgressIndicator.adaptive())
                              : MyElevatedButton(
                                  label: 'Sign up',
                                  onPressed: () async {
                                    if(formKey.currentState!.validate()){
                                      String email = emailController.text;
                                      String password = passwordController.text;
                                      String fullName = nameController.text;

                                      if (fullName.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Please enter your fullname.')),
                                        );
                                        return;
                                      }

                                      try {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        UserCredential userCredential =
                                            await FirebaseAuth.instance
                                                .createUserWithEmailAndPassword(
                                          email: email,
                                          password: password,
                                        );

                                        await userCredential.user
                                            ?.updateDisplayName(fullName);

                                        await userCredential.user?.reload();

                                        setState(() {
                                          isLoading = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Account created successfully.')),
                                        );

                                        Navigator.of(context).pop();
                                      } on FirebaseAuthException catch (e) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (e.code == 'weak-password') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Password must be at least 8 characters.')));
                                        } else if (e.code ==
                                            'email-already-in-use') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'The account already exists for that email.')));
                                        } else if (e.code == 'channel-error') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Check your Internet connection and try again.')));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Error: ${e.code}')));
                                        }
                                      } catch (e) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        print(e);
                                      }
                                    }
                                  },
                                )
                        ],
                      ),
                    ),
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
