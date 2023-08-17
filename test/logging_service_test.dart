import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:cloud_logger/cloud_logger.dart';

void main() {
  test('logging', () async {
    Map<String, dynamic> config = {
      'env': 'prod',
      'loggingLevel': 'debug',
      'logLevel': 2,
      'customerId': 'WorkbookId',
      'logName': 'TestName',
      'sharedKey': 'WorkbookPrimaryKey'
    };

    var isLocalEnv = kDebugMode;
    var outputs = <LogOutput>[];
    if (isLocalEnv) {
      outputs.add(ConsoleOutput());
    } else {
      outputs.add(AzureMonitorOutput(config));
    }

    var logger = Logger(
        printer: isLocalEnv ? PrettyPrinter() : CloudPrinter(),
        output: MultipleOutput(outputs));

    logger.t("Verbose log");
    logger.d("Debug log");
    logger.i("Info log");
    logger.w("Warning log");
    logger.e("Error log");
    logger.f("What a terrible failure log");
    assert(true);
  });
}
