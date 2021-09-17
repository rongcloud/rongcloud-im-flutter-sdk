import 'dart:convert' show json;

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

//app 层的位置消息
class LocationMessage extends MessageContent {
  static const String objectName = "RCD:LBSMsg";

  double? latitude; // 地理位置的纬度
  double? longitude; // 地理位置的经度
  String? imageUri; // 地理位置的缩略图地址
  String? poi; // 地理位置的名称
  String? extra;

  @override
  void decode(String? jsonStr) {
    Map map = json.decode(jsonStr.toString());
    this.latitude = map["latitude"];
    this.longitude = map["longitude"];
    this.imageUri = map["mImgUri"];
    this.poi = map["poi"];
    this.extra = map["extra"];

    // decode 消息内容中携带的发送者的用户信息
    Map? userMap = map["user"];
    super.decodeUserInfo(userMap);

    // decode 消息中的 @ 提醒信息；消息需要携带 @ 信息时添加此方法
    Map? menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
  }

  @override
  String encode() {
    Map map = {"extra": this.extra};

    if (this.latitude != null) {
      map["latitude"] = this.latitude;
    }

    if (this.longitude != null) {
      map["longitude"] = this.longitude;
    }

    if (this.imageUri != null) {
      map["mImgUri"] = this.imageUri;
    }

    if (this.poi != null) {
      map["poi"] = this.poi;
    }

    // encode 消息内容中携带的发送者的用户信息
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }

    // encode 消息中的 @ 提醒信息；消息需要携带 @ 信息时添加此方法
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    return json.encode(map);
  }

  @override
  String? conversationDigest() {
    return poi;
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
