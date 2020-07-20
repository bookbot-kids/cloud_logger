import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  test('logging', () {
    var logService = LoggingService.shared;
    Map<String, dynamic> configs = {'env': 'prod', 'loggingLevel': 'debug'};
    logService.init(configs);
    var logger = logService.logger;
    logger.v("Verbose log");

    logger.d("Debug log");

    logger.i("Info log");

    logger.w("Warning log");

    logger.e("Error log");

    logger.wtf("What a terrible failure log");
    assert(true);
  });
}
