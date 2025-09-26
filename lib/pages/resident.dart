import 'package:flutter/material.dart';
import 'package:mobilia/controller/resident_controller.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_date.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mobilia/utils/widget/input_switch.dart';

class Resident extends StatefulWidget {
  const Resident({super.key});

  @override
  State<Resident> createState() => _ResidentState();
}

class _ResidentState extends State<Resident> {
  ResidentController residentController = ResidentController();

  @override
  void initState() {
    super.initState();
    residentController.fetchProperty(context, () => setState(() {}));
    residentController.fetchUnit(context, () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return FormLayout(title: "Cadastrar morador", child: _content());
  }

  _content() {
    return Form(
      key: residentController.formKey,
      child: Column(
        spacing: 10,
        children: [
          InputSwitch(
            label: "Ativo?",
            value: residentController.ativo,
            onChanged: (val) {
              setState(() {
                residentController.ativo = val;
              });
            },
          ),
          Input(label: "Nome", controller: residentController.nomeController),
          Input(
            label: "E-mail",
            controller: residentController.emailController,
          ),
          Input(
            label: "Telefone",
            controller: residentController.telefoneController,
          ),
          Input(label: "RG", controller: residentController.rgController),
          Input(label: "CPF", controller: residentController.cpfController),
          InputDate(label: "Data de nascimento", controller: residentController.dtNascimentoController,),
          InputDate(label: "Data inicial", controller: residentController.dtInicioController,),
          InputDate(label: "Data final", controller: residentController.dtFimController,),
          InputDate(label: "Data de vencimento do aluguel", controller: residentController.dtVencimentoController,),
          InputSelect(
            items: residentController.properties
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nome)))
                .toList(),
            label: "Em qual imóvel esse morador reside?",
            onChanged: (value) {
              residentController.imovelSelecionado = value!;
            },
          ),
          InputSelect(
            items: residentController.units
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.identificacao)))
                .toList(),
            label: "Em qual unidade esse imóvel está?",
            onChanged: (value) {
              residentController.unidadeSelecionado = value!;
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: residentController.isLoading
                  ? null
                  : () => residentController.submitForm(
                      context,
                      () => setState(() {}),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: residentController.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Salvar"),
            ),
          ),
        ],
      ),
    );
  }
}
