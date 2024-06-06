import 'package:dashcam_sdk/dashcam_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () async {
      CameraCommand.setIpAddress("192.168.0.1");
      expect(CameraCommand.ipAddress, "192.168.0.1");
      CameraCommand.setIpAddress("192.168.0.2");
      expect(CameraCommand.ipAddress, "192.168.0.2");
      expect(
          await CameraCommand.commandCameraSnapshotUrl(),
          Uri.parse(
              "http://192.168.0.2/cgi-bin/Config.cgi?action=set&property=Video&value=capture"));
    });
  });
}
