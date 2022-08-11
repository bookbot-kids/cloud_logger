import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:singleton/singleton.dart';
import 'package:universal_platform/universal_platform.dart';

/// This class uses to collection all system device
/// and app information into the log
class SystemAppInfo {
  factory SystemAppInfo() =>
      Singleton.lazy(() => SystemAppInfo._privateConstructor());
  SystemAppInfo._privateConstructor();
  static SystemAppInfo shared = SystemAppInfo();

  Map<String, dynamic>? _information;

  /// Return the system information properties
  Future<Map<String, dynamic>> get information async {
    if (_information == null) {
      _information = Map();
      _information?.addAll(await collectSystemInfo());
      _information?.addAll(await collectAppInfo());
    }

    return _information ?? {};
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
    final plugin = DeviceInfoPlugin();
    const _androidIdPlugin = AndroidId();
    if (UniversalPlatform.isAndroid) {
      final androidId = await _androidIdPlugin.getId();
      return _collectAndroidInfo(await plugin.androidInfo, androidId);
    } else if (UniversalPlatform.isIOS) {
      return _collectIosInfo(await plugin.iosInfo);
    } else if (UniversalPlatform.isWeb) {
      final webBrowserInfo = await plugin.webBrowserInfo;
      return _collectWebInfo(webBrowserInfo);
    } else if (UniversalPlatform.isWindows) {
      final windowsInfo = await plugin.windowsInfo;
      return _collectWindowsInfo(windowsInfo);
    } else if (UniversalPlatform.isMacOS) {
      final macosInfo = await plugin.macOsInfo;
      return _collectMacOSInfo(macosInfo);
    } else if (UniversalPlatform.isLinux) {
      final linuxInfo = await plugin.linuxInfo;
      return _collectLinuxInfo(linuxInfo);
    }

    return Map<String, dynamic>();
  }

  Map<String, dynamic> _collectWebInfo(WebBrowserInfo webBrowserInfo) {
    return <String, dynamic>{
      'deviceMemory': webBrowserInfo.deviceMemory,
      'hardwareConcurrency': webBrowserInfo.hardwareConcurrency,
      'product': webBrowserInfo.product,
      'browserName': webBrowserInfo.browserName.name,
      'userAgent': webBrowserInfo.userAgent,
      'language': webBrowserInfo.language,
      'maxTouchPoints': webBrowserInfo.maxTouchPoints,
      'appCodeName': webBrowserInfo.appCodeName,
      'appName': webBrowserInfo.appName,
    };
  }

  Map<String, dynamic> _collectMacOSInfo(MacOsDeviceInfo macosInfo) {
    return <String, dynamic>{
      'computerName': macosInfo.computerName,
      'model': macosInfo.model,
      'activeCPUs': macosInfo.activeCPUs,
      'arch': macosInfo.arch,
      'cpuFrequency': macosInfo.cpuFrequency,
      'hostName': macosInfo.hostName,
      'kernelVersion': macosInfo.kernelVersion,
      'memorySize': macosInfo.memorySize,
      'osRelease': macosInfo.osRelease,
      'systemGUID': macosInfo.systemGUID,
    };
  }

  Map<String, dynamic> _collectWindowsInfo(WindowsDeviceInfo windowsInfo) {
    return <String, dynamic>{
      'computerName': windowsInfo.computerName,
      'numberOfCores': windowsInfo.numberOfCores,
      'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
    };
  }

  Map<String, dynamic> _collectLinuxInfo(LinuxDeviceInfo linuxInfo) {
    return <String, dynamic>{
      'deviceId': linuxInfo.id,
      'buildId': linuxInfo.buildId,
      'idLike': linuxInfo.idLike,
      'machineId': linuxInfo.machineId,
      'name': linuxInfo.name,
      'prettyName': linuxInfo.prettyName,
      'variant': linuxInfo.variant,
      'variantId': linuxInfo.variantId,
      'version': linuxInfo.version,
      'versionCodename': linuxInfo.versionCodename,
      'versionId': linuxInfo.versionId,
    };
  }

  Map<String, dynamic> _collectAndroidInfo(AndroidDeviceInfo build,
      String? androidId) {
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
      'build.id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': androidId,
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
