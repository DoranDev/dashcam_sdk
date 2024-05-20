import 'package:dashcam_sdk/src/log_util.dart';
import 'package:intl/intl.dart';

class DashCamCameraCommand {
  static const int wifiApStateEnabled = 13;
  static const String cgiPath = "/cgi-bin/Config.cgi";
  static const String actionSet = "set";
  static const String actionGet = "get";
  static const String actionDel = "del";
  static const String actionPlay = "play";
  static const String actionSetCamId = "setcamid";

  static const String propertyNet = "Net";
  static const String propertySsid = "Net.WIFI_AP.SSID";
  static const String propertyEncryptionKey = "Net.WIFI_AP.CryptoKey";
  static const String propertyHeartbeat = "Playback";
  static const String propertyHotspotSsid = "Net.WIFI_STA.AP.2.SSID";
  static const String propertyHotspotEncryptionKey =
      "Net.WIFI_STA.AP.2.CryptoKey";
  static const String propertyHotspotEnable = "Net.Dev.1.Type";

  static const String commandWifiApMode = "AP";
  static const String commandWifiStaMode = "STA";
  static const String commandWifiModeSwEnable = "Net.WIFI_STA.AP.Switch";

  static const String propertyTimestampYear =
      "Camera.Preview.MJPEG.TimeStamp.year";
  static const String propertyTimestampMonth =
      "Camera.Preview.MJPEG.TimeStamp.month";
  static const String propertyTimestampDay =
      "Camera.Preview.MJPEG.TimeStamp.day";
  static const String propertyTimestamp = "Camera.Preview.MJPEG.TimeStamp.*";
  static const String propertyRtspAv = "Camera.Preview.RTSP.av";
  static const String propertyRecordStatus = "Camera.Record.*";
  static const String propertyCameraStatus = "Camera.Preview.MJPEG.status.*";

  static const String propertyVideo = "Videores";
  static const String propertyImage = "Imageres";
  static const String propertyEv = "Exposure";
  static const String propertyMtd = "MTD";
  static const String propertyFileStreaming = "DCIM\$100__DSC\$";

  static const String commandFindCamera = "findme";
  static const String commandReset = "reset";
  static const String commandMovieRes = "720P60fps";
  static const String commandImageRes = "5M";
  static const String commandVideoRecord = "record";
  static const String commandVideoCapture = "capture";
  static const String propertyVideoRecord = "Video";
  static const String commandShortRec = "rec_short";
  static const String commandHb = "heartbeat";

  static const String commandEv = "EV0";
  static const String commandMtd = "Off";
  static const String propertyFlicker = "Flicker";
  static const String commandFlicker = "50Hz";
  static const String propertyAwb = "AWB";
  static const String commandAwb = "Auto";
  static const String propertyDeleteFiles = "\$DCIM\$*";
  static const String propertyDefaultValue = "Camera.Menu.*";
  static const String propertyCameraPreview = "Camera.Preview.*";
  static const String commandTimeString = "2014/01/01 00:00:00";
  static const String commandFileStreaming = "";

  static const String propertyCameraSrc = "Camera.Preview.Source.1.Camid";
  static const String commandCameraFront = "front";
  static const String commandCameraRear = "rear";

  static const String propertySetAdasHeight = "Camera.Preview.Adas.Height";
  static const String propertySetAdasYOne = "Camera.Preview.Adas.Yone";
  static const String propertySetAdasYTwo = "Camera.Preview.Adas.Ytwo";
  static const String propertySetAdasSave = "Camera.Preview.Adas.SaveData";
  static const String propertyGetAdasVal = "Camera.Preview.Adas.*";

  static const String propertyEnterPlayback = "Playback";
  static const String propertySetPowerOff = "Camera.System.Power";
  static const String commandCameraPower = "Off";

  static String? ipAddress;

  static setIpAddress(String ip) async {
    ipAddress = ip;
  }

  static String? getIpAddress() {
    return ipAddress;
  }

  static String buildArgument(String property, [String? value]) {
    try {
      return "property=$property&value=${Uri.encodeComponent(value ?? '')}";
    } catch (e) {
      LogUtil.debug(e);
      return "";
    }
  }

  static String buildArgumentList(List<String?> arguments) {
    String argumentList = "";
    for (String? argument in arguments) {
      if (argument != null) {
        argumentList += "&$argument";
      }
    }
    return argumentList;
  }

  static Future<Uri?> buildRequestUrl(
      String path, String action, String argumentList) async {
    try {
      String? ip = ipAddress;
      if (ip != null) {
        return Uri.parse("http://$ip$path?action=$action$argumentList");
      }
    } catch (e) {
      LogUtil.debug(e);
    }
    return null;
  }

  static Future<Uri?> commandUpdateUrl(
      String ssid, String encryptionKey) async {
    List<String> arguments = [
      buildArgument(propertySsid, ssid),
      buildArgument(propertyEncryptionKey, encryptionKey)
    ];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandHotspotUpdateUrl(
      String ssid, String encryptionKey) async {
    List<String> arguments = [
      buildArgument(propertyHotspotSsid, ssid),
      buildArgument(propertyHotspotEncryptionKey, encryptionKey)
    ];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandHotspotEnableUrl(String ssid) async {
    List<String> arguments = [buildArgument(propertyHotspotEnable, ssid)];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandFindCameraUrl() async {
    List<String> arguments = [buildArgument(propertyNet, commandFindCamera)];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandCameraRecordUrl() async {
    List<String> arguments = [
      buildArgument(propertyVideoRecord, commandVideoRecord)
    ];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandCameraStatusUrl() async {
    List<String> arguments = [buildArgument(propertyCameraStatus)];
    return buildRequestUrl(cgiPath, actionGet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandCameraTimeSettingsUrl() async {
    List<String> arguments = [
      buildArgument("TimeSettings",
          DateFormat("yyyy\$MM\$dd\$HH\$mm\$ss\$").format(DateTime.now()))
    ];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandCameraSnapshotUrl() async {
    List<String> arguments = [
      buildArgument(propertyVideoRecord, commandVideoCapture)
    ];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandCameraSwitchToFrontUrl() async {
    List<String> arguments = [
      buildArgument(propertyCameraSrc, commandCameraFront)
    ];
    return buildRequestUrl(
        cgiPath, actionSetCamId, buildArgumentList(arguments));
  }

  static Future<Uri?> commandHeartbeatUrl() async {
    List<String> arguments = [buildArgument(propertyHeartbeat, commandHb)];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandSetAdasHeightUrl() async {
    List<String> arguments = [buildArgument(propertySetAdasHeight, "0")];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandGetAdasHeightUrl() async {
    List<String> arguments = [buildArgument(propertyGetAdasVal)];
    return buildRequestUrl(cgiPath, actionGet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandSetAdasSaveUrl() async {
    List<String> arguments = [buildArgument(propertySetAdasSave, "1")];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandGetAdasSaveUrl() async {
    List<String> arguments = [buildArgument(propertyGetAdasVal)];
    return buildRequestUrl(cgiPath, actionGet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandGetAdasUrl() async {
    List<String> arguments = [buildArgument(propertyGetAdasVal)];
    return buildRequestUrl(cgiPath, actionGet, buildArgumentList(arguments));
  }

  static Future<Uri?> commandCameraPowerOffUrl() async {
    List<String> arguments = [
      buildArgument(propertySetPowerOff, commandCameraPower)
    ];
    return buildRequestUrl(cgiPath, actionSet, buildArgumentList(arguments));
  }
}
