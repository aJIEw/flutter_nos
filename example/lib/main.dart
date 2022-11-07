import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nos/flutter_nos.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterNosPlugin = FlutterNos();

  final _imagePicker = ImagePicker();

  final _imageCropper = ImageCropper();

  String _chosenPic = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_nos Plugin example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    chooseImage();
                  },
                  child: const Text('选择图片')),
              if (_chosenPic.isNotEmpty) Image.asset(_chosenPic),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () {

                  },
                  child: const Text('获取')),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () {
                  },
                  child: const Text('上传图片')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> chooseImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      CroppedFile? croppedFile = await _imageCropper.cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '图片裁剪',
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            cancelButtonTitle: '取消',
            doneButtonTitle: '完成',
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() => _chosenPic = croppedFile.path);
      }
    }
  }
}
