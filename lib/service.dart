library logging_service;

import 'package:logger/logger.dart';
import 'package:logging_service/outputs/azure_output.dart';
import 'package:logging_service/outputs/multiple_output.dart';

import 'logging_service.dart';

class LoggingService {
  LoggingService._privateConstructor();
  static LoggingService shared = LoggingService._privateConstructor();

  Logger logger;
  void init(Map config, {List<LogOutput> logOutputs}) {
    // Set log level, e.g. config['logLevel'] = 'debug'
    Logger.level =
        _enumFromString(Level.values, config['logLevel']) ?? Level.error;

    var outputs = List<LogOutput>();
    // alway log into console
    outputs.add(ConsoleOutput());

    // and log to cloud in production or staging
    if (config['env'] == 'prod' || config['env'] == 'stag') {
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
