import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:logging_service/system_info.dart';
import 'package:sync_db/sync_db.dart';
import 'package:universal_io/io.dart';

/// Azure monitor output
class AzureMonitorOutput extends LogOutput {
  static const String _apiVersion = "2016-04-01";
  HTTP _http;
  String _sharedKey;
  String _customerId;
  String _logName;
  String _url;
  AzureMonitorOutput(Map config) {
    _url =
        "https://$_customerId.ods.opinsights.azure.com/api/logs?api-version=$_apiVersion";
    _http = HTTP(null, config);
  }

  @override
  void output(OutputEvent event) {
    var logContent = event.lines.join('');
    var map = SystemInfo.info;
    if (event.level == Level.error) {
      // logging for error
      map['errorLog'] = logContent;
    } else {
      // other log
      map['contentLog'] = logContent;
    }

    _sendLog(map).then((value) => null);
  }

  String _buildSignature(String message, String secret) {
    var keyByte = ascii.encode(secret);
    var base64Str = base64.encode(keyByte);
    keyByte = ascii.encode(base64Str);
    var messageBytes = ascii.encode(message);
    var hmacSha256 = new Hmac(sha256, keyByte);
    var hash = hmacSha256.convert(messageBytes);
    return base64.encode(hash.bytes);
  }

  Future<void> _sendLog(Map data) async {
    var now = HttpDate.format(await NetworkTime.shared.now);
    String jsonData = json.encode(data);
    var jsonBytes = utf8.encode(jsonData);
    String stringToHash = "POST\n" +
        jsonBytes.length.toString() +
        "\napplication/json\n" +
        "x-ms-date:" +
        now +
        "\n/api/logs";
    String hashedString = _buildSignature(stringToHash, _sharedKey);
    String signature = "SharedKey " + _customerId + ":" + hashedString;

    _http.headers = {
      "x-ms-date": now,
      "authorization": signature,
      "content-type": "application/json",
      "accept": "application/json",
      "x-ms-version": _apiVersion,
      "time-generated-field": "",
      "log-type": _logName
    };

    try {
      await _http.post(_url);
    } catch (e) {}
  }
}
