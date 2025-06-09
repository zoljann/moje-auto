class EnvConfig {
  static const host = String.fromEnvironment('API_HOST', defaultValue: '10.0.2.2');
  static const port = String.fromEnvironment('API_PORT', defaultValue: '5000');
  static const baseUrl = 'http://$host:$port';

  static const stripePublicKey = String.fromEnvironment('STRIPE_PUBLIC_KEY', defaultValue: '');
}
