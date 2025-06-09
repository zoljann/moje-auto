class EnvConfig {
  static const host = String.fromEnvironment('API_HOST', defaultValue: 'localhost');
  static const port = String.fromEnvironment('API_PORT', defaultValue: '5000');
  static const baseUrl = 'http://$host:$port';
}
