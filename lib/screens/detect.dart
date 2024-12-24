import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:detector_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class Detect extends StatefulWidget {
  const Detect({super.key});

  @override
  State<Detect> createState() => _DetectState();
}

class _DetectState extends State<Detect> {
  late CameraController controller;
  String label = '';
  double confidence = 0;

  loadCamera() {
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((onValue) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          controller.startImageStream((image) {
            runModel(image);
          });
        });
      }
    }).catchError((onError) {
      log('error is :$onError');
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  runModel(CameraImage img) async {
    dynamic recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );

    for (var element in recognitions) {
      setState(() {
        label = element['label'];
        confidence = element['confidence'];
      });
    }
  }

  @override
  void initState() {
    loadCamera();
    loadModel();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            height: 500,
            width: double.infinity,
            child: CameraPreview(controller)),
        Text(
          '$label    ${(confidence * 100).toInt()}%',
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 30),
      ]),
    ));
  }
}
