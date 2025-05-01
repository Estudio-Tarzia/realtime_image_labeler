# realtime_image_labeler

[![pub package](https://img.shields.io/pub/v/realtime_image_labeler.svg)](https://pub.dev/packages/realtime_image_labeler)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/[YOUR_GITHUB_USERNAME]/realtime_image_labeler/blob/main/LICENSE) <!-- UPDATE GITHUB LINK -->

A Flutter widget that provides a live camera preview for real-time object detection using a built-in SSD MobileNet TFLite model. It displays bounding boxes with labels and confidence scores for detected objects and offers a simple interface for integration.

**(View Portuguese Version [README_pt-BR.md](README_pt-BR.md))**

## Preview

**(ADD A SCREENSHOT OR GIF HERE!)**

*Example:*
`![Widget Preview](preview.gif)`

*A GIF demonstrating real-time detection is highly recommended.*

## Features

*   Displays a full-screen live camera preview.
*   Performs real-time object detection using the included SSD MobileNet TFLite model.
*   Draws bounding boxes and labels around detected objects.
*   Provides detection results via the `onResult` callback (includes label, confidence, location).
*   Optionally includes a customizable button to capture pictures (`onTakePicture` callback).
*   Handles camera initialization and lifecycle management internally.

## Getting Started

1.  **Add Dependency:** Add this to your project's `pubspec.yaml` file:
    ```yaml
    dependencies:
      realtime_image_labeler: ^0.0.1 # Replace with the latest published version
    ```

2.  **Install:** Run `flutter pub get` in your terminal.

## Platform Setup (Permissions)

Camera access requires platform-specific configuration.

**Android** (`android/app/src/main/AndroidManifest.xml`)

Add the following permission *before* the `<application>` tag:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<!-- Optional, but recommended -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
Use code with caution.
Markdown
iOS (ios/Runner/Info.plist)
Add the following key-string pair inside the main <dict> tag:
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to perform live object detection.</string>
Use code with caution.
Xml
(Remember to provide a clear usage description for your users).
Note: While this widget handles camera initialization, you might still want to request camera permission before navigating to the screen containing DetectorWidget, using a package like permission_handler for a smoother user experience.
Basic Usage
Import the package and integrate DetectorWidget into your screen.
import 'package:flutter/material.dart';
import 'package:realtime_image_labeler/realtime_image_labeler.dart'; // Import the package
import 'dart:io'; // Required for File operations if using onTakePicture
import 'package:camera/camera.dart'; // Required for XFile

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-time Object Detection')),
      body: DetectorWidget(
        // Required callback for detection results
        onResult: (List<Recognition> results) {
          // Process the list of detected objects (Recognition)
          // Each 'Recognition' object contains label, confidence score,
          // and location (bounding box).
          if (results.isNotEmpty) {
            // Example: Print the primary detected object's label and confidence
            final firstResult = results.first;
            print(
                "Detected: ${firstResult.label} (${(firstResult.score * 100).toStringAsFixed(0)}%)");
          }
          // Consider updating your UI based on the results here
        },

        // Optional callback when a picture is taken
        onTakePicture: (XFile file) {
          print('Picture captured: ${file.path}');

          // Example: Navigate to a new screen to display the picture
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => DisplayPictureScreen(imagePath: file.path),
          //   ),
          // );

          // Or display in a dialog:
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Picture Taken"),
              content: Image.file(File(file.path)), // Requires 'dart:io'
              actions: [
                TextButton(
                    onPressed: Navigator.of(context).pop, child: Text("OK"))
              ],
            ),
          );
        },

        // --- Optional Styling ---
        // iconSize: 70,
        // icon: Icons.camera_alt,
        // backgroundColor: Colors.blue,
        // foregroundColor: Colors.white,
        // showCameraButton: true, // Defaults to true if onTakePicture is provided
      ),
    );
  }
}

/// Structure of the Recognition object (as typically used in TFLite examples)
/// You might need to adjust based on your exact internal 'Recognition' class.
/*
class Recognition {
  final int id;        // Usually an index
  final String label;  // Detected object name
  final double score;  // Confidence score (0.0 to 1.0)
  final Rect location; // Bounding box (relative coordinates)

  Recognition(this.id, this.label, this.score, this.location);
}
*/
Use code with caution.
Dart
DetectorWidget Parameters
onResult (required, Function(List<Recognition>)): Callback invoked frequently with the list of detected objects. Each Recognition object provides details like label, confidence score, and location.
onTakePicture (optional, Function(XFile)?): Callback invoked when the user taps the capture button. Returns an XFile object (from the camera package). If this is null, the camera button will not be shown by default.
icon (optional, IconData): Icon used for the capture button. Defaults to Icons.camera.
backgroundColor (optional, Color): Background color of the capture button circle. Defaults to Colors.white.
foregroundColor (optional, Color): Color of the icon on the capture button. Defaults to Colors.black.
iconSize (optional, double): Size of the capture button icon. Defaults to 100.0.
showCameraButton (optional, bool): Explicitly controls the visibility of the camera button. Defaults to true if onTakePicture is provided, otherwise false. If set to true but onTakePicture is null, the button will appear but do nothing when tapped.
Model Used
This package uses a pre-trained SSD MobileNet v1 model (ssd_mobilenet.tflite) and corresponding labels (labelmap.txt) bundled as assets to perform object detection. These assets are included within the package.
IMPORTANT: The included model and labels are typically derived from the TensorFlow Object Detection API and often distributed under the Apache License 2.0. Please verify the specific license terms applicable to the model files you have bundled if they differ from the standard TensorFlow examples. Ensure compliance when using or distributing this package.
Acknowledgement
The core detection logic and widget structure are inspired by and adapt concepts from the official TensorFlow Lite Flutter example:
https://github.com/tensorflow/flutter-tflite/blob/main/example/live_object_detection_ssd_mobilenet
Additional Information
Find the source code on GitHub. <!-- UPDATE LINK -->
Report issues on the issue tracker. <!-- UPDATE LINK -->
Contributions are welcome!
License
This package is licensed under the MIT License.
