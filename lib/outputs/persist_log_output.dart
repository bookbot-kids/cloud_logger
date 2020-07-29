import 'package:logger/logger.dart';
import 'package:logging_service/log_database.dart';
import 'package:sembast/sembast.dart';

/// An abstract output that can persist data
abstract class PersistLogOutput extends LogOutput {
  /// The log database instance, share to all output subclasses
  static LogDatabase _logDatabase = LogDatabase();

  /// Create or update log record by `map['id']`
  Future<void> save(Map map, String outputType) async {
    if (map['id'] == null) {
      throw ArgumentError('id is missing');
    }

    map['_logOutputType'] = outputType;
    await _logDatabase.save(map);
  }

  /// Delete log record
  Future<void> remove(String id) async {
    await _logDatabase.remove(id);
  }

  /// List all the logs for special output type, sort by `createdAt asc`
  Future<List> all(String type) async {
    var finder = Finder();
    finder.filter = Filter.equals('_logOutputType', type);
    finder.sortOrder = SortOrder('createdAt');
    return await _logDatabase.query(finder: finder);
  }
}
