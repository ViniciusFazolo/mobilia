import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilia/pages/login.dart';

class WelcomeController {
  void startApplication(BuildContext context) {
    Future future = Future.delayed(Duration(seconds: 2));
    future.then((value) => {_callApi(context)});
  }

  Future _callApi(BuildContext context) async {
    Map<String, dynamic> data = {'login': '1234', 'senha': '123'};

    String body = json.encode(data);

    try {
      final url = Platform.isAndroid
          ? "http://10.0.2.2:8080/auth/login"
          : "https://aluguei-app-production.up.railway.app/auth/login";
      
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } catch (e) {
      // Aqui cai se a API estiver desligada ou fora do ar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }
}
