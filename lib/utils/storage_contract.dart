abstract final class StoragePathName {
  static const String hive = 'hive';
  static const String cookie = '.plpl';
}

abstract final class StorageBoxName {
  static const String userInfo = 'userInfo';
  static const String localCache = 'localCache';
  static const String setting = 'setting';
  static const String historyWord = 'historyWord';
  static const String video = 'video';
  static const String onlineCache = 'onlineCache';

  static const List<String> values = <String>[
    userInfo,
    localCache,
    setting,
    historyWord,
    video,
    onlineCache,
  ];
}
