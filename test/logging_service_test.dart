import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  test('logging', () {
    Map<String, dynamic> config = {'env': 'prod', 'loggingLevel': 'debug'};
    var isLocalEnv = true;
    var outputs = List<LogOutput>();
    if (isLocalEnv) {
      outputs.add(ConsoleOutput());
    } else {
      outputs.add(AzureMonitorOutput(config));
    }

    var logger = Logger(
        printer: isLocalEnv ? PrettyPrinter() : CloudPrinter(),
        output: MultipleOutput(outputs));

    logger.v("Verbose log");
    logger.d("Debug log");
    logger.i("Info log");
    logger.w("Warning log");
    logger.e("Error log");
    logger.wtf("What a terrible failure log");
    assert(true);
  });
}
