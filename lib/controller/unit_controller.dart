import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/unit.dart';
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/service/unit_service.dart';
import 'package:mobilia/utils/utils.dart';

class UnitController {
  final formKey = GlobalKey<FormState>();
  List<Property> properties = [];
  final List<Map<String, String>> statusOptions = [
    {'value': 'OCUPADA', 'label': 'Ocupada'},
    {'value': 'VAZIA', 'label': 'Vazia'},
  ];

  int? editingId; // ID do item sendo editado

  // estados booleanos
  bool isActive = true;
  bool cozinha = true;
  bool areaServico = true;
  bool isLoading = false;

  // controllers
  final valorAluguelController = TextEditingController();
  final areaTotalController = TextEditingController();
  final blocoController = TextEditingController();
  final complementoController = TextEditingController();
  final identificacaoController = TextEditingController();
  final descricaoController = TextEditingController();
  final numeroController = TextEditingController();
  final qtdSalaController = TextEditingController();
  final qtdQuartoController = TextEditingController();
  final qtdBanheiroController = TextEditingController();
  final qtdGaragemController = TextEditingController();
  final qtdSuiteController = TextEditingController();
  String statusSelecionado = "";
  int imovelSelecionado = 0;
  List<File> imagens = [];
  bool imagensModificadas = false; // Flag para saber se as imagens foram modificadas

  Future<bool> submitForm(BuildContext context, VoidCallback refresh) async {
    if (!formKey.currentState!.validate()) return false;

    final service = UnitService(baseUrl: apiBaseUrl);

    _setLoading(refresh, true);

    debugPrint('=== Unit Submit ===');
    debugPrint('editingId: $editingId');
    debugPrint('isEdit: ${editingId != null}');
    debugPrint('statusSelecionado: "$statusSelecionado"');
    debugPrint('imovelSelecionado: $imovelSelecionado');

    try {
      // Se está editando e não há novas imagens selecionadas, não envia imagens
      // Isso preserva as imagens existentes no backend
      final imagensParaEnviar = editingId != null && imagens.isEmpty 
          ? null 
          : (imagens.isNotEmpty ? imagens : null);
      
      debugPrint('DEBUG submitForm - editingId: $editingId');
      debugPrint('DEBUG submitForm - imagens.length: ${imagens.length}');
      debugPrint('DEBUG submitForm - imagensParaEnviar: ${imagensParaEnviar?.length ?? "null"}');
      
      final response = editingId != null
          ? await service.updateUnit(
              id: editingId!,
              ativo: isActive,
              cozinha: cozinha,
              areaServico: areaServico,
              valorAluguel: valorAluguelController.text,
              areaTotal: areaTotalController.text,
              bloco: blocoController.text,
              complemento: complementoController.text,
              identificacao: identificacaoController.text,
              descricao: descricaoController.text,
              qtdSala: qtdSalaController.text,
              qtdQuarto: qtdQuartoController.text,
              qtdBanheiro: qtdBanheiroController.text,
              qtdSuite: qtdSuiteController.text,
              qtdGaragem: qtdGaragemController.text,
              imagens: imagensParaEnviar,
              imovel: imovelSelecionado,
              status: statusSelecionado.isNotEmpty ? statusSelecionado : 'VAZIA',
            )
          : await service.createUnit(
              ativo: isActive,
              cozinha: cozinha,
              areaServico: areaServico,
              valorAluguel: valorAluguelController.text,
              areaTotal: areaTotalController.text,
              bloco: blocoController.text,
              complemento: complementoController.text,
              identificacao: identificacaoController.text,
              descricao: descricaoController.text,
              qtdSala: qtdSalaController.text,
              qtdQuarto: qtdQuartoController.text,
              qtdBanheiro: qtdBanheiroController.text,
              qtdSuite: qtdSuiteController.text,
              qtdGaragem: qtdGaragemController.text,
              imagens: imagens,
              imovel: imovelSelecionado,
              status: statusSelecionado.isNotEmpty ? statusSelecionado : 'VAZIA',
            );

      _setLoading(refresh, false);

      debugPrint('Resposta do servidor: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingId != null
                ? "Unidade atualizada com sucesso!"
                : "Unidade cadastrada com sucesso!"),
          ),
        );
        // Não reseta mais o formulário, pois vamos voltar para a listagem
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingId != null
                ? "Erro ao atualizar unidade (${response.statusCode})"
                : "Erro ao cadastrar unidade (${response.statusCode})"),
          ),
        );
        return false;
      }
    } catch (e) {
      _setLoading(refresh, false);
      debugPrint('Erro ao enviar unidade: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(editingId != null
              ? "Erro ao atualizar unidade: $e"
              : "Erro ao cadastrar unidade: $e"),
        ),
      );
      return false;
    }
  }

  void loadForEdit(Unit unit) {
    editingId = unit.id;
    debugPrint('Carregando unidade para edição - ID: $editingId');
    isActive = unit.ativo;
    cozinha = unit.cozinha;
    areaServico = unit.areaServico;
    valorAluguelController.text = unit.valorAluguel;
    areaTotalController.text = unit.areaTotal;
    blocoController.text = unit.bloco ?? '';
    complementoController.text = unit.complemento ?? '';
    identificacaoController.text = unit.identificacao;
    descricaoController.text = unit.descricao ?? '';
    qtdSalaController.text = unit.qtdSala ?? '';
    qtdQuartoController.text = unit.qtdQuarto ?? '';
    qtdBanheiroController.text = unit.qtdBanheiro ?? '';
    qtdSuiteController.text = unit.qtdSuite ?? '';
    qtdGaragemController.text = unit.qtdGaragem ?? '';
    imovelSelecionado = unit.imovel?.id ?? 0;
    // Garante que o status seja uma string válida e corresponda aos valores esperados
    final statusFromUnit = unit.status?.toString().trim() ?? '';
    debugPrint('Status carregado da unidade (raw): "${unit.status}"');
    debugPrint('Status carregado da unidade (processed): "$statusFromUnit"');
    
    if (statusFromUnit.isNotEmpty) {
      // Verifica se o status corresponde a um dos valores válidos
      final validStatuses = statusOptions.map((e) => e["value"]).toList();
      debugPrint('Status válidos: $validStatuses');
      
      // Normaliza o status para maiúsculas para comparação
      final statusUpper = statusFromUnit.toUpperCase();
      
      // Procura o status correspondente (case-insensitive)
      final matchedStatus = validStatuses.firstWhere(
        (s) => s?.toUpperCase() == statusUpper,
        orElse: () => null,
      );
      
      if (matchedStatus != null) {
        statusSelecionado = matchedStatus;
        debugPrint('Status definido como: $statusSelecionado');
      } else {
        // Se não encontrou match, tenta usar o valor original se for OCUPADA ou VAZIA
        if (statusUpper == 'OCUPADA' || statusUpper == 'VAZIA') {
          statusSelecionado = statusUpper;
          debugPrint('Status definido diretamente (OCUPADA/VAZIA): $statusSelecionado');
        } else {
          statusSelecionado = '';
          debugPrint('Status não reconhecido, definindo como vazio');
        }
      }
    } else {
      statusSelecionado = '';
      debugPrint('Status vazio, definindo como string vazia');
    }
    debugPrint('statusSelecionado final: "$statusSelecionado"');
    imagens = unit.imagens; // Files locais (vazio ao carregar)
    imagensModificadas = false; // Reseta a flag ao carregar para edição
    debugPrint('DEBUG loadForEdit - unit.imagensUrls: ${unit.imagensUrls}');
    debugPrint('DEBUG loadForEdit - unit.imagens (Files): ${unit.imagens.length} arquivos');
  }

  Future<void> fetchProperty(BuildContext context, VoidCallback refresh) async {
    final propertyService = PropertyService(baseUrl: apiBaseUrl);
    final response = await propertyService.get("imovel");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      properties = data.map((e) => Property.fromJson(e)).toList();
    } else {
      properties = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao buscar imóveis (${response.statusCode})"),
        ),
      );
    }

    refresh();
  }

  void _setLoading(VoidCallback refresh, bool value) {
    isLoading = value;
    refresh();
  }

}
