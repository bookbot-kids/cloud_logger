import 'package:logger/logger.dart';

/// Azure monitor output
class AzureOutput extends LogOutput {
  final Map config;

  AzureOutput(this.config);
  @override
  void output(OutputEvent event) {
    if (event.level == Level.error) {
      // logging for error
    } else {
      // other log
    }
  }
}
