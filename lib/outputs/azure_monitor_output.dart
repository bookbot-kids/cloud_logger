import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:cloud_logger/outputs/persist_log_output.dart';
import 'package:cloud_logger/system_app_info.dart';
import 'package:robust_http/robust_http.dart';
import 'package:universal_io/io.dart';
import 'package:uuid/uuid.dart';

/// Azure monitor output log. It will write log content into a map like:
///
/// ```
/// {"errorLog": "this is an error log"}
/// or
/// {"contentLog": "this is normal log"}
/// ```
class AzureMonitorOutput extends PersistLogOutput {
  static const String _azureApiVersion = "2016-04-01";
  HTTP _http;
  String _sharedKey;
  String _customerId;
  String _logName;
  String _url;

  /// Initialize the output with [azure monitor workbook] keys:
  ///
  /// [azure monitor workbook]: https://docs.microsoft.com/en-us/azure/azure-monitor/platform/workbooks-overview
  /// `customerId`: The analytic workbook id
  ///
  /// `sharedKey`: The primary key in workbook advance settings
  ///
  /// `logName`: The name of custom log in log analytic
  AzureMonitorOutput(Map config) {
    _customerId = config['customerId'];
    _sharedKey = config['sharedKey'];
    _logName = config['logName'];
    _url =
        "https://$_customerId.ods.opinsights.azure.com/api/logs?api-version=$_azureApiVersion";

    // Dont retry or log this api
    var customConfigs = Map<String, dynamic>.from(config);
    customConfigs['httpRetries'] = 1;
    customConfigs['logLevel'] = 'none';
    _http = HTTP(null, customConfigs);
  }

  /// An output method is called from [LogPrinter], which receive an [OutputEvent] when one of the log method is called, e.g `logger.v("Verbose log")`. More [Reference]
  ///
  /// [Reference]: https://github.com/leisim/logger/blob/master/lib/src/log_output.dart#L3
  @override
  void output(OutputEvent event) {
    if (event.lines == null || event.lines.isEmpty) {
      return;
    }

    // only send error and wtf log into azure
    if (event.level != Level.error && event.level != Level.wtf) {
      return;
    }

    SystemAppInfo.shared.information.then((map) async {
      try {
        // parse all log lines into string
        map['logContent'] = event.lines.join(' ');
        map['logName'] = event.lines.first;
        map['logType'] = event.level == Level.error ? 'error' : 'critical';
        // save to database before sending to azure monitor
        var id = Uuid().v4().toString();
        map['id'] = id;
        await save(map, 'AzureMonitor');
        var result = await sendLogToAzure(map);
        // then remove when send successfully
        if (result) {
          await remove(id);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  /// List all logs from database and send all into azure monitor
  Future<void> sendAllLogs() async {
    try {
      var list = await all('AzureMonitor');
      var tasks = List<Future>();
      list.forEach((item) {
        tasks.add(sendLog(item));
      });

      await Future.wait(tasks);
    } catch (e) {
      print(e);
    }
  }

  /// Send a log into azure monitor
  /// Must have `id` in the map
  Future<void> sendLog(Map map) async {
    try {
      var result = await sendLogToAzure(map);
      if (result) {
        await remove(map['id']);
      }
    } catch (e) {
      print(e);
    }
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
  /// `data`: the json map data. Notice that all the keys start with _ will not send to azure
  Future<bool> sendLogToAzure(Map data) async {
    try {
      // remove local fields
      data.removeWhere((key, value) => key.startsWith('_'));
      var datestring = HttpDate.format(DateTime.now());
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
        "x-ms-version": _azureApiVersion,
        "time-generated-field": "",
        "log-type": _logName
      };

      await _http.post(_url, data: jsonData);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
