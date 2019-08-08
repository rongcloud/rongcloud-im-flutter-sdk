import 'dart:math';

class UserInfo {
  String userId;
  String name;
  String portraitUrl;
}

//用户信息，用户信息需要开发者自行处理（从 APP 服务获取用户信息并保存），此处只做了最简单的处理
class UserInfoDataSource {
  static Map<String,UserInfo> cachedUserMap = new Map();//保证同一 userId

  static UserInfo getUserInfo(String userId) {
    UserInfo cachedUserInfo = cachedUserMap[userId];
    if(cachedUserInfo != null) {
      return cachedUserInfo;
    }

    List names = _getCachedNameList();
    List urls = _getCachedPortraitList();

    UserInfo user = new UserInfo();
    user.userId = userId;
    user.name = names[Random().nextInt(names.length)];
    user.portraitUrl = urls[Random().nextInt(urls.length)];

    cachedUserMap[userId] = user;
    return user;
  }

  static List _getCachedNameList() {
    List names = ["丁春秋","木婉清","包不同","王语嫣","云中鹤","天山童姥"
    ,"乔峰","阿朱","阿紫","鸠摩智","段誉","段正淳","萧远山","虚竹"];
    return names;
  }

  static List _getCachedPortraitList() {
    List urls = ["http://b-ssl.duitang.com/uploads/item/201804/24/20180424214451_5lJat.png",
    "http://i0.hdslb.com/bfs/article/64a47330d4c66553fe18bf6b63ab761099fd018c.jpg",
    "http://img.mp.itc.cn/upload/20161205/545bbfda38bd4d738266189901a25a61_th.jpeg",
    "http://b-ssl.duitang.com/uploads/item/201804/13/20180413141949_aFcZ3.png"];
    return urls;
  }

}