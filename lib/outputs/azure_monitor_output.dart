import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:logging_service/system_info.dart';
import 'package:sync_db/sync_db.dart';
import 'package:universal_io/io.dart';

/// Azure monitor output log. It will write log content into a map like:
///
/// ```
/// {"errorLog": "this is an error log"}
/// or
/// {"contentLog": "this is normal log"}
/// ```
class AzureMonitorOutput extends LogOutput {
  static const String _apiVersion = "2016-04-01";
  HTTP _http;
  String _sharedKey;
  String _customerId;
  String _logName;
  String _url;
  String _errorPropertyKey;
  String _propertyKey;

  /// Initialize the output with [azure monitor workbook] keys:
  ///
  /// [azure monitor workbook]: https://docs.microsoft.com/en-us/azure/azure-monitor/platform/workbooks-overview
  /// `customerId`: The analytic workbook id
  ///
  /// `sharedKey`: The primary key in workbook advance settings
  ///
  /// `logName`: The name of custom log in log analytic
  ///
  /// `errorPropertyKey`: The error log property key
  ///
  /// `propertyKey`: other log property key
  AzureMonitorOutput(Map config) {
    _customerId = config['customerId'];
    _sharedKey = config['sharedKey'];
    _logName = config['logName'];
    _errorPropertyKey = config['errorPropertyKey'] ?? 'errorLog';
    _propertyKey = config['propertyKey'] ?? 'contentLog';
    _logName = config['logName'];
    _url =
        "https://$_customerId.ods.opinsights.azure.com/api/logs?api-version=$_apiVersion";
    _http = HTTP(null, config);
  }

  @override
  void output(OutputEvent event) {
    // parse all log lines into json map
    var logContent = event.lines.join('');
    var map = SystemInfo.info;
    if (event.level == Level.error) {
      // logging for error
      map[_errorPropertyKey] = logContent;
    } else {
      // other log
      map[_propertyKey] = logContent;
    }

    sendLog(map).then((value) => null);
  }

  /// Generate authentication signature base on date and secret keys
  String _buildSignature(String message, String secret) {
    var keys = base64.decode(secret);
    var messageBytes = ascii.encode(message);
    var hmacSha256 = new Hmac(sha256, keys);
    var hash = hmacSha256.convert(messageBytes);
    return base64.encode(hash.bytes);
  }

  /// Send log to [azure monitor]
  ///
  /// [azure monitor]: https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-collector-api
  /// `data`: the json map data
  Future<void> sendLog(Map data) async {
    var datestring = HttpDate.format(await NetworkTime.shared.now);
    String jsonData = json.encode(data);
    var jsonBytes = utf8.encode(jsonData);
    String stringToHash = "POST\n" +
        jsonBytes.length.toString() +
        "\napplication/json\n" +
        "x-ms-date:" +
        datestring +
        "\n/api/logs";
    String hashedString = _buildSignature(stringToHash, _sharedKey);
    String signature = "SharedKey " + _customerId + ":" + hashedString;

    _http.headers = {
      "x-ms-date": datestring,
      "authorization": signature,
      "content-type": "application/json",
      "accept": "application/json",
      "x-ms-version": _apiVersion,
      "time-generated-field": "",
      "log-type": _logName
    };

    try {
      await _http.post(_url, data: jsonData);
    } catch (e) {
      print(e);
    }
  }
}
