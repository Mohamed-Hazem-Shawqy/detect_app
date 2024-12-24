import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image/image.dart' as ig;
import 'package:image_picker/image_picker.dart';

class Picker extends StatefulWidget {
  const Picker({super.key});

  @override
  State<Picker> createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  final ImagePicker _picker = ImagePicker();
  File? img;
  GlobalKey<ScaffoldState> key = GlobalKey();
  String label = '';
  double confidence = 0;

  @override
  void initState() {
    super.initState();
    loadModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      key.currentState?.showBottomSheet(
        (context) => SizedBox(
          height: 96,
          width: double.infinity,
          child: Column(
            children: [
              TextButton.icon(
                onPressed: () async {
                  var camera =
                      await _picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    img = camera != null ? File(camera.path) : null;
                  });
                  if (img != null) {
                    runModel(img!);
                  }
                },
                label: const Text('from camera'),
                icon: const Icon(Icons.camera_alt),
              ),
              TextButton.icon(
                onPressed: () async {
                  XFile? gallery =
                      await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    img = gallery != null ? File(gallery.path) : null;
                  });
                  if (img != null) {
                    runModel(img!);
                  }
                },
                label: const Text('from gallery'),
                icon: const Icon(Icons.image),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.grey,
        enableDrag: false,
      );
    });
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future<void> runModel(File image) async {
    // Step 1: Load the image as bytes
    final imageBytes = await image.readAsBytes();

    // Step 2: Decode the image using the image package
    ig.Image? decodedImage = ig.decodeImage(imageBytes);

    if (decodedImage == null) {
      return; // Early return if decoding fails
    }

    // Step 3: Re-encode the image to JPEG format
    final jpegBytes = ig.encodeJpg(decodedImage, quality: 90);

    // Step 4: Save the JPEG image to a temporary file
    final tempDir = Directory.systemTemp;
    final tempImageFile = File('${tempDir.path}/temp_image.jpg')
      ..writeAsBytesSync(jpegBytes);

    // Step 5: Run the model on the re-encoded JPEG image
    dynamic recognitions = await Tflite.runModelOnImage(
      path: tempImageFile.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    for (var element in recognitions) {
      setState(() {
        label = element['label'];
        confidence = element['confidence'];
      });
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (img != null)
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: FileImage(img!)),
                  ),
                  child: Container(
                    margin:
                        const EdgeInsets.only(top: 250, left: 100, right: 100),
                    color: Colors.grey.withOpacity(.5),
                    child: Text(
                      ' $label   ${(confidence * 100).toInt()}%',
                      style: const TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              const Text('No image selected'),
          ],
        ),
      ),
    );
  }
}
