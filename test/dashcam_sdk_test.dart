import 'package:dashcam_sdk/dashcam_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () async {
      DashCamCameraCommand.setIpAddress("192.168.0.1");
      expect(DashCamCameraCommand.ipAddress, "192.168.0.1");
      DashCamCameraCommand.setIpAddress("192.168.0.2");
      expect(DashCamCameraCommand.ipAddress, "192.168.0.2");
      expect(
          await DashCamCameraCommand.commandCameraSnapshotUrl(),
          Uri.parse(
              "http://192.168.0.2/cgi-bin/Config.cgi?action=set&property=Video&value=capture"));
    });
  });
}
