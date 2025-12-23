import 'package:flutter/material.dart';
import 'package:mobilia/controller/welcome_controller.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  WelcomeController control = WelcomeController();

  @override
  void initState() {
    super.initState();
    control.startApplication(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown[50],
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset("assets/logo/logo-transparente.png", fit: BoxFit.contain),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 100),
            child: Text(
              "Aluguei",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
