import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';
import 'package:sembast/utils/value_utils.dart' as SembastUtils;

class LogDatabase {
  LogDatabase._privateConstructor();
  static LogDatabase shared = LogDatabase._privateConstructor();
  Database _database;
  Future<void> init() async {
    _database = await databaseFactory.openDatabase('log.db');
  }

  Future<void> save(Map map) async {
    var store = StoreRef.main();

    var id = map['id'];
    if (!(id is String && id.isNotEmpty)) {
      id = Uuid().v4().toString();
      map['createdAt'] = DateTime.now();
    }

    await store.record(id).put(_database, map);
  }

  Future<void> remove(String id) async {
    final store = StoreRef.main();
    if (await store.record(id).exists(_database)) {
      await store.record(id).delete(_database);
    }
  }

  Future<List> query({Finder finder}) async {
    final store = StoreRef.main();
    var results = List();
    var records = await store.find(_database, finder: finder ?? Finder());
    for (var record in records) {
      var value = SembastUtils.cloneValue(record.value);
      results.add(value);
    }

    return results;
  }

  DatabaseFactory get databaseFactory {
    if (UniversalPlatform.isWeb) {
      return databaseFactoryWeb;
    }

    return databaseFactoryIo;
  }
}
