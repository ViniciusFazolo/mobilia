import 'package:flutter/material.dart';
import 'package:mobilia/controller/contract_controller.dart';
import 'package:mobilia/utils/textInputFormatter.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_date.dart';
import 'package:mobilia/utils/widget/input_select.dart';

class Contract extends StatefulWidget {
  const Contract({super.key});

  @override
  State<Contract> createState() => _ContractState();
}

class _ContractState extends State<Contract> {
  ContractController controller = ContractController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await controller.fetchUsers();
    await controller.fetchResident();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormLayout(title: "Cadastrar contrato", child: content());
  }

  content() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: controller.formKey,
      child: Column(
        spacing: 10,
        children: [
          InputDate(
            label: "Data de inicio",
            controller: controller.dtInicioController,
          ),
          InputDate(
            label: "Data de fim",
            controller: controller.dtFimController,
          ),
          InputDate(
            label: "Data de vencimento",
            controller: controller.dtVencimentoController,
          ),
          InputSelect<String>(
            value: controller.tipoLocacaoSelecionado,
            items: controller.tipoLocacao
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e["value"],
                    child: Text(e["label"]!),
                  ),
                )
                .toList(),
            label: "Tipo de locação",
            onChanged: (value) {
              setState(() {
                controller.tipoLocacaoSelecionado = value;
              });
            },
            validator: null,
          ),
          Input(
            label: "Valor do depósito",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigitsWithDecimal],
            controller: controller.valorDepositoController,
          ),
          InputSelect<int>(
            key: ValueKey('morador_${controller.residents.length}'),
            value: controller.residenteSelecionado != 0 ? controller.residenteSelecionado : null,
            items: controller.residents.isEmpty
                ? [const DropdownMenuItem<int>(value: null, child: Text("Nenhum morador cadastrado"))]
                : controller.residents
                    .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.nome)))
                    .toList(),
            label: "Morador",
            onChanged: controller.residents.isEmpty
                ? null
                : (value) {
                    setState(() {
                      controller.residenteSelecionado = value ?? 0;
                    });
                  },
            validator: null,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () {
                      controller.submitForm(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Salvar"),
            ),
          ),
        ],
      ),
    );
  }
}
