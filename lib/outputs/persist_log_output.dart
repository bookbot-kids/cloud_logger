import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';
import 'package:sembast/utils/value_utils.dart' as SembastUtils;

/// An abstract output that can persist data
abstract class PersistLogOutput extends LogOutput {
  /// Sembast database instance
  static Database _database;

  /// Create or update log record by `map['id']`
  Future<void> save(Map map, String outputType) async {
    if (map['id'] == null) {
      throw ArgumentError('id is missing');
    }

    map['_logOutputType'] = outputType;
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

  /// Delete log record
  Future<void> remove(String id) async {
    final store = StoreRef.main();
    if (await store.record(id).exists(await database)) {
      await store.record(id).delete(await database);
    }
  }

  /// List all the logs for special output type, sort by `createdAt asc`
  Future<List> all(String type) async {
    var finder = Finder();
    finder.filter = Filter.equals('_logOutputType', type);
    finder.sortOrder = SortOrder('createdAt');
    final store = StoreRef.main();
    var results = List();
    var records = await store.find(await database, finder: finder);
    for (var record in records) {
      var value = SembastUtils.cloneValue(record.value);
      results.add(value);
    }

    return results;
  }

  /// Sembast database factory, uses to init database from a path. It has difference factory for web or other platform
  static DatabaseFactory get _databaseFactory {
    return UniversalPlatform.isWeb ? databaseFactoryWeb : databaseFactoryIo;
  }

  /// Get the sembast database instance, init if needed
  static Future<Database> get database async {
    if (_database == null) {
      _database = await _databaseFactory.openDatabase('log.db');
    }

    return _database;
  }
}
