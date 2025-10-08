import 'package:flutter/material.dart';
import 'package:mobilia/controller/contract_controller.dart';
import 'package:mobilia/utils/estados.dart';
import 'package:mobilia/utils/textInputFormatter.dart';
import 'package:mobilia/utils/utils.dart';
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

  @override
  void initState() {
    super.initState();
    controller.fetchUsers();
    controller.fetchResident();
    controller.fetchUnit();
    controller.fetchProperty();
  }

  @override
  Widget build(BuildContext context) {
    return FormLayout(title: "Cadastrar contrato", child: content());
  }

  content() {
    return Form(
      key: controller.formKey,
      child: Column(
        spacing: 10,
        children: [
          Input(
            label: "CEP",
            controller: controller.cepController,
            onFocusChange: (focus) async {
              if (!focus) {
                if (controller.cepController.text.isNotEmpty) {
                  final resultado = await findCep(
                    controller.cepController.text,
                  );
                  if (resultado != null) {
                    setState(() {
                      controller.cidadeController.text = resultado['cidade']!;
                      controller.bairroController.text = resultado['bairro']!;
                      controller.ruaController.text = resultado['rua']!;
                      controller.estadoSelecionado = resultado['estado']!;
                    });
                  }
                }
              }
            },
          ),
          Input(label: "Rua", controller: controller.ruaController),
          InputSelect<String>(
            label: "Estado",
            value: controller.estadoSelecionado,
            items: estados
                .map(
                  (e) => DropdownMenuItem(
                    value: e["sigla"],
                    child: Text(e["nome"]!),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() {
                controller.estadoSelecionado = val;
              });
            },
            validator: (val) {
              if (val == null) return "Campo obrigatório";
              return null;
            },
          ),
          Input(label: "Cidade", controller: controller.cidadeController),
          Input(label: "Bairro", controller: controller.bairroController),
          Input(
            label: "Número",
            controller: controller.numeroController,
            requiredField: false,
          ),
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
          InputSelect(
            items: controller.tipoLocacao
                .map(
                  (e) => DropdownMenuItem(
                    value: e["value"],
                    child: Text(e["label"]!),
                  ),
                )
                .toList(),
            label: "Tipo de locação",
            onChanged: (value) {
              controller.tipoLocacaoSelecionado = value!;
            },
          ),
          Input(
            label: "Valor do aluguel",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigitsWithDecimal],
            controller: controller.valorAluguelController,
          ),
          Input(
            label: "Valor do depósito",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigitsWithDecimal],
            controller: controller.valorDepositoController,
          ),
          InputSelect(
            items: controller.properties
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nome)))
                .toList(),
            label: "Imóvel",
            onChanged: (value) {
              controller.imovelSelecionado = value!;
            },
          ),
          InputSelect(
            items: controller.units
                .map(
                  (e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.identificacao),
                  ),
                )
                .toList(),
            label: "Unidade",
            onChanged: (value) {
              controller.unidadeSelecionado = value!;
            },
          ),
          InputSelect(
            items: controller.residents
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nome)))
                .toList(),
            label: "Morador",
            onChanged: (value) {
              controller.residenteSelecionado = value!;
            },
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
