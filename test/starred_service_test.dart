import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacescope/services/starred_service.dart';
import 'package:spacescope/models/nasa_image.dart';

void main() {
  late StarredService service;

  setUp(() {
    
    SharedPreferences.setMockInitialValues({});
    service = StarredService();
  });

  // ───────── TEST 1 ─────────
  test('Add starred item', () async {
    final image = NasaImage(
      title: 'Test',
      mediaType: 'image',
       previewUrl: 'test_url',
    );

    final added = await service.toggle(image);

    expect(added, true);

    final isStarred = await service.isStarred(image);
    expect(isStarred, true);
  });

  // ───────── TEST 2 ─────────
  test('Remove starred item', () async {
    final image = NasaImage(
      title: 'Test',
      mediaType: 'image',
       previewUrl: 'test_url',
    );

    await service.toggle(image); // add first
    await service.toggle(image); // remove

    final isStarred = await service.isStarred(image);
    expect(isStarred, false);
  });

  // ───────── TEST 3 ─────────
  test('Clear all starred items', () async {
    final image = NasaImage(
      title: 'Test',
      mediaType: 'image',
       previewUrl: 'test_url',
    );

    await service.toggle(image);

    await service.clearAll();

    final all = await service.getAll();
    expect(all.isEmpty, true);
  });
}