import 'package:flutter/material.dart';
import 'package:mobilia/controller/login_controller.dart';
import 'package:mobilia/utils/widget/button.dart';
import 'package:mobilia/utils/widget/input.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  LoginController loginController = LoginController();
  final loginTextControler = TextEditingController();
  final pwTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            spacing: 8,
            children: [
              Image.asset(
                'assets/logo/logo-transparente.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              Input(label: "Login", controller: loginTextControler),
              Input(
                label: "Senha",
                controller: pwTextController,
                obscureText: true,
              ),
              SizedBox(
                width: double.infinity,
                child: Button(label: "Login", onPressed: onPressedLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onPressedLogin() {
    if (!_formKey.currentState!.validate()) return;

    loginController.login(
      context,
      login: loginTextControler.text,
      pw: pwTextController.text,
    );
  }
}
