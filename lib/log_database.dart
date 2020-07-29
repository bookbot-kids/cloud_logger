import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';
import 'package:sembast/utils/value_utils.dart' as SembastUtils;

/// A log database class to manage log caches. All the logs must be saved here before sending to the cloud.
class LogDatabase {
  /// Sembast database instance
  Database _database;

  /// Sembast database factory, uses to init database from a path. It has difference factory for web or other platform
  DatabaseFactory get databaseFactory {
    if (UniversalPlatform.isWeb) {
      return databaseFactoryWeb;
    }

    return databaseFactoryIo;
  }

  /// Get the sembast database instance, init if needed
  Future<Database> get database async {
    if (_database == null) {
      _database = await databaseFactory.openDatabase('log.db');
    }

    return database;
  }

  /// Create or update a record into database
  ///
  /// Create record if `map` doesn't contain `id`
  Future<void> save(Map map) async {
    var store = StoreRef.main();

    var id = map['id'];
    if (!(id is String && id.isNotEmpty)) {
      id = Uuid().v4().toString();
    }

    if (!map.containsKey('createdAt')) {
      map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
    }

    await store.record(id).put(await database, map);
  }

  /// Remove a record from database by `id`
  Future<void> remove(String id) async {
    final store = StoreRef.main();
    if (await store.record(id).exists(await database)) {
      await store.record(id).delete(await database);
    }
  }

  /// Query data from database
  ///
  /// `finder`: the sembast query parameters
  Future<List> query({Finder finder}) async {
    final store = StoreRef.main();
    var results = List();
    var records = await store.find(await database, finder: finder ?? Finder());
    for (var record in records) {
      var value = SembastUtils.cloneValue(record.value);
      results.add(value);
    }

    return results;
  }
}
