import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobilia/domain/contract.dart' as domain;
import 'package:mobilia/domain/contract.dart';
import 'package:mobilia/pages/contract.dart';
import 'package:mobilia/pages/contract_pdf_view.dart';
import 'package:mobilia/service/contract_service.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:intl/intl.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  List<domain.Contrato> contracts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = ContractService(baseUrl: apiBaseUrl);
      final response = await service.get("contrato");

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

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Contract()),
    );
    
    // Recarrega a lista quando volta da tela de cadastro
    if (result == true || result == null) {
      _loadContracts();
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
        onRefresh: _loadContracts,
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
              onPressed: _loadContracts,
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
              "Nenhum contrato cadastrado",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
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
                  if (contract.valorAluguel != null) ...[
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "R\$ ${contract.valorAluguel!.toStringAsFixed(2)}",
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
