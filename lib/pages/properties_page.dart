import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart' as domain;
import 'package:mobilia/pages/property.dart';
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/utils/utils.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  List<domain.Property> properties = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = PropertyService(baseUrl: apiBaseUrl);
      final response = await service.get("imovel");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          properties = data.map((e) => domain.Property.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Erro ao carregar imóveis (${response.statusCode})";
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
      MaterialPageRoute(builder: (context) => const Property()),
    );
    
    // Recarrega a lista quando volta da tela de cadastro
    if (result == true || result == null) {
      _loadProperties();
    }
  }

  Future<void> _deleteProperty(domain.Property property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: Text("Deseja realmente excluir o imóvel \"${property.nome}\"?\n\nEsta ação não pode ser desfeita."),
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

    if (confirm == true && property.id != null) {
      try {
        final service = PropertyService(baseUrl: apiBaseUrl);
        final endpoint = "imovel/${property.id}";
        debugPrint("Deletando imóvel - Endpoint: $endpoint, ID: ${property.id}");
        final response = await service.delete(endpoint);

        if (response.statusCode == 200 || response.statusCode == 204) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Imóvel excluído com sucesso!"),
                backgroundColor: Colors.green,
              ),
            );
            _loadProperties();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro ao excluir imóvel (${response.statusCode})"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao excluir imóvel: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Imóveis"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProperties,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text("Novo Imóvel"),
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
              onPressed: _loadProperties,
              child: const Text("Tentar novamente"),
            ),
          ],
        ),
      );
    }

    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Nenhum imóvel cadastrado",
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
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Property(
                    propertyToEdit: domain.Property(
                      id: property.id,
                      nome: property.nome,
                      cep: property.cep,
                      estado: property.estado,
                      cidade: property.cidade,
                      bairro: property.bairro,
                      rua: property.rua,
                      numero: property.numero,
                      complemento: property.complemento,
                      imagem: property.imagem,
                      ativo: property.ativo,
                      dtCadastro: property.dtCadastro,
                    ),
                  ),
                ),
              );
              if (result == true) {
                _loadProperties();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem do imóvel
                if (property.imagem != null && property.imagem!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      property.imagem!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              property.nome,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: property.ativo
                                      ? Colors.green[100]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  property.ativo ? "Ativo" : "Inativo",
                                  style: TextStyle(
                                    color: property.ativo
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
                                onPressed: () => _deleteProperty(property),
                                tooltip: "Excluir imóvel",
                              ),
                            ],
                          ),
                        ],
                      ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${property.rua}${property.numero != null ? ', ${property.numero}' : ''}",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.map, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "${property.bairro}, ${property.cidade} - ${property.estado}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (property.cep.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.markunread_mailbox, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "CEP: ${property.cep}",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
