import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swms_mobile/core/config/app_config.dart';

void main() {
  test('loads and normalizes API URL from environment', () {
    dotenv.loadFromString(
      envString: 'PRODUCTION_API_URL=https://api.example.test/api/v1/\nGOOGLE_MAPS_API_KEY=restricted-key',
    );

    final config = AppConfig.fromEnvironment();

    expect(config.apiBaseUrl, 'https://api.example.test/api/v1');
    expect(config.googleMapsApiKey, 'restricted-key');
  });

  test('rejects API URLs that do not include the versioned API path', () {
    dotenv.loadFromString(
      envString: 'PRODUCTION_API_URL=https://api.example.test',
    );

    expect(AppConfig.fromEnvironment, throwsStateError);
  });
}
