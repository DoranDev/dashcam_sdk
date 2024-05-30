import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class CameraSocket {
  Socket? clientSocket;
  String? targetIp;
  int targetPort = 8000;
  int tcpTimeout = 5000;
  int tcpLinkcnt = 0;
  late DateTime tcpSendtime;
  late DateTime tcpRecvtime;

  final StreamController<int> _eventController = StreamController<int>();

  Stream<int> get events => _eventController.stream;

  final List<int> data = utf8.encode('Wakeup\n');

  void sendTcpWakeupData(String ip) {
    targetIp = ip;
    _sendWakeup();
  }

  Future<void> _sendWakeup() async {
    try {
      tcpSendtime = DateTime.now();
      clientSocket = await Socket.connect(targetIp, targetPort,
          timeout: Duration(milliseconds: 3000));

      clientSocket!.add(data);
      await clientSocket!.flush();
      clientSocket!.close();
    } catch (e) {
      tcpRecvtime = DateTime.now();
      debugPrint(
          "CameraSocket timeout: ${tcpRecvtime.difference(tcpSendtime).inMilliseconds}");

      if (tcpRecvtime.difference(tcpSendtime).inMilliseconds < 3000) {
        await Future.delayed(Duration(
            milliseconds:
                3000 - tcpRecvtime.difference(tcpSendtime).inMilliseconds));
      }

      _eventController.add(IPCamWhistlerEvent.msgWakeupSent);
    } finally {
      await Future.delayed(Duration(seconds: 3));
      _eventController.add(IPCamWhistlerEvent.msgWakeupSent);
    }
  }

  void tcpConnectPort(String ip, int port) {
    tcpLinkcnt = 0;
    targetIp = ip;
    targetPort = port;
    _connectPort();
  }

  Future<void> _connectPort() async {
    try {
      clientSocket = await Socket.connect(targetIp, targetPort,
          timeout: Duration(milliseconds: tcpTimeout));

      clientSocket!.close();
      _eventController.add(IPCamWhistlerEvent.msgRunrtspEvent);
    } catch (e) {
      debugPrint("CameraSocket connection error: $e");
      tcpLinkcnt++;
      if (tcpLinkcnt > 100) {
        _eventController.add(IPCamWhistlerEvent.msgConnectrtspFailed);
      } else {
        await Future.delayed(Duration(milliseconds: 50));
        _connectPort();
      }
    }
  }
}

class IPCamWhistlerEvent {
  static const int msgUpdateEvent = 1;
  static const int msgDownloadFinished = 2;
  static const int msgSurfaceSize = 3;
  static const int msgDownloadFail = 4;
  static const int msgReceiveIp = 5;
  static const int msgBroadcastEvent = 6;
  static const int msgRunrtspEvent = 7;
  static const int msgConnectrtspFailed = 8;
  static const int msgWakeupSent = 9;
  static const int msgReceiveRing = 10;
  static const int msgReceivePir = 11;
}
