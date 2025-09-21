import 'package:flutter/material.dart';
import 'package:mobilia/pages/property.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> items = [
    {
      "icon": Icons.apartment,
      "label": "Cadastrar Imóvel",
      "page": const Property(),
    },
    {"icon": Icons.add_circle_outline, "label": "Cadastrar Unidade"},
    {"icon": Icons.person_add, "label": "Cadastrar Morador"},
    {"icon": Icons.search, "label": "Consultar Apartamentos"},
    {"icon": Icons.attach_money, "label": "Aluguéis a vencer"},
    {"icon": Icons.receipt, "label": "Enviar boleto"},
    {"icon": Icons.request_quote, "label": "Reajustar aluguel"},
    {"icon": Icons.pie_chart, "label": "Estatísticas"},
    {"icon": Icons.settings, "label": "Configurações"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mobília"), centerTitle: true),
      drawer: const Drawer(),
      body: Container(
        color: Colors.grey[100],
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 40,
              runSpacing: 20,
              children: const [
                Column(
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 30,
                      color: Colors.green,
                    ),
                    Text(
                      "X Unidades alugadas",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.sentiment_dissatisfied_outlined, size: 30),
                    Text("X Unidades vazias"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: Wrap(
                  spacing: 25,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  children: items.map((item) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (item["page"] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => item["page"],
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Icon(
                              item["icon"],
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 110,
                            child: Text(
                              item["label"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
