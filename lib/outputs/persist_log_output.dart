import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
  Future<dynamic> save(Map map, String outputType) async {
    map['_logOutputType'] = outputType;
    var store = StoreRef.main();
    var id = map['id'];
    if (id == null || !(id is String && id.isNotEmpty)) {
      id = Uuid().v4().toString();
      map['id'] = id;
    }

    if (!map.containsKey('createdAt')) {
      map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
    }

    await store.record(id).put(await database, map);
    return map;
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
    var results = [];
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

  /// Get database path. On mobile it's in document folder, on web it's just in browser storage
  static Future<String> get _databasePath async {
    final dbName = 'log.db';
    if (UniversalPlatform.isWeb) {
      return dbName;
    }

    // return db path from application  document folder
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return join(dir.path, dbName);
  }

  /// Get the sembast database instance, init if needed
  static Future<Database> get database async {
    if (_database == null) {
      _database = await _databaseFactory.openDatabase(await _databasePath);
    }

    return _database;
  }
}
