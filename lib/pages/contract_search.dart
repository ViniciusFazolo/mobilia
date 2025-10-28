import 'package:flutter/material.dart';
import 'package:mobilia/controller/contract_search_controller.dart';
import 'package:mobilia/domain/contract.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/pages/contract_pdf_view.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:intl/intl.dart';

class ContractSearch extends StatefulWidget {
  const ContractSearch({super.key});

  @override
  State<ContractSearch> createState() => _ContractSearchState();
}

class _ContractSearchState extends State<ContractSearch> {
  ContractSearchController controller = ContractSearchController();
  List<Morador> residents = [];
  List<Contrato> contracts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getResidents();
  }

  void _getResidents() async {
    List<Morador> res = await controller.getResidents();

    setState(() {
      residents = res;
    });
  }

  void _getContractsByResidentId(int? id) async {
    setState(() {
      isLoading = true;
    });

    List<Contrato> res = await controller.getContractsByResidentId(id);

    setState(() {
      contracts = res;
      isLoading = false;
    });
  }

  void _showContractDetails(Contrato contrato) {
    if (contrato.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID do contrato não disponível'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPdfView(contrato: contrato),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getObjetoLocacaoLabel(ObjetoLocacao? obj) {
    if (obj == null) return 'N/A';
    switch (obj) {
      case ObjetoLocacao.CASA_RESIDENCIAL:
        return 'Casa Residencial';
      case ObjetoLocacao.APARTAMENTO_RESIDENCIAL:
        return 'Apartamento Residencial';
      case ObjetoLocacao.PONTO_COMERCIAL:
        return 'Ponto Comercial';
    }
  }

  Widget _buildContractCards() {
    if (contracts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Nenhum contrato encontrado',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contrato = contracts[index];

        return InkWell(
          onTap: () => _showContractDetails(contrato),
          borderRadius: BorderRadius.circular(12),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unidade e Imóvel
                  Row(
                    children: [
                      Icon(Icons.home, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contrato.unidade?.identificacao ??
                                  'Unidade não informada',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contrato.imovel?.nome ?? 'Imóvel não informado',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  const Divider(height: 24),

                  // Objeto de Locação
                  _buildInfoRow(
                    icon: Icons.business,
                    label: 'Tipo',
                    value: _getObjetoLocacaoLabel(contrato.objLocacao),
                  ),
                  const SizedBox(height: 12),

                  // Datas
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Início',
                    value: _formatDate(contrato.dataInicio),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.event,
                    label: 'Fim',
                    value: _formatDate(contrato.dataFim),
                  ),

                  // Status (opcional)
                  if (contrato.status != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: contrato.status!
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        contrato.status! ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          color: contrato.status!
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Consultar contratos")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputSelect(
                  label: "Selecione um morador",
                  items: residents
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.nome)),
                      )
                      .toList(),
                  onChanged: (val) {
                    _getContractsByResidentId(val);
                  },
                ),
                const SizedBox(height: 20),
                _buildContractCards(),
              ],
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
