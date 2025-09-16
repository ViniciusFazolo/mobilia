import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilia/pages/home.dart';
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
      final response = await http.post(
        Uri.parse('http://localhost:8080/auth/login'),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
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
