import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'quiz_api.dart';

class FileDownloadService {
  static final Dio _dio = Dio();

  // Pobieranie pliku PDF z nowymi parametrami
  static Future<String?> downloadPdf(
      String quizId, {
        required String quizName,
        int? questionCount,
        int variantsCount = 1,
        String layout = 'standard',
        bool includeAnswerKey = true,
        Function(int, int)? onProgress,
      }) async {
    try {
      final url = QuizApi.buildExportUrl(
        'pdf',
        quizId,
        questionCount: questionCount,
        variantsCount: variantsCount,
        layout: layout,
        includeAnswerKey: includeAnswerKey,
      );
      return await _downloadFile(
          url,
          generateFileName(
            quizName: quizName,
            variantsCount: variantsCount,
            layout: layout.toLowerCase(),
            extension: '.pdf',
          ),
          onProgress: onProgress);
    } catch (e) {
      throw Exception('Błąd pobierania PDF: $e');
    }
  }

  static String generateFileName({
    required String quizName,
    required int variantsCount,
    required String layout,
    required String extension,
  }) {
    final sanitizedName = sanitizeFileName(quizName);
    final timestamp = DateTime.now().toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('T', '_')
        .substring(0, 19);

    final variantsSuffix = variantsCount > 1 ? '_${variantsCount}var' : '';
    final layoutSuffix = layout.toLowerCase() != 'standard' ? '_$layout' : '';

    return '$sanitizedName$variantsSuffix${layoutSuffix}_$timestamp$extension';
  }

  static String sanitizeFileName(String fileName) {
    if (fileName.isEmpty) return 'Quiz';

    // Znaki niedozwolone w Windows/Download folder
    const invalidChars = r'\/:*?"<>|';
    final sanitized = fileName.split('').where((c) => !invalidChars.contains(c)).join();

    return sanitized.isEmpty ? 'Quiz' : sanitized.trim();
  }

  // Wewnętrzna metoda pobierania pliku
  static Future<String?> _downloadFile(
    String url,
    String fileName, {
    Function(int, int)? onProgress,
  }) async {
    try {
      // Sprawdź i poproś o uprawnienia
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Brak uprawnień do zapisu plików');
      }

      // Pobierz folder pobierania
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        throw Exception('Nie można uzyskać folderu pobierania');
      }

      final filePath = '${directory.path}/$fileName';

      // Pobierz plik
      final response = await _dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return filePath;
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Quiz nie został znaleziony');
        } else if (e.response?.statusCode == 500) {
          throw Exception('Błąd serwera podczas generowania pliku');
        } else {
          throw Exception('Błąd połączenia: ${e.message}');
        }
      }
      rethrow;
    }
  }

  // Sprawdź i poproś o uprawnienia
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) nie wymaga WRITE_EXTERNAL_STORAGE
      if (await _getAndroidVersion() >= 33) {
        return true;
      }
      
      // Android < 13 wymaga uprawnień do pamięci
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS nie wymaga specjalnych uprawnień dla Documents directory
      return true;
    }
    return true;
  }

  // Pobierz wersję Androida
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    
    // Możesz użyć device_info_plus package dla dokładnej wersji
    // Na razie zakładamy najnowszą wersję
    return 33;
  }

  // Pobierz odpowiedni folder dla platformy
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Android Downloads
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) return directory;
        return await getExternalStorageDirectory();
      }

      if (Platform.isIOS) {
        // iOS - brak public Downloads, użyj Documents
        return await getApplicationDocumentsDirectory();
      }

      if (Platform.isWindows) {
        // Windows Downloads
        final downloadsDir = await getDownloadsDirectory();
        return downloadsDir ?? Directory(r'C:\Users\$env:USERNAME\Downloads');
      }

      // if (Platform.isMacOS) {
      //   // macOS Downloads
      //   final downloadsDir = await getDownloadsDirectory();
      //   return downloadsDir ?? Directory('/Users/$env:USER/Downloads');
      // }
      //
      // if (Platform.isLinux) {
      //   // Linux Downloads
      //   final downloadsDir = await getDownloadsDirectory();
      //   return downloadsDir ?? Directory('/home/$env:USER/Downloads');
      // }

      // Fallback
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      print('Błąd folderu: $e');
      return await getTemporaryDirectory();
    }
  }

  // Otwórz plik w domyślnej aplikacji
  static Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Nie można otworzyć pliku: ${result.message}');
      }
    } catch (e) {
      throw Exception('Błąd otwierania pliku: $e');
    }
  }
}