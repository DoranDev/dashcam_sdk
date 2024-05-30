import 'dart:async';
import 'dart:io';
import 'package:dashcam_sdk/src/log_util.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:wifi_ip_details/wifi_ip_details.dart';
import 'package:network_info_plus/network_info_plus.dart';

abstract class WifiUtil {
  static openSetting() {
    if (Platform.isAndroid) {
      const OpenSettingsPlus.android()
          .sendCustomMessage("android.settings.WIFI_SETTINGS");
    } else if (Platform.isIOS) {
      const OpenSettingsPlus.iOS().sendCustomMessage('App-Prefs:WIFI');
    }
  }

  static Future<IPDetails?> info() async {
    IPDetails? ipDetails;
    try {
      ipDetails = await WifiIPDetails.getMyWIFIDetails();
    } catch (e) {
      LogUtil.debug(e);
    }
    return ipDetails;
  }

  static Future<Map> info2() async {
    Map details = {};
    await runZonedGuarded(() async {
      final info = NetworkInfo();
      final wifiName = await info.getWifiName(); // "FooNetwork"
      final wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
      final wifiIP = await info.getWifiIP(); // 192.168.1.43
      final wifiIPv6 =
          await info.getWifiIPv6(); // 2001:0db8:85a3:0000:0000:8a2e:0370:7334
      final wifiSubmask = await info.getWifiSubmask(); // 255.255.255.0
      final wifiBroadcast = await info.getWifiBroadcast(); // 192.168.1.255
      final wifiGateway = await info.getWifiGatewayIP(); // 192.168.1.1
      details["wifiName"] = wifiName;
      details["wifiBSSID"] = wifiBSSID;
      details["wifiIP"] = wifiIP;
      details["wifiIPv6"] = wifiIPv6;
      details["wifiSubmask"] = wifiSubmask;
      details["wifiBroadcast"] = wifiBroadcast;
      details["wifiGateway"] = wifiGateway;
    }, (error, stackTrace) {
      // Handle error within the zone
      LogUtil.debug("$error \n$stackTrace", name: "WifiUtil info");
    });
    return details;
  }
}
