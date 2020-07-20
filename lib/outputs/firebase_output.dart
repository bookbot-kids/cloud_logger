import 'package:logger/logger.dart';

/// Firebase cloud output
class FirebaseOutput extends LogOutput {
  final Map config;

  FirebaseOutput(this.config);
  @override
  void output(OutputEvent event) {
    if (event.level == Level.error) {
      // logging to crashlytics
    } else {
      // other log
    }
  }
}
