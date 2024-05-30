import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'camera_peeker.dart';

class CameraSniffer {
  final String listenIP = '0.0.0.0';
  final int port = 49142;
  RawDatagramSocket? socket;
  Uint8List buffer = Uint8List(4096);
  CameraPeeker? thePeeker;
  int ticket = -1;
  int utime = -1;
  bool alive = true;
  static const int wifiApStateEnabled = 13;
  static String? hotspotCameraIP;

  CameraSniffer() {
    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      socket?.broadcastEnabled = true;
      socket?.listen(_handleSocketEvent);
      debugPrint('===Create DatagramSocket Successfully!');
    } catch (e) {
      alive = false;
      debugPrint('===Create DatagramSocket Failed!');
    }
  }

  void setPeeker(CameraPeeker peeker) {
    thePeeker = peeker;
  }

  void update(String s) {
    if (thePeeker != null) {
      thePeeker!.update(s);
    }
  }

  int verifyData(String s) {
    try {
      var info = s.split('CHKSUM=');
      var sum = int.parse(info[1]);
      var achar = info[0].runes;
      for (var ch in achar) {
        sum -= ch;
      }
      return sum;
    } catch (e) {
      return 1;
    }
  }

  static String? getLdwsState(String s) {
    return _extractValue(s, 'LDWS=');
  }

  static String? getFcwsState(String s) {
    return _extractValue(s, 'FCWS=');
  }

  static String? getSagState(String s) {
    return _extractValue(s, 'SAG=');
  }

  static String? getIpAddr(String s) {
    return _extractValue(s, 'IP=');
  }

  static String? getUIMode(String s) {
    return _extractValue(s, 'UIMode=');
  }

  static String? getVideoRes(String s) {
    return _extractValue(s, 'Videores=');
  }

  static String? getImageRes(String s) {
    return _extractValue(s, 'Imageres=');
  }

  static String? getTVStatus(String s) {
    return _extractValue(s, 'TV=');
  }

  static String? getWhiteBalance(String s) {
    return _extractValue(s, 'AWB=');
  }

  static String? getFlicker(String s) {
    return _extractValue(s, 'Flicker=');
  }

  static String? getEV(String s) {
    return _extractValue(s, 'EV=');
  }

  static String? getRecording(String s) {
    return _extractValue(s, 'Recording=');
  }

  static String? getStreaming(String s) {
    return _extractValue(s, 'Streaming=');
  }

  static String? getshortFileUrl(String s) {
    return _extractValue(s, 'shortFn=') ??
        _extractValue(s, 'emerFn=') ??
        _extractValue(s, 'dlFn=');
  }

  static String? _extractValue(String s, String key) {
    try {
      var info = s.split(key);
      return info[1].split('\n')[0];
    } catch (e) {
      return null;
    }
  }

  InfoStatus checkTicketTime(String s) {
    try {
      var info = s.split('ticket=');
      var newTicket = int.parse(info[1].split('\n')[0]);
      int newTime;
      info = s.split('time=');
      try {
        newTime = int.parse(info[1].split('\n')[0]);
      } catch (e) {
        newTime = utime;
      }
      if ((ticket != newTicket) || (ticket == newTicket && utime != newTime)) {
        ticket = newTicket;
        utime = newTime;
        return InfoStatus.newer;
      }
      return InfoStatus.old;
    } catch (e) {
      return InfoStatus.bad;
    }
  }

  void _handleSocketEvent(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? datagram = socket?.receive();
      if (datagram != null) {
        String s = utf8.decode(datagram.data);
        debugPrint('== GET DATA');
        if (verifyData(s) == 0) {
          if (checkTicketTime(s) == InfoStatus.newer) {
            debugPrint('== UPDATE');
            update(s);
          } else {
            debugPrint('== OLD');
          }
        } else {
          debugPrint('Check sum Error or Data Lost!!!');
        }
      }
    }
  }

  static String stringFromPacket(Datagram datagram) {
    return utf8.decode(datagram.data);
  }

  static Datagram stringToPacket(String s, InternetAddress address, int port) {
    List<int> bytes = utf8.encode(s);
    return Datagram(Uint8List.fromList(bytes), address, port);
  }

  static Future<bool> isAPEnable() async {
    try {
      var wifiInfo = await NetworkInfo().getWifiIP();
      // Check if the IP address indicates AP mode is enabled.
      // This implementation depends on the actual method available in your context.
      return wifiInfo != null && wifiInfo.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void setCameraIp(String ip) {
    debugPrint('Get Camera IP = $ip');
    hotspotCameraIP = ip;
  }

  Future<String?> getCameraIp() async {
    if (await isAPEnable()) {
      return hotspotCameraIP;
    } else {
      try {
        var wifiInfo = await NetworkInfo().getWifiGatewayIP();
        if (wifiInfo != null && wifiInfo.isNotEmpty) {
          return wifiInfo;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

enum InfoStatus { old, newer, bad }
