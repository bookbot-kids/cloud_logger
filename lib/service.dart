library logging_service;

import 'package:logger/logger.dart';
import 'package:logging_service/outputs/azure_output.dart';
import 'package:logging_service/outputs/multiple_output.dart';

import 'logging_service.dart';

class LoggingService {
  LoggingService._privateConstructor();

  /// singleton instance
  static LoggingService shared = LoggingService._privateConstructor();

  /// logger instance
  ///
  /// Usage: LoggingService.shared.logger.w("Warning log");
  Logger logger;

  /// Initialize the log service with [config]
  ///
  /// config['env']: logging environment
  ///
  /// config['logLevel']: logging level
  ///
  /// [logOutputs]: custom outputs
  void init(Map config, {List<LogOutput> logOutputs}) {
    // Set log level, e.g. config['logLevel'] = 'debug'
    Logger.level =
        _enumFromString(Level.values, config['logLevel']) ?? Level.error;

    var outputs = List<LogOutput>();

    if (config['env'] == null || config['env'] == 'dev') {
      // log into console for local
      outputs.add(ConsoleOutput());
    } else if (config['env'] == 'prod' || config['env'] == 'stag') {
      // and log to cloud in production or staging
      outputs.add(AzureOutput(config));
      outputs.add(FirebaseOutput(config));
    }

    logger = Logger(
        printer: PrettyPrinter(),
        output: MultipleOutput(logOutputs ?? outputs));
  }
}

T _enumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split(".").last == value,
      orElse: () => null);
}
