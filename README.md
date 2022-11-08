# flutter_nos

Flutter 版的网易数帆对象存储[直传 SDK](https://sf.163.com/help/documents/66981681442246656)，支持 Android & iOS。

[![pub package](https://img.shields.io/pub/v/flutter_nos?color=blue)](https://pub.dev/packages/flutter_nos)

## 开始使用

添加依赖：

```yaml
dependencies:
  flutter_nos: ^{latest_version}
```

## 用法

第一步，初始化：

```dart
final _nosUploader = FlutterNos();

@override
void initState() {
  _nosUploader.init();
}
```

第二步，设置上传成功后的回调：

```dart
_nosUploader.setOnSuccess((message) {
  // 上传成功
  print('flutter_nos: ==============> upload success, message = $message');
});
```

第三步，调用上传接口：

```dart
// 先调用后端接口获取 token 数据
var nosToken = await getTokenRequest();

var bucketName = nosToken.bucketName ?? '';
var objName = nosToken.objName ?? '';
var uploadToken = nosToken.uploadToken ?? '';
var imagePath = _chosenPic;
// 开始上传图片
_nosUploader.uploadImage(bucketName, objName, uploadToken, imagePath);
```

具体示例请移步项目下的 example 文件夹。

欢迎提交 issue 和 PR 帮助完善该项目。