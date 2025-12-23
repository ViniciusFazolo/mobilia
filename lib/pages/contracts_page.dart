import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobilia/domain/contract.dart' as domain;
import 'package:mobilia/domain/contract.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/pages/contract.dart';
import 'package:mobilia/pages/contract_pdf_view.dart';
import 'package:mobilia/service/contract_service.dart';
import 'package:mobilia/service/resident_service.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:intl/intl.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  List<domain.Contrato> contracts = [];
  List<Morador> residents = [];
  bool isLoading = true;
  bool isLoadingResidents = false;
  String? errorMessage;
  int? selectedResidentId; // ID do morador selecionado para filtro

  @override
  void initState() {
    super.initState();
    _loadResidents();
    _loadContracts();
  }

  Future<void> _loadResidents() async {
    setState(() {
      isLoadingResidents = true;
    });

    try {
      final service = ResidentService(baseUrl: apiBaseUrl);
      final response = await service.get("morador");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          residents = data.map((e) => Morador.fromJson(e)).toList();
          isLoadingResidents = false;
        });
      } else {
        setState(() {
          isLoadingResidents = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingResidents = false;
      });
    }
  }

  Future<void> _loadContracts({int? moradorId}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = ContractService(baseUrl: apiBaseUrl);
      final String endpoint = moradorId != null
          ? "contrato/byMoradorId/$moradorId"
          : "contrato";
      final response = await service.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          contracts = data.map((e) => domain.Contrato.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Erro ao carregar contratos (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao conectar com a API: $e";
        isLoading = false;
      });
    }
  }

  void _onResidentChanged(int? residentId) {
    setState(() {
      selectedResidentId = residentId;
    });
    _loadContracts(moradorId: residentId);
  }

  void _clearFilter() {
    setState(() {
      selectedResidentId = null;
    });
    _loadContracts();
  }

  Future<void> _deleteContract(domain.Contrato contract) async {
    final contractName = contract.unidade?.identificacao ?? 
                        contract.imovel?.nome ?? 
                        "Contrato #${contract.id}";
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: Text("Deseja realmente excluir o contrato \"$contractName\"?\n\nEsta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm == true && contract.id != null) {
      try {
        final service = ContractService(baseUrl: apiBaseUrl);
        final endpoint = "contrato/${contract.id}";
        debugPrint("Deletando contrato - Endpoint: $endpoint, ID: ${contract.id}");
        final response = await service.delete(endpoint);

        if (response.statusCode == 200 || response.statusCode == 204) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Contrato excluído com sucesso!"),
                backgroundColor: Colors.green,
              ),
            );
            _loadContracts(moradorId: selectedResidentId);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro ao excluir contrato (${response.statusCode})"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao excluir contrato: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Contract()),
    );
    
    // Recarrega a lista quando volta da tela de cadastro
    if (result == true || result == null) {
      _loadContracts(moradorId: selectedResidentId);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getObjetoLocacaoLabel(domain.ObjetoLocacao? obj) {
    if (obj == null) return 'N/A';
    switch (obj) {
      case domain.ObjetoLocacao.CASA_RESIDENCIAL:
        return 'Casa Residencial';
      case domain.ObjetoLocacao.APARTAMENTO_RESIDENCIAL:
        return 'Apartamento Residencial';
      case domain.ObjetoLocacao.PONTO_COMERCIAL:
        return 'Ponto Comercial';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contratos"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadContracts(moradorId: selectedResidentId),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text("Novo Contrato"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Filtro por morador
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputSelect<int>(
                      label: "Filtrar por morador",
                      hint: "Selecione um morador (opcional)",
                      value: selectedResidentId,
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text("Todos os contratos"),
                        ),
                        ...residents.map(
                          (resident) => DropdownMenuItem<int>(
                            value: resident.id,
                            child: Text(resident.nome),
                          ),
                        ),
                      ],
                      onChanged: _onResidentChanged,
                      validator: null, // Não é obrigatório
                    ),
                  ),
                  if (selectedResidentId != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _clearFilter,
                      icon: const Icon(Icons.clear),
                      tooltip: "Limpar filtro",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Lista de contratos
        Expanded(
          child: _buildContractsList(),
        ),
      ],
    );
  }

  Widget _buildContractsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadContracts(moradorId: selectedResidentId),
              child: const Text("Tentar novamente"),
            ),
          ],
        ),
      );
    }

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              selectedResidentId != null
                  ? "Nenhum contrato encontrado para este morador"
                  : "Nenhum contrato cadastrado",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (selectedResidentId == null)
              Text(
                "Toque no botão + para cadastrar",
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              if (contract.id != null) {
                // Cria Contrato diretamente copiando os campos do domain.Contrato
                // Isso evita problemas de conversão JSON
                final contrato = Contrato(
                  id: contract.id,
                  dataInicio: contract.dataInicio,
                  dataFim: contract.dataFim,
                  dataVencimento: contract.dataVencimento,
                  valorAluguel: contract.valorAluguel,
                  valorDeposito: contract.valorDeposito,
                  status: contract.status,
                  objLocacao: contract.objLocacao,
                  qtd: contract.qtd,
                  endereco: contract.endereco,
                  cidade: contract.cidade,
                  estado: contract.estado,
                  cep: contract.cep,
                  bairro: contract.bairro,
                  rua: contract.rua,
                  numero: contract.numero,
                  user: contract.user,
                  morador: contract.morador,
                  unidade: contract.unidade,
                  imovel: contract.imovel,
                  dtCadastro: contract.dtCadastro,
                  pdfContrato: contract.pdfContrato,
                );
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContractPdfView(contrato: contrato),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ID do contrato não disponível'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (contract.unidade != null)
                              Text(
                                contract.unidade!.identificacao,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              const Text(
                                "Contrato",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (contract.imovel != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                contract.imovel!.nome,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (contract.status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: contract.status!
                                    ? Colors.green[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                contract.status! ? "Ativo" : "Inativo",
                                style: TextStyle(
                                  color: contract.status!
                                      ? Colors.green[800]
                                      : Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteContract(contract),
                            tooltip: "Excluir contrato",
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (contract.morador != null) ...[
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contract.morador!.nome,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (contract.objLocacao != null) ...[
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _getObjetoLocacaoLabel(contract.objLocacao),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (contract.unidade?.valorAluguel != null && contract.unidade!.valorAluguel.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "R\$ ${contract.unidade!.valorAluguel}",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "Início: ${_formatDate(contract.dataInicio)}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      if (contract.dataFim != null) ...[
                        const SizedBox(width: 16),
                        Text(
                          "Fim: ${_formatDate(contract.dataFim)}",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
