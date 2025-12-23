import 'package:flutter/material.dart';
import 'package:mobilia/controller/resident_controller.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/utils/textInputFormatter.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_date.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mobilia/utils/widget/input_switch.dart';

class Resident extends StatefulWidget {
  final Morador? residentToEdit;
  
  const Resident({super.key, this.residentToEdit});

  @override
  State<Resident> createState() => _ResidentState();
}

class _ResidentState extends State<Resident> {
  ResidentController residentController = ResidentController();

  @override
  void initState() {
    super.initState();
    residentController.fetchUnit(context, () {
      if (widget.residentToEdit != null) {
        residentController.loadForEdit(widget.residentToEdit!);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.residentToEdit != null ? "Editar morador" : "Cadastrar morador";
    return FormLayout(title: title, child: _content());
  }

  _content() {
    return Form(
      key: residentController.formKey,
      child: Column(
        spacing: 10,
        children: [
          Input(label: "Nome", controller: residentController.nomeController),
          Input(
            label: "E-mail",
            controller: residentController.emailController,
          ),
          Input(
            label: "Telefone",
            controller: residentController.telefoneController,
            inputFormatters: [telefoneMask],
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Telefone obrigatório";
              }
              // Remove caracteres não numéricos para verificar se tem 10 ou 11 dígitos
              final digits = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.length < 10 || digits.length > 11) {
                return "Telefone incompleto";
              }
              return null;
            },
          ),
          Input(label: "RG", controller: residentController.rgController),
          Input(
            label: "CPF",
            controller: residentController.cpfController,
            inputFormatters: [cpfMask],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "CPF obrigatório";
              }
              // Remove caracteres não numéricos para verificar se tem 11 dígitos
              final digits = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.length != 11) {
                return "CPF incompleto";
              }
              return null;
            },
          ),
          InputDate(
            label: "Data inicial",
            controller: residentController.dtInicioController,
          ),
          InputDate(
            label: "Data final",
            controller: residentController.dtFimController,
          ),
          InputDate(
            label: "Data de vencimento do aluguel",
            controller: residentController.dtVencimentoController,
          ),
          InputSelect<int>(
            key: ValueKey('unidade_${residentController.unidadeSelecionado}_${residentController.editingId}'),
            value: residentController.unidadeSelecionado != null && residentController.unidadeSelecionado != 0
                ? residentController.unidadeSelecionado
                : null,
            items: residentController.units
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.id,
                    child: Text(e.identificacao),
                  ),
                )
                .toList(),
            label: "Em qual unidade esse morador reside?",
            onChanged: (value) {
              setState(() {
                residentController.unidadeSelecionado = value;
              });
            },
          ),
          InputSwitch(
            label: "Ativo?",
            value: residentController.ativo,
            onChanged: (val) {
              setState(() {
                residentController.ativo = val;
              });
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: residentController.isLoading
                  ? null
                  : () async {
                      final success = await residentController.submitForm(
                        context,
                        () => setState(() {}),
                      );
                      // Se estava editando e a operação foi bem-sucedida, volta para a lista
                      if (success && widget.residentToEdit != null && context.mounted) {
                        // Aguarda um pouco para mostrar a mensagem de sucesso
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
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
