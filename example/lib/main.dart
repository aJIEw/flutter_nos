import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nos/flutter_nos.dart';
import 'package:flutter_nos_example/nos_token.dart';
import 'package:http/http.dart' as http;
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
  final _nosUploader = FlutterNos();

  final _imagePicker = ImagePicker();

  final _imageCropper = ImageCropper();

  String _chosenPic = '';

  String avatarUrl = '';

  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();

    _nosUploader.init();
    _nosUploader.setOnSuccess((message) {
      // 上传成功
      print('flutter_nos: ==============> upload success, message = $message');

      setState(() {
        avatarUrl = _avatarUrl;
      });
    });
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
                    uploadImage();
                  },
                  child: const Text('上传图片')),
              if (avatarUrl.isNotEmpty)
                Image.network(
                  avatarUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
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

  Future<NosToken> getTokenRequest() async {
    // 向后端发起请求，获取 token 和图片链接
    final response = await http.get(Uri.parse('https://request_url'));
    if (response.statusCode == 200) {
      // TODO: 根据实际业务需求修改数据结构
      return NosToken.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Request failed');
    }
  }

  Future<void> uploadImage() async {
    var nosToken = await getTokenRequest();

    var bucketName = nosToken.bucketName ?? '';
    var objName = nosToken.objName ?? '';
    var uploadToken = nosToken.uploadToken ?? '';
    var imagePath = _chosenPic;
    // 开始上传图片
    _nosUploader.uploadImage(bucketName, objName, uploadToken, imagePath);
    // 保存图片链接
    _avatarUrl = nosToken.targetUrl ?? '';
  }
}
