import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_admin/env_config.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _token;
  String? _refreshToken;
  Timer? _refreshTimer;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _refreshToken = prefs.getString('refresh_token');
    if (_token != null) _scheduleRefresh();
  }

  String? get token => _token;

  Future<void> saveTokens(
    String token,
    String refreshToken, [
    Map<String, dynamic>? user,
  ]) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('jwt_token', token);
    await prefs.setString('refresh_token', refreshToken);
    _token = token;
    _refreshToken = refreshToken;

    if (user != null) {
      await prefs.setInt('user_id', user['userId']);
      await prefs.setString('user_firstName', user['firstName']);
      await prefs.setString('user_lastName', user['lastName']);
    }

    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    final payload = _parseJwtPayload(_token!);
    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    final duration = expiry
        .subtract(const Duration(seconds: 50))
        .difference(DateTime.now());

    _refreshTimer?.cancel();
    if (duration.isNegative) {
      _refreshTokenIfNeeded();
    } else {
      _refreshTimer = Timer(duration, _refreshTokenIfNeeded);
    }
  }

  Future<void> _refreshTokenIfNeeded() async {
    if (_refreshToken == null) return;

    final response = await http.post(
      Uri.parse("${EnvConfig.baseUrl}/login/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(_refreshToken),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['token'], data['refreshToken']);
    }
  }

  Map<String, dynamic> _parseJwtPayload(String token) {
    final payloadBase64 = base64Url.normalize(token.split('.')[1]);
    final payloadString = utf8.decode(base64Url.decode(payloadBase64));
    return jsonDecode(payloadString);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('user_firstName');
    await prefs.remove('user_lastName');
    _token = null;
    _refreshToken = null;
    _refreshTimer?.cancel();
  }

  Future<int?> get userId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<String?> get userFirstName async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_firstName');
  }

  Future<String?> get userLastName async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_lastName');
  }
}
