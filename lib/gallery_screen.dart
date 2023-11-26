import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File>? _mediaFileList;

  Future<void> updateImageList() async {
    try {
      var pathToCache = await getApplicationCacheDirectory();
      var pickedFileList = pathToCache
          .listSync()
          .whereType<File>()
          .where((element) =>
              (element.path.endsWith('.jpg') ||
                  element.path.endsWith('.png')) &&
              element.existsSync())
          .toList();
      setState(() {
        _mediaFileList = pickedFileList;
      });
    } catch (e) {
      print('updateImageList $e');
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(updateImageList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
          itemCount: _mediaFileList == null ? 0 : _mediaFileList?.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemBuilder: (BuildContext context, int index) {
            return _mediaFileList![index].lengthSync() > 0
                ? Image.file(File(_mediaFileList![index].path))
                : const Center(child: Text('Error'));
          }),
    );
  }
}
