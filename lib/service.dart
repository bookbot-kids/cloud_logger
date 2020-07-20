library logging_service;

import 'package:logger/logger.dart';
import 'package:logging_service/outputs/azure_output.dart';
import 'package:logging_service/outputs/multiple_output.dart';

import 'logging_service.dart';

class LoggingService {
  LoggingService._privateConstructor();
  static LoggingService shared = LoggingService._privateConstructor();

  Logger logger;
  void init(Map config, {LogOutput output}) {
    var outputs = List<LogOutput>();
    // alway log into console
    outputs.add(ConsoleOutput());

    if (config['env'] == 'prod') {
      outputs.add(AzureOutput(config));
      outputs.add(FirebaseOutput(config));
    }

    logger = Logger(printer: PrettyPrinter(), output: MultipleOutput(outputs));
  }
}
