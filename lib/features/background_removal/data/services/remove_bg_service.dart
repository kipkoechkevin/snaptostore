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
    
    final response = await request.send();
    
    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final base64Image = base64Encode(bytes);
      
      return RemoveBgResponse(
        success: true,
        imageData: base64Image,
        metadata: {
          'original_size': file.lengthSync(),
          'processed_size': bytes.length,
          'format': format,
        },
      );
    } else {
      final errorResponse = await response.stream.bytesToString();
      final errorData = jsonDecode(errorResponse);
      
      return RemoveBgResponse(
        success: false,
        error: errorData['errors']?[0]?['title'] ?? 'Unknown error occurred',
      );
    }
  } catch (e) {
    return RemoveBgResponse(
      success: false,
      error: 'Failed to process image: $e',
    );
  }
}

Future<String> saveProcessedImage(String base64Image) async {
  try {
    final bytes = base64Decode(base64Image);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'processed_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = path.join(directory.path, fileName);
    
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    
    return filePath;
  } catch (e) {
    throw Exception('Failed to save processed image: $e');
  }
}
}