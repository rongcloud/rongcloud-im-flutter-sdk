import 'dart:convert';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class LocationMessage extends MessageContent {
  static const String objectName = "RC:LBSMsg";
  double mLat;
  double mLng;
  String mPoi;
  String mBase64;
  String mImgUri;

  static LocationMessage obtain(
      double lat, double lng, String poi, String imgUri) {
    LocationMessage msg = LocationMessage();
    msg.mLat = lat;
    msg.mLng = lng;
    msg.mPoi = poi;
    msg.mImgUri = imgUri;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    Map map = json.decode(jsonStr);
    this.mLat = map["latitude"];
    this.mLng = map["longitude"];
    this.mPoi = map["poi"];
    this.mBase64 = map["content"];
    this.mImgUri = map["content"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
  }

  @override
  String encode() {
    Map map = {"latitude":this.mLat,"longitude":this.mLng,"poi":mPoi
    ,"mBase64":mBase64,"mImgUri":mImgUri};
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return "位置";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
