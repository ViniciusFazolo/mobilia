import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobilia/domain/parcel.dart';
import 'package:mobilia/service/parcel_service.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:intl/intl.dart';

class ParcelsPage extends StatefulWidget {
  const ParcelsPage({super.key});

  @override
  State<ParcelsPage> createState() => _ParcelsPageState();
}

class _ParcelsPageState extends State<ParcelsPage> {
  List<Parcela> parcels = [];
  List<Parcela> filteredParcels = [];
  bool isLoading = true;
  String? errorMessage;
  late DateTime selectedDate; // Mês atual por padrão

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, 1); // Primeiro dia do mês atual
    _loadParcels();
  }

  Future<void> _loadParcels() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = ParcelService(baseUrl: apiBaseUrl);
      final response = await service.get("parcela");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          parcels = data.map((e) => Parcela.fromJson(e)).toList();
          _filterByDate();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Erro ao carregar parcelas (${response.statusCode})";
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

  void _filterByDate() {
    setState(() {
      filteredParcels = parcels.where((parcela) {
        if (parcela.dataVencimento == null) return false;
        return parcela.dataVencimento!.year == selectedDate.year &&
            parcela.dataVencimento!.month == selectedDate.month;
      }).toList();
      
      // Ordena por data de vencimento
      filteredParcels.sort((a, b) {
        if (a.dataVencimento == null || b.dataVencimento == null) return 0;
        return a.dataVencimento!.compareTo(b.dataVencimento!);
      });
    });
  }

  void _previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
      _filterByDate();
    });
  }

  void _nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      _filterByDate();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Selecione o mês',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        // Mantém apenas o mês e ano, define o dia como 1
        selectedDate = DateTime(picked.year, picked.month, 1);
        _filterByDate();
      });
    }
  }

  Future<void> _markAsPaid(Parcela parcela) async {
    if (parcela.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID da parcela não disponível'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final service = ParcelService(baseUrl: apiBaseUrl);
      
      // Atualiza o status para PAGO e define a data de pagamento como hoje
      final hoje = DateTime.now();
      final dataPagamento = DateTime(hoje.year, hoje.month, hoje.day);
      
      // Prepara os dados de atualização com todos os campos necessários
      final updateData = {
        'numeroParcela': parcela.numeroParcela,
        'dataVencimento': parcela.dataVencimento?.toIso8601String().split('T')[0],
        'valor': parcela.valor,
        'status': 'PAGO',
        'dataPagamento': dataPagamento.toIso8601String().split('T')[0], // Apenas a data (yyyy-MM-dd)
        'contrato': parcela.contrato?.id, // Envia apenas o ID do contrato
      };

      final response = await service.put("parcela/${parcela.id}", updateData);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Atualiza a parcela na lista local sem recarregar tudo
        setState(() {
          final index = parcels.indexWhere((p) => p.id == parcela.id);
          if (index != -1) {
            parcels[index] = Parcela(
              id: parcela.id,
              contrato: parcela.contrato,
              numeroParcela: parcela.numeroParcela,
              dataVencimento: parcela.dataVencimento,
              valor: parcela.valor,
              dataPagamento: dataPagamento,
              status: StatusParcela.PAGO,
            );
            _filterByDate(); // Reaplica o filtro
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parcela marcada como paga!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorBody = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar parcela: ${response.statusCode}\n$errorBody'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar parcela: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getStatusLabel(StatusParcela? status) {
    switch (status) {
      case StatusParcela.PAGO:
        return 'Pago';
      case StatusParcela.PENDENTE:
        return 'Pendente';
      default:
        return 'N/A';
    }
  }

  Color _getStatusColor(StatusParcela? status) {
    switch (status) {
      case StatusParcela.PAGO:
        return Colors.green;
      case StatusParcela.PENDENTE:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parcelas"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _loadParcels,
        child: Column(
          children: [
            // Filtro de data
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Mês anterior',
                  ),
                  Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Text(
                        DateFormat('MMMM yyyy', 'pt_BR').format(selectedDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Próximo mês',
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text("Filtrar"),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Lista de parcelas
            Expanded(child: _buildBody()),
          ],
        ),
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
              onPressed: _loadParcels,
              child: const Text("Tentar novamente"),
            ),
          ],
        ),
      );
    }

    if (filteredParcels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Nenhuma parcela encontrada",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Para o mês selecionado",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredParcels.length,
      itemBuilder: (context, index) {
        final parcela = filteredParcels[index];
        final isPaid = parcela.status == StatusParcela.PAGO;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _getStatusColor(parcela.status).withOpacity(0.3),
              width: 1,
            ),
          ),
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
                          Row(
                            children: [
                              Text(
                                "Parcela ${parcela.numeroParcela ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (parcela.contrato?.unidade != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "• ${parcela.contrato!.unidade!.identificacao}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (parcela.contrato?.morador != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              parcela.contrato!.morador!.nome,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(parcela.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(parcela.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(parcela.status),
                        style: TextStyle(
                          color: _getStatusColor(parcela.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "Vencimento: ${_formatDate(parcela.dataVencimento)}",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (parcela.dataPagamento != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        "Pago em: ${_formatDate(parcela.dataPagamento)}",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payments, size: 20, color: Colors.grey[800]),
                        const SizedBox(width: 4),
                        Text(
                          "R\$ ${parcela.valor?.toStringAsFixed(2) ?? '0.00'}",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!isPaid)
                      ElevatedButton.icon(
                        onPressed: () => _markAsPaid(parcela),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Marcar como Pago"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
