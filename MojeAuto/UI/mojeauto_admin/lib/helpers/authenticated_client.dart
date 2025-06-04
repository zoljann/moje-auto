import 'package:http/http.dart' as http;
import 'token_manager.dart';

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = TokenManager().token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }
}

final httpClient = AuthenticatedClient();
