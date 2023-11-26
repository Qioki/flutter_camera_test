import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? _controller;
  XFile? lastImage;
  bool takingPhoto = false;

  @override
  void initState() {
    super.initState();
    unawaited(initCamera());
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    _onNewCameraSelected(cameras[0]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cameraController.description);
    }
  }

  void _takePhoto() async {
    if (takingPhoto) return;
    takingPhoto = true;
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;
      await _controller?.takePicture();
    } catch (e) {
      print(e);
    }
    takingPhoto = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _controller?.value.isInitialized == true
            ? CameraPreview(_controller!)
            : Container(),
        // if (lastImage != null)
        //   Align(
        //     alignment: Alignment.topRight,
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Container(
        //         decoration:
        //             BoxDecoration(border: Border.all(color: Colors.white)),
        //         width: 120,
        //         height: 240,
        //         child: Image.file(
        //           File(lastImage!.path),
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),
        //   ),
        Align(
          alignment: Alignment.bottomCenter,
          child: IconButton(
            color: Colors.red,
            iconSize: 48,
            onPressed: _takePhoto,
            // onPressed: () async {
            //   lastImage = await _controller!.takePicture();
            //   setState(() {});
            // },
            icon: const Icon(Icons.camera),
          ),
        ),
      ],
    );
  }

  void _onNewCameraSelected(CameraDescription description) async {
    await _controller?.dispose();
    _controller =
        CameraController(description, ResolutionPreset.max, enableAudio: false);

    _controller!.addListener(() {
      print('Camera ${_controller?.value.isInitialized}');
      if (mounted) {
        setState(() {});
      }
    });
    await _controller?.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
