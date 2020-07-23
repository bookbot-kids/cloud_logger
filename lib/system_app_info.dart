import 'package:device_info/device_info.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:universal_html/html.dart' as html;
import 'package:package_info/package_info.dart';

/// This class uses to collection all system device
/// and app information into the log
class SystemAppInfo {
  SystemAppInfo._privateConstructor();
  static SystemAppInfo shared = SystemAppInfo._privateConstructor();

  Map<String, dynamic> _information;

  /// Return the system information properties
  Future<Map<String, dynamic>> get information async {
    if (_information == null) {
      _information = Map();
      _information.addAll(await collectSystemInfo());
      _information.addAll(await collectAppInfo());
    }

    return _information;
  }

  /// Collect app build version info. Only work for android & ios
  Future<Map<String, dynamic>> collectAppInfo() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return <String, dynamic>{
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    }

    return Map<String, dynamic>();
  }

  /// Collect all system info for each platform and write into a map
  Future<Map<String, dynamic>> collectSystemInfo() async {
    if (UniversalPlatform.isAndroid) {
      var plugin = DeviceInfoPlugin();
      return _collectAndroidInfo(await plugin.androidInfo);
    } else if (UniversalPlatform.isIOS) {
      var plugin = DeviceInfoPlugin();
      return _collectIosInfo(await plugin.iosInfo);
    } else if (UniversalPlatform.isWeb) {
      return <String, dynamic>{'userAgent': html.window.navigator.userAgent};
    } else if (UniversalPlatform.isWindows) {
      // TODO check later
    } else if (UniversalPlatform.isMacOS) {
      // TODO check later
    }

    return Map<String, dynamic>();
  }

  Map<String, dynamic> _collectAndroidInfo(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _collectIosInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
