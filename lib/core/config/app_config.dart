import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.googleMapsApiKey});

  final String apiBaseUrl;
  final String googleMapsApiKey;

  factory AppConfig.fromEnvironment() {
    final apiBaseUrl = (dotenv.env['PRODUCTION_API_URL']?.trim() ?? '')
        .replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty ||
        !uri.path.endsWith('/api/v1')) {
      throw StateError(
        'PRODUCTION_API_URL is missing or invalid in .env. '
        'It must be an HTTP(S) URL ending in /api/v1.',
      );
    }

    return AppConfig(
      apiBaseUrl: apiBaseUrl,
      googleMapsApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? '',
    );
  }
}
