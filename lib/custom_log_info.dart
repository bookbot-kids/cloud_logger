import 'package:singleton/singleton.dart';

/// Custom information to send to the log output
class CustomLogInfo {
  factory CustomLogInfo() =>
      Singleton.lazy(() => CustomLogInfo._privateConstructor());
  CustomLogInfo._privateConstructor();
  static CustomLogInfo shared = CustomLogInfo();

  Map<String, dynamic> information = {};
}
