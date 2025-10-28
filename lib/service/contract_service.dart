import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobilia/service/crud_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobilia/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ContractService extends CrudService {
  final Map<String, String>? defaultHeaders;
  ContractService({required super.baseUrl, this.defaultHeaders});

  Future<String> downloadPdfToCache(int contratoId) async {
    try {
      final url = Uri.parse('$apiBaseUrl/contrato/$contratoId/view');

      final headers = {'Accept': 'application/pdf', ...?defaultHeaders};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/contrato_$contratoId.pdf');
        await file.writeAsBytes(response.bodyBytes);

        return file.path;
      } else if (response.statusCode == 404) {
        throw Exception('PDF não encontrado');
      } else {
        throw Exception('Erro ao carregar PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar PDF: $e');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Android 13+ (API 33+) não precisa de permissão para Downloads
      if (androidInfo.version.sdkInt >= 33) {
        return true;
      }

      // Android 10-12 (API 29-32)
      if (androidInfo.version.sdkInt >= 29) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }

      // Android 9 e anterior (API 28-)
      final status = await Permission.storage.request();
      return status.isGranted;
    }

    return true; // iOS não precisa dessa permissão
  }

  Future<String> downloadPdfToDevice(int contratoId) async {
    try {
      // Solicita permissão
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Permissão de armazenamento negada');
      }

      final url = Uri.parse('$apiBaseUrl/contrato/$contratoId/download');

      final headers = {'Accept': 'application/pdf', ...?defaultHeaders};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        String filePath;

        if (Platform.isAndroid) {
          // Salva diretamente na pasta Downloads
          filePath = await _saveToDownloadsAndroid(
            contratoId,
            response.bodyBytes,
          );
        } else {
          // iOS: Salva no diretório de documentos do app
          final directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/contrato_$contratoId.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        }

        return filePath;
      } else if (response.statusCode == 404) {
        throw Exception('PDF não encontrado');
      } else {
        throw Exception('Erro ao baixar PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao baixar PDF: $e');
    }
  }

  Future<String> _saveToDownloadsAndroid(
    int contratoId,
    List<int> bytes,
  ) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    // Para Android 10+ (API 29+): usar diretório público de Downloads
    if (androidInfo.version.sdkInt >= 29) {
      // Caminho público da pasta Downloads
      final downloadsDir = Directory('/storage/emulated/0/Download');

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath = '${downloadsDir.path}/contrato_$contratoId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } else {
      // Para Android 9 e anterior: usar getExternalStorageDirectory
      final directory = await getExternalStorageDirectory();

      if (directory == null) {
        throw Exception('Não foi possível acessar o armazenamento externo');
      }

      // Navega até a pasta Downloads
      final downloadsPath = directory.path.replaceAll(
        RegExp(r'Android.*'),
        'Download',
      );
      final downloadsDir = Directory(downloadsPath);

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath = '${downloadsDir.path}/contrato_$contratoId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    }
  }

  Future<bool> checkPdfExists(int contratoId) async {
    try {
      final url = Uri.parse('$apiBaseUrl/contrato/$contratoId/view');

      final headers = {...?defaultHeaders};

      final response = await http.head(url, headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
