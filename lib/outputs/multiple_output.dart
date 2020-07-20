import 'package:logger/logger.dart';

class MultipleOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultipleOutput(this.outputs);
  @override
  void output(OutputEvent event) {
    outputs.forEach((output) {
      output.output(event);
    });
  }
}
