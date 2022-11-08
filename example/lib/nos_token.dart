class NosToken {
  NosToken({
    this.bucketName,
    this.objName,
    this.uploadToken,
    this.targetUrl,
  });

  NosToken.fromJson(dynamic json) {
    bucketName = json['bucketName'];
    objName = json['objName'];
    uploadToken = json['uploadToken'];
    targetUrl = json['targetUrl'];
  }

  String? bucketName;
  String? objName;
  String? uploadToken;
  String? targetUrl;

  NosToken copyWith({
    String? bucketName,
    String? objName,
    String? uploadToken,
    String? targetUrl,
  }) =>
      NosToken(
        bucketName: bucketName ?? this.bucketName,
        objName: objName ?? this.objName,
        uploadToken: uploadToken ?? this.uploadToken,
        targetUrl: targetUrl ?? this.targetUrl,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['bucketName'] = bucketName;
    map['objName'] = objName;
    map['uploadToken'] = uploadToken;
    map['targetUrl'] = targetUrl;
    return map;
  }
}
