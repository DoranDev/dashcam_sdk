import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:xml/xml.dart';

import '../../dashcam_sdk.dart';

class FileBrowser {
  final Uri _uri;
  final int _count;
  bool _completed;
  List _fileList;

  static const int COUNT_MAX = 16;

  FileBrowser(this._uri, int count)
      : _count = (count < 1 ? 1 : (count > COUNT_MAX ? COUNT_MAX : count)),
        _completed = false,
        _fileList = [];

  bool isCompleted() {
    return _completed;
  }

  List getFileList() {
    var fileList = _fileList;
    _fileList = [];
    return fileList;
  }

  static String buildQuery(
      int filelistid, String directory, Format format, int count, int from) {
    var action = filelistid == 0 ? "action=dir" : "action=reardir";
    var property = "property=$directory";
    var formatParam = "format=${format.name}";
    var countParam = "count=$count";
    var fromParam = "from=$from";

    return '$action&$property&$formatParam&$countParam&$fromParam';
  }

  Future<XmlDocument?> sendRequest(Uri url) async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(url);
    HttpClientResponse response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      return null;
    }

    String responseBody = await response.transform(utf8.decoder).join();
    responseBody = responseBody.substring(0, responseBody.lastIndexOf(">") + 1);
    return XmlDocument.parse(responseBody);
  }

  Future<int> retrieveFileList(
      int filelistid, String directory, Format format, int from) async {
    if (_completed && from != 0) {
      return -1;
    }

    _completed = false;
    _fileList.clear();

    var query = buildQuery(filelistid, directory, format, _count, from);
    var url = Uri(
        scheme: _uri.scheme,
        userInfo: _uri.userInfo,
        host: CameraCommand.getIpAddress(),
        port: _uri.port,
        path: _uri.path,
        query: query,
        fragment: _uri.fragment);

    var document = await sendRequest(url);
    if (document == null) {
      return from;
    }

    try {
      int amount =
          FileBrowserModel.parseDirectoryModel(document, directory, _fileList);
      if (amount != _count) {
        _completed = true;
      }
    } catch (e) {
      print(e);
    }

    return from + _count;
  }
}

class Format {
  static const Format mov = Format._('mov');
  static const Format avi = Format._('avi');
  static const Format mp4 = Format._('mp4');
  static const Format jpeg = Format._('jpeg');
  static const Format all = Format._('all');

  final String name;

  const Format._(this.name);

  @override
  String toString() => name;

  static List<Format> get values => [mov, avi, mp4, jpeg, all];

  static Format fromString(String name) {
    return values.firstWhere((format) => format.name == name,
        orElse: () => throw ArgumentError('Invalid format name'));
  }
}

class FileBrowserModel {
  static int parseDirectoryModel(
      XmlDocument document, String directory, List fileList) {
    final element = document.rootElement;

    if (element.name.toString().toLowerCase() == directory.toLowerCase()) {
      return parseDirectory(element, fileList);
    } else {
      throw Exception('Directory element does not match');
    }
  }

  static int parseDirectory(XmlNode node, List fileList) {
    final children = node.children;
    int amount = 0;

    for (var child in children) {
      if (child.nodeType != XmlNodeType.ELEMENT) continue;

      if (DirectoryElement.file.matchElement(child)) {
        // try {
        //   final file = FileNode.fromXmlNode(child);
        //   fileList.add(file);
        // } catch (e) {
        //   if (e is Exception) {
        //     print(e);
        //   }
        // }
      } else if (DirectoryElement.amount.matchElement(child)) {
        amount = int.parse(child.text);
      }
    }
    return amount;
  }

  static void printDocument(XmlDocument document) {
    final domSource = document.toXmlString(pretty: true);
    print(domSource);
  }

  static E strToEnum<E>(List<E> enumValues, String value) {
    value = value.trim();

    for (var enumVal in enumValues) {
      if (enumVal.toString().split('.').last.toLowerCase() ==
          value.toLowerCase()) {
        return enumVal;
      }
    }
    throw Exception('Invalid enum value');
  }
}

// DirectoryElement class
class DirectoryElement {
  static const DirectoryElement file = DirectoryElement._('file');
  static const DirectoryElement amount = DirectoryElement._('amount');

  final String elementName;

  const DirectoryElement._(this.elementName);

  bool matchElement(XmlNode node) {
    if (node is XmlElement) {
      return node.name.toString() == elementName;
    }
    return false;
  }
}

// void main() {
//   // Example usage:
//   var url = Uri.parse('http://example.com');
//   var fileBrowser = FileBrowser(url, 10);
//   fileBrowser.retrieveFileList(0, 'directory', Format('xml'), 0).then((result) {
//     print(result);
//   });
// }
