

import 'package:ecom_user_app_firebase/pages/registration_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../utils/helper_functions.dart';

class PhoneVerificationPage extends StatefulWidget {
  static const String routeName = '/phone_verification';

  PhoneVerificationPage({Key? key}) : super(key: key);

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final txtController = TextEditingController();
  final codeController = TextEditingController();
  bool codeSent = false;
  bool showCodeTextField = false;
  String vId = '';
  @override
  void dispose() {
    txtController.dispose();
    codeController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: txtController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter Mobile Number',
                  filled: true,
                  fillColor: Colors.white
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _verifyPhoneNumber();
                },
                child: const Text('VERIFY', style: TextStyle(color: Colors.black54),),
              ),
              const SizedBox(height: 20,),
              if(showCodeTextField) Column(
                children: [
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.blue.shade50,
                    enableActiveFill: true,
                    //errorAnimationController: errorController,
                    controller: codeController,
                    onCompleted: (v) {
                      print("Completed");
                    },
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        //currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      print("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(verificationId: vId, smsCode: codeController.text);
                      FirebaseAuth.instance.signInWithCredential(credential)
                          .then((userCredential) {
                            if(userCredential.user != null) {
                              AuthService.logout().then((value) =>
                                  Navigator.pushReplacementNamed(context, RegistrationPage.routeName, arguments: txtController.text));

                            }
                      });
                    },
                    child: const Text('SENT', style: TextStyle(color: Colors.black54),),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _verifyPhoneNumber() async {
    setState(() {
      showCodeTextField = true;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: txtController.text,
      verificationCompleted: (PhoneAuthCredential credential) {
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        showMsg(context, 'Code sent');
        vId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
