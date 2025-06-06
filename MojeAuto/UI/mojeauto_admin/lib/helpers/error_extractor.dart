import 'dart:convert';
import 'package:http/http.dart' as http;

String extractErrorMessage(http.Response response, {String fallback = "Došlo je do greške."}) {
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map) {
      if (decoded['errorMessage'] is String) return decoded['errorMessage'];
      if (decoded['error'] is String) return decoded['error'];
    }
  } catch (_) {}
  return fallback;
}
