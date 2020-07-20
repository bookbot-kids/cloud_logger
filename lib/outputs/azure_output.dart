import 'package:logger/logger.dart';

class AzureOutput extends LogOutput {
  final Map config;

  AzureOutput(this.config);
  @override
  void output(OutputEvent event) {}
}
