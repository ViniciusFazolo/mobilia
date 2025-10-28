// lib/views/contract_pdf_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mobilia/domain/contract.dart';
import 'package:mobilia/service/contract_service.dart';
import 'package:mobilia/utils/utils.dart';

class ContractPdfView extends StatefulWidget {
  final Contrato contrato;

  const ContractPdfView({super.key, required this.contrato});

  @override
  State<ContractPdfView> createState() => _ContractPdfViewState();
}

class _ContractPdfViewState extends State<ContractPdfView> {
  final ContractService _pdfService = ContractService(baseUrl: apiBaseUrl);
  String? pdfPath;
  bool isLoading = true;
  bool isDownloading = false;
  String? error;
  int currentPage = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final path = await _pdfService.downloadPdfToCache(widget.contrato.id!);
      setState(() {
        pdfPath = path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    setState(() {
      isDownloading = true;
    });

    try {
      final filePath = await _pdfService.downloadPdfToDevice(
        widget.contrato.id!,
      );

      if (mounted) {
        // Extrai apenas o nome do arquivo do caminho completo
        final fileName = filePath.split('/').last;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✓ PDF baixado com sucesso!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Localização:'),
                Text(
                  'Pasta Downloads > $fileName',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contrato PDF', style: TextStyle(fontSize: 18)),
            if (totalPages > 0)
              Text(
                'Página ${currentPage + 1} de $totalPages',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (!isLoading && pdfPath != null)
            IconButton(
              icon: isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              onPressed: isDownloading ? null : _downloadPdf,
              tooltip: 'Baixar PDF',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPdf,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando PDF...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar PDF',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (pdfPath == null) {
      return const Center(child: Text('PDF não disponível'));
    }

    return PDFView(
      filePath: pdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        setState(() {
          totalPages = pages ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          this.error = error.toString();
        });
      },
      onPageError: (page, error) {
        setState(() {
          this.error = 'Erro na página $page: $error';
        });
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // Você pode salvar o controller se precisar controlar o PDF
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          currentPage = page ?? 0;
        });
      },
    );
  }
}
