import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobilia/domain/property.dart' as domain;
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/utils/estados.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_image.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mobilia/utils/widget/input_switch.dart';

class Property extends StatefulWidget {
  final domain.Property? propertyToEdit;
  
  const Property({super.key, this.propertyToEdit});

  @override
  State<Property> createState() => _PropertyState();
}

class _PropertyState extends State<Property> {
  final _formKey = GlobalKey<FormState>();
  bool isActive = true;
  String? estadoSelecionado;
  XFile? imagemSelecionada;
  final nomeController = TextEditingController();
  final cepController = TextEditingController();
  final estadoController = TextEditingController();
  final cidadeController = TextEditingController();
  final bairroController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.propertyToEdit != null) {
      _loadForEdit(widget.propertyToEdit!);
    }
  }

  void _loadForEdit(domain.Property property) {
    isActive = property.ativo;
    nomeController.text = property.nome;
    cepController.text = property.cep;
    estadoSelecionado = property.estado;
    cidadeController.text = property.cidade;
    bairroController.text = property.bairro;
    ruaController.text = property.rua;
    numeroController.text = property.numero?.toString() ?? '';
    complementoController.text = property.complemento ?? '';
    
    // Debug: verifica se a imagem foi carregada
    print('DEBUG _loadForEdit - property.imagem: ${property.imagem}');
    print('DEBUG _loadForEdit - property.imagens: ${property.imagens}');
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.propertyToEdit != null ? "Editar imóvel" : "Cadastrar imóvel";
    return FormLayout(title: title, child: content());
  }

  content() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 10,
        children: [
          Input(label: "Nome", controller: nomeController),
          const SizedBox(height: 16),
          const Text(
            "Endereço",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Input(
            label: "CEP",
            controller: cepController,
            onFocusChange: (focus) async {
              if (!focus) {
                if (cepController.text.isNotEmpty) {
                  final resultado = await findCep(cepController.text);
                  if (resultado != null) {
                    setState(() {
                      cidadeController.text = resultado['cidade']!;
                      bairroController.text = resultado['bairro']!;
                      ruaController.text = resultado['rua']!;
                      estadoSelecionado = resultado['estado']!;
                    });
                  }
                }
              }
            },
          ),
          InputSelect<String>(
            label: "Estado",
            value: estadoSelecionado,
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
                estadoSelecionado = val;
                // A validação automática do InputSelect vai remover a mensagem de erro
              });
            },
            validator: (val) {
              if (val == null) return "Campo obrigatório";
              return null;
            },
          ),
          Input(label: "Cidade", controller: cidadeController),
          Input(label: "Bairro", controller: bairroController),
          Input(label: "Rua", controller: ruaController),
          Input(
            label: "Número",
            controller: numeroController,
            requiredField: false,
          ),
          Input(
            label: "Complemento",
            controller: complementoController,
            requiredField: false,
          ),
          Builder(
            builder: (context) {
              final imageUrl = widget.propertyToEdit?.imagem ?? 
                  (widget.propertyToEdit?.imagens != null && widget.propertyToEdit!.imagens!.isNotEmpty
                      ? widget.propertyToEdit!.imagens!.first
                      : null);
              print('DEBUG InputImage widget - imageUrl: $imageUrl');
              return InputImage(
                label: "Imagem do imóvel",
                multiple: false,
                initialImageUrl: imageUrl,
                onChangedXFile: (xFile) {
                  setState(() {
                    imagemSelecionada = xFile;
                  });
                },
              );
            },
          ),
          InputSwitch(
            label: "Ativo?",
            value: isActive,
            onChanged: (val) {
              setState(() {
                isActive = val;
              });
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Lista de bytes para enviar ao serviço
      List<Map<String, dynamic>>? imagensBytes;
      
      if (imagemSelecionada != null) {
        // FORMA CORRETA PARA WEB: ler bytes em vez de usar path
        final bytes = await imagemSelecionada!.readAsBytes();
        imagensBytes = [
          {
            'bytes': bytes,
            'fileName': imagemSelecionada!.name,
          }
        ];
      }

      final service = PropertyService(baseUrl: apiBaseUrl);

      final response = widget.propertyToEdit != null && widget.propertyToEdit!.id != null
          ? await service.updateProperty(
              id: widget.propertyToEdit!.id!,
              ativo: isActive,
              nome: nomeController.text,
              cep: cepController.text,
              estado: estadoSelecionado ?? '',
              cidade: cidadeController.text,
              bairro: bairroController.text,
              rua: ruaController.text,
              numero: numeroController.text,
              complemento: complementoController.text,
              imagensBytes: imagensBytes,
            )
          : await service.createProperty(
              ativo: isActive,
              nome: nomeController.text,
              cep: cepController.text,
              estado: estadoSelecionado ?? '',
              cidade: cidadeController.text,
              bairro: bairroController.text,
              rua: ruaController.text,
              numero: numeroController.text,
              complemento: complementoController.text,
              imagensBytes: imagensBytes,
            );

      setState(() {
        isLoading = false;
      });

      final statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.propertyToEdit != null
                  ? "Imóvel atualizado com sucesso!"
                  : "Imóvel cadastrado com sucesso!"),
            ),
          );

          // Volta para a listagem após salvar (tanto para cadastro quanto edição)
          Navigator.pop(context, true);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.propertyToEdit != null
                  ? "Erro ao atualizar imóvel"
                  : "Erro ao cadastrar imóvel"),
            ),
          );
        }
      }
    } catch (e) {
      print("ERRO NO SUBMIT: $e");
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar imóvel: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
