// ignore_for_file: avoid_print

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realtime_image_labeler/src/src.dart';

/// A [StatefulWidget] that represents a detector widget in the application.
///
/// This widget is used to perform detection functionality, such as image
/// labeling or object detection, and provides a user interface for interacting
/// with the detection process.
///
/// The [DetectorWidget] manages its own state, which allows it to update
/// dynamically based on user interactions or detection results.
///
/// ## Parameters:
/// - [onResult]: A callback function that receives a list of [Recognition]
///   objects when detection results are available.
/// - [onTakePicture]: A callback function that receives an [XFile] object
///   when a picture is taken.
/// - [icon]: An optional [IconData] for the camera button. Defaults to
///   [Icons.camera].
/// - [backgroundColor]: An optional [Color] for the background of the camera
///   button. Defaults to [Colors.white].
/// - [foregroundColor]: An optional [Color] for the foreground of the camera
///   button. Defaults to [Colors.black].
/// - [iconSize]: An optional [double] for the size of the camera button icon.
///   Defaults to 100.
/// - [showCameraButton]: A boolean that determines whether to show the
///   camera button. Defaults to true.
/// - [key]: An optional [Key] for the widget.

class DetectorWidget extends StatefulWidget {
  const DetectorWidget({
    super.key,
    required this.onResult,
    this.onTakePicture,
    this.icon = Icons.camera,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.iconSize = 100,
    this.showCameraButton = true,
  });

  final void Function(List<Recognition>) onResult;
  final void Function(XFile)? onTakePicture;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;
  final bool showCameraButton;

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver {
  late List<CameraDescription> cameras;
  CameraController? _cameraController;
  get _controller => _cameraController;
  Detector? _detector;
  StreamSubscription? _subscription;

  List<Recognition>? results;

  bool isTakingPicture = false;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _takePictures() async {
    setState(() {
      isTakingPicture = true;
    });
    if (_cameraController == null || !_controller.value.isInitialized) {
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      if (widget.onTakePicture != null) {
        widget.onTakePicture!(file);
      }
    } catch (e) {
      print('Error taking picture: $e');
    }

    setState(() {
      isTakingPicture = false;
    });
  }

  void _initStateAsync() async {
    _initializeCamera();

    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        _subscription = instance.resultsStream.stream.listen((values) {
          setState(() {
            results = values['recognitions'];
            if (results != null) {
              isDetecting = false;
              widget.onResult(results!);
            }
          });
        });
      });
    });
  }

  void _initializeCamera() async {
    cameras = await availableCameras();

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});
        ScreenParams.previewSize = _controller.value.previewSize!;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    var aspect = 1 / _controller.value.aspectRatio;

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: aspect,
            child: CameraPreview(_controller),
          ),
        ),
        Center(
          child: AspectRatio(
            aspectRatio: aspect,
            child: _boundingBoxes(),
          ),
        ),
        if (widget.showCameraButton && widget.onTakePicture != null)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: !isTakingPicture ? _takePictures : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isTakingPicture
                      ? widget.backgroundColor
                      : widget.foregroundColor,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: isTakingPicture
                        ? widget.foregroundColor
                        : widget.backgroundColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }

    return Stack(
        children: results!.map((box) {
      return BoxWidget(result: box);
    }).toList());
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
