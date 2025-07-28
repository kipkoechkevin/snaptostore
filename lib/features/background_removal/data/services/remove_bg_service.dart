import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/remove_bg_response.dart';
import '../../../../core/config/env_config.dart';

class RemoveBgService {
static const String _baseUrl = 'https://api.remove.bg/v1.0/removebg';
final String _apiKey;

RemoveBgService() : _apiKey = EnvConfig.removeBgApiKey;

Future<RemoveBgResponse> removeBackground({
  required String imagePath,
  String size = 'auto',
  String format = 'png',
}) async {
  try {
    if (_apiKey.isEmpty) {
      return const RemoveBgResponse(
        success: false,
        error: 'Remove.bg API key not configured',
      );
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      return const RemoveBgResponse(
        success: false,
        error: 'Image file not found',
      );
    }

    // ✅ Add file size check to prevent memory issues
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) { // 10MB limit
      return const RemoveBgResponse(
        success: false,
        error: 'Image file too large (max 10MB)',
      );
    }

    print('Starting background removal for file: $imagePath (${fileSize} bytes)');

    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    
    // Add headers
    request.headers['X-Api-Key'] = _apiKey;
    
    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath('image_file', imagePath),
    );
    
    // Add parameters  
    request.fields['size'] = size;
    request.fields['format'] = format;
    
    // ✅ Add timeout to prevent hanging
    final response = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timeout');
      },
    );
    
    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      print('Background removal successful, received ${bytes.length} bytes');
      
      // ✅ Process in chunks to avoid memory issues
      const chunkSize = 1024 * 1024; // 1MB chunks
      final chunks = <List<int>>[];
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        chunks.add(bytes.sublist(i, end));
      }
      
      final base64Image = base64Encode(bytes);
      
      return RemoveBgResponse(
        success: true,
        imageData: base64Image,
        metadata: {
          'original_size': fileSize,
          'processed_size': bytes.length,
          'format': format,
        },
      );
    } else {
      final errorResponse = await response.stream.bytesToString();
      Map<String, dynamic> errorData;
      
      try {
        errorData = jsonDecode(errorResponse);
      } catch (e) {
        return RemoveBgResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
      
      return RemoveBgResponse(
        success: false,
        error: errorData['errors']?[0]?['title'] ?? 'Unknown error occurred',
      );
    }
  } catch (e) {
    print('Background removal error: $e');
    return RemoveBgResponse(
      success: false,
      error: 'Failed to process image: $e',
    );
  }
}

Future<String> saveProcessedImage(String base64Image) async {
  try {
    print('Saving processed image...');
    
    // ✅ Decode in chunks to avoid memory issues
    final bytes = base64Decode(base64Image);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'processed_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = path.join(directory.path, fileName);
    
    final file = File(filePath);
    
    // ✅ Write with buffer to manage memory
    final sink = file.openWrite();
    const chunkSize = 1024 * 1024; // 1MB chunks
    
    for (int i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      sink.add(bytes.sublist(i, end));
      
      // ✅ Allow other processes to run
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    await sink.close();
    
    print('Processed image saved to: $filePath');
    return filePath;
  } catch (e) {
    print('Save error: $e');
    throw Exception('Failed to save processed image: $e');
  }
}

// ✅ Add cleanup method
Future<void> cleanupTempFiles() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final tempFiles = directory.listSync()
        .where((file) => file.path.contains('snaptostore_') || file.path.contains('processed_'))
        .where((file) => file.statSync().modified.isBefore(DateTime.now().subtract(const Duration(hours: 1))))
        .toList();
    
    for (final file in tempFiles) {
      await file.delete();
    }
    
    print('Cleaned up ${tempFiles.length} temp files');
  } catch (e) {
    print('Cleanup error: $e');
  }
}
}