import 'dart:math';

import 'db_manager.dart';

class BaseInfo {
  String id;
  String name;
  String portraitUrl;
}

class UserInfo extends BaseInfo {
  //开发者可以按需自行增加字段
  Map<String, dynamic> toMap() {
    return {'userId': id, 'name': name, 'portraitUrl': portraitUrl};
  }
}

class GroupInfo extends BaseInfo {
  //开发者可以按需自行增加字段
  Map<String, dynamic> toMap() {
    return {'groupId': id, 'name': name, 'portraitUrl': portraitUrl};
  }
}

//用户信息，用户信息需要开发者自行处理（从 APP 服务获取用户信息并保存），此处只做了最简单的处理
class UserInfoDataSource {
  static Map<String, UserInfo> cachedUserMap = new Map(); //保证同一 userId
  static Map<String, GroupInfo> cachedGroupMap = new Map(); //保证同一 groupId
  static UserInfoCacheListener cacheListener;

  // 用来刷新用户信息，当有用户信息更新的时候
  static void setUserInfo(UserInfo info) {
    if (info == null) {
      return;
    }
    cachedUserMap[info.id] = info;
    DbManager.instance.setUserInfo(info);
  }

  // 获取用户信息
  static Future<UserInfo> getUserInfo(String userId) async {
    UserInfo cachedUserInfo = cachedUserMap[userId];
    if (cachedUserInfo != null) {
      return cachedUserInfo;
    } else {
      UserInfo info;
      List<UserInfo> infoList =
          await DbManager.instance.getUserInfo(userId: userId);
      if (infoList != null && infoList.length > 0) {
        info = infoList[0];
      }
      if (info == null) {
        if (cacheListener != null) {
          info = cacheListener.getUserInfo(userId);
        }
        if (info != null) {
          DbManager.instance.setUserInfo(info);
        }
      }
      if (info != null) {
        cachedUserMap[info.id] = info;
      }

      if (info == null) {
        info = UserInfo();
      }
      return info;
    }
  }

  static UserInfo generateUserInfo(String userId) {
    List names = _getCachedNameList();
    List urls = _getCachedPortraitList();

    UserInfo user = new UserInfo();
    user.id = userId;
    user.name = names[Random().nextInt(names.length)];
    user.portraitUrl = urls[Random().nextInt(urls.length)];

    cachedUserMap[userId] = user;
    return user;
  }

  static GroupInfo generateGroupInfo(String groupId) {
    List names = _getCachedNameList();
    List urls = _getCachedPortraitList();

    GroupInfo group = new GroupInfo();
    group.id = groupId;
    group.name = names[Random().nextInt(names.length)];
    group.portraitUrl = urls[Random().nextInt(urls.length)];

    cachedGroupMap[groupId] = group;
    return group;
  }

  static void setGroupInfo(GroupInfo info) {
    if (info == null) {
      return;
    }
    cachedGroupMap[info.id] = info;
    DbManager.instance.setGroupInfo(info);
  }

  // 群组信息
  static Future<GroupInfo> getGroupInfo(String groupId) async {
    GroupInfo cachedGroupInfo = cachedGroupMap[groupId];
    if (cachedGroupInfo != null) {
      return cachedGroupInfo;
    } else {
      GroupInfo info;
      List<GroupInfo> infoList =
          await DbManager.instance.getGroupInfo(groupId: groupId);
      if (infoList != null && infoList.length > 0) {
        info = infoList[0];
      }
      if (info == null) {
        if (cacheListener != null) {
          info = cacheListener.getGroupInfo(groupId);
        }
        if (info != null) {
          DbManager.instance.setGroupInfo(info);
        }
      }
      if (info != null) {
        cachedGroupMap[info.id] = info;
      }

      if (info == null) {
        info = GroupInfo();
      }
      return info;
    }
  }

  static void setCacheListener(UserInfoCacheListener listener) {
    cacheListener = listener;
  }

  static List _getCachedNameList() {
    List names = [
      "丁春秋",
      "木婉清",
      "包不同",
      "王语嫣",
      "云中鹤",
      "天山童姥",
      "乔峰",
      "阿朱",
      "阿紫",
      "鸠摩智",
      "段誉",
      "段正淳",
      "萧远山",
      "虚竹"
    ];
    return names;
  }

  static List _getCachedPortraitList() {
    List urls = [
      "http://b-ssl.duitang.com/uploads/item/201804/24/20180424214451_5lJat.png",
      "http://i0.hdslb.com/bfs/article/64a47330d4c66553fe18bf6b63ab761099fd018c.jpg",
      "http://img.mp.itc.cn/upload/20161205/545bbfda38bd4d738266189901a25a61_th.jpeg",
      "http://b-ssl.duitang.com/uploads/item/201804/13/20180413141949_aFcZ3.png"
    ];
    return urls;
  }

  static List _getCachaGroupNameList() {
    List names = [
      "群组0",
      "群组1",
      "群组2",
      "群组3",
      "群组4",
      "群组5",
      "群组6",
      "群组7",
      "群组8",
      "群组9"
    ];
    return names;
  }
}

class UserInfoCacheListener {
  UserInfo Function(String userId) getUserInfo;
  GroupInfo Function(String groupId) getGroupInfo;
  void Function(UserInfo info) onUserInfoUpdated;
}
