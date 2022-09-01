import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_user_app_firebase/pages/phone_verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../models/user_model.dart';
import 'launcher_page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool isObscureText = true;
  final formKey = GlobalKey<FormState>();
  String errMsg = '';

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    fillColor: Colors.white,
                    filled: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field must not be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: isObscureText,
                controller: passController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(isObscureText
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() {
                      isObscureText = !isObscureText;
                    }),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field must not be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent),
                  onPressed: () {
                    authenticate();
                  },
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Forgot Password?',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Click Here',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New User?',
                    style: const TextStyle(fontSize: 18, color: Colors.white54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, PhoneVerificationPage.routeName);
                    },
                    child: const Text(
                      'Register Here',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'OR',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.g_mobiledata,
                    color: Colors.grey,
                    size: 40,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    signInWithGoogle().then((value) {
                      if (value.user != null) {
                        final userModel = UserModel(
                          uid: value.user!.uid,
                          email: value.user!.email!,
                          mobile: value.user?.phoneNumber ?? 'Not Available',
                          name: value.user?.displayName ?? 'Not Available',
                          userCreationTime:
                          Timestamp.fromDate(value.user!.metadata.creationTime!),
                        );
                        AuthService.addUser(userModel)
                            .then((value) =>
                            Navigator.pushReplacementNamed(context, LauncherPage.routeName));
                      }
                    }).catchError((error) {
                      setState(() {
                        errMsg = error.toString();
                      });
                    });
                  },
                  label: const Text('SIGN IN WITH GOOGLE',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                errMsg,
                style: TextStyle(color: Theme.of(context).errorColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  authenticate() async {
    if (formKey.currentState!.validate()) {
      try {
        final status =
            await AuthService.login(emailController.text, passController.text);
        if (status) {
          Navigator.pushReplacementNamed(context, LauncherPage.routeName);
        } else {
          AuthService.logout();
          setState(() {
            errMsg = 'You are not an Admin';
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          errMsg = e.message!;
        });
      }
    }
  }



  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

}
