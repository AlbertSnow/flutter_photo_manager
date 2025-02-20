import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class SaveMediaExample extends StatefulWidget {
  const SaveMediaExample({Key? key}) : super(key: key);

  @override
  _SaveMediaExampleState createState() => _SaveMediaExampleState();
}

class _SaveMediaExampleState extends State<SaveMediaExample> {
  final String imageUrl =
      'https://ww4.sinaimg.cn/bmiddle/005TR3jLly1ga48shax8zj30u02ickjl.jpg';

  final String haveExifUrl = 'http://172.16.100.7:2393/IMG_20200107_182905.jpg';

  final String videoUrl =
      'http://img.ksbbs.com/asset/Mon_1703/05cacb4e02f9d9e.mp4';

  // final videoUrl = "http://192.168.31.252:51781/out.mov";
  // final videoUrl = "http://192.168.31.252:51781/out.ogv";

  String get videoName {
    final String extName =
        Uri.parse(videoUrl).pathSegments.last.split('.').last;
    final int name = DateTime.now().microsecondsSinceEpoch ~/
        Duration.microsecondsPerMillisecond;
    return '$name.$extName';
  }

  Future<String> downloadPath() async {
    final int name = DateTime.now().microsecondsSinceEpoch ~/
        Duration.microsecondsPerMillisecond;

    String dir;

    if (Platform.isIOS || Platform.isMacOS) {
      dir = (await getApplicationSupportDirectory()).absolute.path;
    } else if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      ))![0]
          .absolute
          .path;
    } else {
      dir = (await getDownloadsDirectory())!.absolute.path;
    }

    return '$dir/$name.jpg';
  }

  @override
  void initState() {
    super.initState();
    PhotoManager.addChangeCallback(_onChange);
    PhotoManager.startChangeNotify();
  }

  void _onChange(MethodCall call) {
    print(call.arguments);
  }

  @override
  void dispose() {
    PhotoManager.stopChangeNotify();
    PhotoManager.removeChangeCallback(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save media page'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: saveImageWithBytes,
            child: const Text('Save image with bytes'),
          ),
          ElevatedButton(
            onPressed: saveImageWithPath,
            child: const Text('Save image with path'),
          ),
          ElevatedButton(
            onPressed: saveVideo,
            child: const Text('Save video'),
          ),
        ],
      ),
    );
  }

  Future<void> saveVideo() async {
    final HttpClient client = HttpClient();
    final HttpClientRequest req = await client.getUrl(Uri.parse(videoUrl));
    final HttpClientResponse resp = await req.close();

    final String name = videoName;

    final Directory tmpDir = await getTemporaryDirectory();
    final File file = File('${tmpDir.path}/$name');
    if (file.existsSync()) {
      file.deleteSync();
    }
    resp.listen((List<int> data) {
      file.writeAsBytesSync(data, mode: FileMode.append);
    }, onDone: () async {
      print('file path = ${file.lengthSync()}');
      final AssetEntity? asset =
          await PhotoManager.editor.saveVideo(file, title: name);
      print('saved asset: $asset');
      client.close();
    });
  }

  Future<void> saveImageWithBytes() async {
    final HttpClient client = HttpClient();
    final HttpClientRequest req = await client.getUrl(Uri.parse(imageUrl));
    final HttpClientResponse resp = await req.close();
    final List<int> bytes = <int>[];
    resp.listen((List<int> data) {
      bytes.addAll(data);
    }, onDone: () {
      final Uint8List image = Uint8List.fromList(bytes);
      saveImage(image);
      client.close();
    });
  }

  Future<void> saveImage(Uint8List uint8List) async {
    final AssetEntity? asset = await PhotoManager.editor.saveImage(
      uint8List,
      title: '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    print('saved asset: $asset');
  }

  Future<void> saveImageWithPath() async {
    final HttpClient client = HttpClient();
    final HttpClientRequest req = await client.getUrl(Uri.parse(imageUrl));
    final HttpClientResponse resp = await req.close();

    final File file = File(await downloadPath());

    resp.listen((List<int> data) {
      file.writeAsBytesSync(data, mode: FileMode.append);
    }, onDone: () async {
      print('write image to file success: $file');
      final AssetEntity? asset = await PhotoManager.editor.saveImageWithPath(
        file.path,
        title: '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      print('saved asset: $asset');
      client.close();
    });
  }
}
