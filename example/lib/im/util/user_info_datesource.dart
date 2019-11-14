import 'dart:math';

class BaseInfo {
  String id;
  String name;
  String portraitUrl;
}
class UserInfo extends BaseInfo {
  //开发者可以按需自行增加字段
}

class GroupInfo extends BaseInfo  {
  //开发者可以按需自行增加字段
}

//用户信息，用户信息需要开发者自行处理（从 APP 服务获取用户信息并保存），此处只做了最简单的处理
class UserInfoDataSource {
  static Map<String,UserInfo> cachedUserMap = new Map();//保证同一 userId
  static Map<String,GroupInfo> cachedGroupMap = new Map();//保证同一 groupId

  static UserInfo getUserInfo(String userId) {
    UserInfo cachedUserInfo = cachedUserMap[userId];
    if(cachedUserInfo != null) {
      return cachedUserInfo;
    }

    List names = _getCachedNameList();
    List urls = _getCachedPortraitList();

    UserInfo user = new UserInfo();
    user.id = userId;
    user.name = names[Random().nextInt(names.length)];
    user.portraitUrl = urls[Random().nextInt(urls.length)];

    cachedUserMap[userId] = user;
    return user;
  }

  static GroupInfo getGroupInfo(String groupId) {
    GroupInfo cachedGroupInfo = cachedGroupMap[groupId];
    if(cachedGroupInfo != null) {
      return cachedGroupInfo;
    }

    List names = _getCachaGroupNameList();
    List urls = _getCachedPortraitList();

    GroupInfo group = new GroupInfo();
    group.id = groupId;
    group.name = names[Random().nextInt(names.length)];
    group.portraitUrl = urls[Random().nextInt(urls.length)];
    cachedGroupMap[groupId] = group;
    return group;
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

  static List _getCachaGroupNameList() {
    List names = ["群组0","群组1","群组2","群组3","群组4","群组5","群组6"
    ,"群组7","群组8","群组9"];
    return names;
  }

}