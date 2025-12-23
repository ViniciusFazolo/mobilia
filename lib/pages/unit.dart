import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilia/controller/unit_controller.dart';
import 'package:mobilia/domain/unit.dart' as domain;
import 'package:mobilia/utils/textInputFormatter.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_image.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mobilia/utils/widget/input_switch.dart';

class Unit extends StatefulWidget {
  final domain.Unit? unitToEdit;
  
  const Unit({super.key, this.unitToEdit});

  @override
  State<Unit> createState() => _UnitState();
}

class _UnitState extends State<Unit> {
  final UnitController unitController = UnitController();

  @override
  void initState() {
    super.initState();
    // Busca as propriedades primeiro
    unitController.fetchProperty(context, () {
      // Depois, se há unidade para editar, carrega os dados
      if (widget.unitToEdit != null) {
        unitController.loadForEdit(widget.unitToEdit!);
      }
      // Atualiza a UI após tudo estar carregado
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.unitToEdit != null ? "Editar unidade" : "Cadastrar unidade";
    return FormLayout(title: title, child: _content());
  }

  _content() {
    return Form(
      key: unitController.formKey,
      child: Column(
        spacing: 10,
        children: [
          InputSelect<int>(
            key: ValueKey('imovel_${unitController.imovelSelecionado}_${unitController.editingId}'),
            value: unitController.imovelSelecionado != 0 ? unitController.imovelSelecionado : null,
            items: unitController.properties
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nome)))
                .toList(),
            label: "Essa unidade pertence a que imóvel?",
            onChanged: (value) {
              setState(() {
                unitController.imovelSelecionado = value ?? 0;
              });
            },
          ),
          InputSelect<String>(
            key: ValueKey('status_${unitController.statusSelecionado}_${unitController.editingId}'),
            value: unitController.statusSelecionado.isNotEmpty 
                ? unitController.statusSelecionado 
                : null,
            items: unitController.statusOptions
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e["value"],
                    child: Text(e["label"]!),
                  ),
                )
                .toList(),
            label: "Status",
            onChanged: (value) {
              setState(() {
                unitController.statusSelecionado = value ?? '';
              });
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
          Builder(
            builder: (context) {
              final imageUrls = widget.unitToEdit?.imagensUrls;
              print('DEBUG InputImage Unit - imageUrls: $imageUrls');
              return InputImage(
                label: "Imagens do imóvel",
                multiple: true,
                initialImageUrls: imageUrls,
                onChangedMultiple: (files) {
                  setState(() {
                    debugPrint(files.map((f) => f.path).join(', '));
                    unitController.imagens = files;
                    unitController.imagensModificadas = true; // Marca que as imagens foram modificadas
                  });
                },
              );
            },
          ),
          InputSwitch(
            label: "Ativo?",
            value: unitController.isActive,
            onChanged: (val) {
              setState(() {
                unitController.isActive = val;
              });
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: unitController.isLoading
                  ? null
                  : () async {
                      final success = await unitController.submitForm(
                        context,
                        () => setState(() {}),
                      );
                      // Volta para a listagem após salvar (tanto para cadastro quanto edição)
                      if (success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
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
