import 'dart:io';
import 'package:dashcam_sdk/src/log_util.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:wifi_ip_details/wifi_ip_details.dart';

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
}
