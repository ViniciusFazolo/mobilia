import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilia/controller/unit_controller.dart';
import 'package:mobilia/utils/textInputFormatter.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_image.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mobilia/utils/widget/input_switch.dart';

class Unit extends StatefulWidget {
  const Unit({super.key});

  @override
  State<Unit> createState() => _UnitState();
}

class _UnitState extends State<Unit> {
  final UnitController unitController = UnitController();

  @override
  void initState() {
    super.initState();
    unitController.fetchProperty(context, () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return FormLayout(title: "Cadastrar unidade", child: _content());
  }

  _content() {
    return Form(
      key: unitController.formKey,
      child: Column(
        spacing: 10,
        children: [
          InputSwitch(
            label: "Ativo?",
            value: unitController.isActive,
            onChanged: (val) {
              setState(() {
                unitController.isActive = val;
              });
            },
          ),
          InputSwitch(
            label: "Possui cozinha?",
            value: unitController.cozinha,
            onChanged: (val) {
              setState(() {
                unitController.cozinha = val;
              });
            },
          ),
          InputSwitch(
            label: "Possui área de serviço?",
            value: unitController.areaServico,
            onChanged: (val) {
              setState(() {
                unitController.areaServico = val;
              });
            },
          ),
          InputSelect(
            items: unitController.properties
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nome)))
                .toList(),
            label: "Essa unidade pertence a que imóvel?",
            onChanged: (value) {
              unitController.imovelSelecionado = value!;
            },
          ),
          InputSelect(
            items: unitController.statusOptions
                .map(
                  (e) => DropdownMenuItem(
                    value: e["value"],
                    child: Text(e["label"]!),
                  ),
                )
                .toList(),
            label: "Status",
            onChanged: (value) {
              unitController.statusSelecionado = value!;
            },
          ),
          Input(
            label: "Valor do aluguel",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigits],
            controller: unitController.valorAluguelController,
          ),
          Input(
            label: "Área total",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigitsWithDecimal],
            controller: unitController.areaTotalController,
          ),
          Input(label: "Bloco", controller: unitController.blocoController),
          Input(
            label: "Complemento",
            controller: unitController.complementoController,
          ),
          Input(
            label: "Identificação",
            controller: unitController.identificacaoController,
          ),
          Input(
            label: "Descrição",
            controller: unitController.descricaoController,
          ),
          Input(
            label: "Quantidade de salas",
            keyboardType: TextInputType.number,
            controller: unitController.qtdSalaController,
          ),
          Input(
            label: "Quantidade de quartos",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigits],
            controller: unitController.qtdQuartoController,
          ),
          Input(
            label: "Quantidade de banheiros",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigits],
            controller: unitController.qtdBanheiroController,
          ),
          Input(
            label: "Quantidade de suítes",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigits],
            controller: unitController.qtdSuiteController,
          ),
          Input(
            label: "Quantidade de garagens",
            keyboardType: TextInputType.number,
            inputFormatters: [onlyDigits],
            controller: unitController.qtdGaragemController,
          ),
          InputImage(
            label: "Imagens do imóvel",
            multiple: true,
            onChanged: (file) {
              setState(() {
                if (file != null) {
                  unitController.imagens.add(file);
                }
              });
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: unitController.isLoading
                  ? null
                  : () => unitController.submitForm(
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
              child: unitController.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Salvar"),
            ),
          ),
        ],
      ),
    );
  }
}
