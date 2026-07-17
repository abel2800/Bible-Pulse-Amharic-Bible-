import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_pulse/services/bible_brain_catalog_service.dart';

void main() {
  test('discovers audio filesets and applies download permissions', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = BibleBrainCatalogService(
      apiKey: 'test-key',
      preferences: preferences,
      client: MockClient((request) async {
        if (request.url.path.endsWith('/download/list')) {
          return http.Response(
            '{"data":[{"fileset_id":"AMHABC_N2DA"}]}',
            200,
          );
        }
        expect(request.url.path, endsWith('/bibles/AMHABC'));
        return http.Response(
          '{"data":{"filesets":{"AMHABC_N2DA":'
          '{"id":"AMHABC_N2DA","type":"audio",'
          '"segmentation_type":"chapter"}}}}',
          200,
        );
      }),
    );

    final filesets = await service.audioFilesets('AMHABC');

    expect(filesets, hasLength(1));
    expect(filesets.single.id, 'AMHABC_N2DA');
    expect(filesets.single.downloadPermitted, isTrue);
  });
}
