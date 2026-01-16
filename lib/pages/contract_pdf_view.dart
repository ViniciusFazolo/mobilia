// lib/views/contract_pdf_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobilia/domain/contract.dart';
import 'package:mobilia/service/contract_service.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:mobilia/utils/prefs.dart';

// Import condicional para HTML (apenas na web)
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';

// Import condicional para PDFView (apenas em mobile)
import 'package:flutter_pdfview/flutter_pdfview.dart' if (dart.library.html) 'package:mobilia/pages/contract_pdf_view_stub.dart';

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
      if (kIsWeb) {
        // Na web, cria um blob URL com o PDF baixado com token
        final url = Uri.parse('$apiBaseUrl/contrato/${widget.contrato.id!}/view');
        final token = await Prefs.getString("token");
        
        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/pdf',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          // Cria um blob URL para exibir o PDF com o tipo MIME correto
          final blob = html.Blob([response.bodyBytes], 'application/pdf');
          final urlBlob = html.Url.createObjectUrlFromBlob(blob);
          setState(() {
            pdfPath = urlBlob;
            isLoading = false;
          });
        } else {
          throw Exception('Erro ao carregar PDF: ${response.statusCode}');
        }
      } else {
        final path = await _pdfService.downloadPdfToCache(widget.contrato.id!);
        setState(() {
          pdfPath = path;
          isLoading = false;
        });
      }
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
        if (kIsWeb) {
          // Na web, faz o download via fetch com token
          await _downloadPdfWeb(widget.contrato.id!);
        } else {
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

    // Na web, abre o PDF em uma nova aba (iframe não funciona por causa de X-Frame-Options)
    if (kIsWeb) {
      return _WebPdfViewer(pdfUrl: pdfPath!);
    }

    // Em mobile, usa o PDFView (só compila em mobile)
    return _buildMobilePdfView();
  }

  Widget _buildMobilePdfView() {
    // Este método só é chamado quando não é web, então PDFView está disponível
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
      onViewCreated: (dynamic pdfViewController) {
        // Você pode salvar o controller se precisar controlar o PDF
        // Na web, este código não é executado, então usar dynamic é seguro
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          currentPage = page ?? 0;
        });
      },
    );
  }

  Future<void> _downloadPdfWeb(int contratoId) async {
    if (!kIsWeb) return;
    
    try {
      final url = Uri.parse('$apiBaseUrl/contrato/$contratoId/download');
      final token = await Prefs.getString("token");
      
      // Faz a requisição com o token no header
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/pdf',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Cria um blob URL e faz o download com o tipo MIME correto
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final urlBlob = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement()
          ..href = urlBlob
          ..setAttribute('download', 'contrato_$contratoId.pdf')
          ..click();
        html.Url.revokeObjectUrl(urlBlob);
      } else {
        throw Exception('Erro ao baixar PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// Widget para exibir PDF na web usando iframe com blob URL
class _WebPdfViewer extends StatefulWidget {
  final String pdfUrl;

  const _WebPdfViewer({required this.pdfUrl});

  @override
  State<_WebPdfViewer> createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<_WebPdfViewer> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerIframe();
    }
  }

  void _registerIframe() {
    // Cria um iframe HTML com o blob URL
    // Blob URLs são locais e não são bloqueados por X-Frame-Options
    final viewId = 'pdf-iframe-${widget.pdfUrl.hashCode}';
    
    final iframe = html.IFrameElement()
      ..src = widget.pdfUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('type', 'application/pdf');

    // Registra o iframe como um widget Flutter
    // Nota: Se já foi registrado, será sobrescrito (isso é OK)
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Garante que o iframe foi registrado antes de usar
      final viewId = 'pdf-iframe-${widget.pdfUrl.hashCode}';
      
      return SizedBox.expand(
        child: HtmlElementView(
          viewType: viewId,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
