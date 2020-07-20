import 'package:logger/logger.dart';

class FirebaseOutput extends LogOutput {
  final Map config;

  FirebaseOutput(this.config);
  @override
  void output(OutputEvent event) {}
}
