class AppConfig {
  // Local station IPs — must match Flask server config
  static const Map<String, String> computerIPs = {
    'PC1': 'http://192.168.1.101:5000',
    'PC2': 'http://192.168.1.102:5000',
    'PC3': 'http://192.168.1.103:5000',
    'PC4': 'http://192.168.1.104:5000',
  };
  // Fallback local address used when station detection fails
  static const String defaultLocalIP = 'http://192.168.1.101:5000';

  // TODO: replace with actual Supabase project credentials
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Brand identity
  static const String shopName = 'LAIDANI PHONE';
  static const String shopSlogan = 'طباعة سريعة واحترافية';

  // Pricing config — Algerian Dinar per page
  static const double priceBWPerPage = 10.0;
  static const double priceColorPerPage = 30.0;
  static const double priceA3Multiplier = 2.0;

  // Network timeouts and intervals
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration pollingInterval = Duration(seconds: 3);

  static const String appVersion = '1.0.0';
}
