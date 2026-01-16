// Stub file para PDFView na web (não usado, apenas para compilação)
import 'package:flutter/material.dart';

// Stubs vazios para evitar erros de compilação na web
class PDFView extends StatelessWidget {
  final String? filePath;
  final bool enableSwipe;
  final bool swipeHorizontal;
  final bool autoSpacing;
  final bool pageFling;
  final bool pageSnap;
  final int defaultPage;
  final dynamic fitPolicy;
  final bool preventLinkNavigation;
  final Function(int?)? onRender;
  final Function(dynamic)? onError;
  final Function(int, dynamic)? onPageError;
  final Function(dynamic)? onViewCreated;
  final Function(int?, int?)? onPageChanged;

  const PDFView({
    super.key,
    this.filePath,
    this.enableSwipe = true,
    this.swipeHorizontal = false,
    this.autoSpacing = true,
    this.pageFling = true,
    this.pageSnap = true,
    this.defaultPage = 0,
    this.fitPolicy,
    this.preventLinkNavigation = false,
    this.onRender,
    this.onError,
    this.onPageError,
    this.onViewCreated,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class PDFViewController {
  // Stub vazio
}

enum FitPolicy {
  BOTH,
  WIDTH,
  HEIGHT,
}

