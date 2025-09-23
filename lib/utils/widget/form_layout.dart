import 'package:flutter/material.dart';

class FormLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const FormLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 10),
          child: child,
        )
      )
    );
  }
}