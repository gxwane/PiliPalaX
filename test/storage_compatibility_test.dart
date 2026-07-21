import 'dart:convert';
import 'dart:io';

import 'package:pilipalaz/models/model_owner.dart';
import 'package:pilipalaz/models/search/hot.dart';
import 'package:pilipalaz/models/user/info.dart';
import 'package:pilipalaz/utils/storage_contract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;

  setUp(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('pilipalax-hive-');
    Hive.init(hiveDirectory.path);
  });

  tearDown(() async {
    await Hive.close();
    if (await hiveDirectory.exists()) {
      await hiveDirectory.delete(recursive: true);
    }
  });

  test('v1.1.5 storage boxes keep their names and values', () async {
    final fixture =
        jsonDecode(
              await File('test/fixtures/v1_1_5_storage.json').readAsString(),
            )
            as Map<String, dynamic>;
    final boxValues = fixture['boxValues'] as Map<String, dynamic>;

    expect(StorageBoxName.values, boxValues.keys.toList());

    for (final name in StorageBoxName.values) {
      final box = await Hive.openBox<dynamic>(name);
      await box.putAll(boxValues[name] as Map<String, dynamic>);
    }

    await Hive.close();
    Hive.init(hiveDirectory.path);

    for (final name in StorageBoxName.values) {
      final box = await Hive.openBox<dynamic>(name);
      expect(box.toMap(), boxValues[name], reason: 'box $name changed');
    }
  });

  test('persisted Hive adapter type IDs stay stable', () {
    expect(OwnerAdapter().typeId, 3);
    expect(UserInfoDataAdapter().typeId, 4);
    expect(LevelInfoAdapter().typeId, 5);
    expect(HotSearchModelAdapter().typeId, 6);
    expect(HotSearchItemAdapter().typeId, 7);
  });
}
