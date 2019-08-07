
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'widget_util.dart';

import '../../util/style.dart';
import '../../util/time.dart';
import '../../util/user_info_datesource.dart';

class ConversationListItem extends StatefulWidget {
  final Conversation conversation;
  final ConversationListItemDelegate delegate;
  const ConversationListItem({Key key,this.delegate, this.conversation}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return new _ConversationListItemState(this.delegate,this.conversation);
  }
}

class _ConversationListItemState extends State<ConversationListItem> {
  Conversation conversation ;
  ConversationListItemDelegate delegate;
  UserInfo user;

  _ConversationListItemState(ConversationListItemDelegate delegate,Conversation con) {
    this.delegate = delegate;
    this.conversation = con;
    this.user = UserInfoDataSource.getUserInfo(con.targetId);
  }
  

  Widget _buildTile() {
    return Material(
      color: Color(UIColor.ConItemBgColor),
      child: InkWell(
        onTap: () {
          if(this.delegate != null) {
            this.delegate.didTapConversation(this.conversation);
          }else {
            print("没有实现 ConversationListItemDelegate");
          }
        },
        onLongPress: () {
          if(this.delegate != null) {
            this.delegate.didLongPressConversation(this.conversation);
          }else {
            print("没有实现 ConversationListItemDelegate");
          }
        },
        child: Container(
          height: ScreenUtil().setHeight(120),
          color: Color(UIColor.ConItemBgColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildPortrait(),
              _buildContent()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortrait() {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 8,
            ),
            WidgetUtil.buildUserPortrait(this.user.portraitUrl),
          ],
        ),
        Positioned(
          right:-3.0 ,
          top: -3.0,
          child: _buildUnreadCount(conversation.unreadMessageCount),
        ),
      ],
    );
  }

  Widget _buildContent(){
    return Expanded(
      child: Container(
        height: ScreenUtil().setHeight(120),
        margin: EdgeInsets.only(left:ScreenUtil().setWidth(20.0)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5,color: Color(UIColor.ConBorderColor),)
          )
        ),
        child: Row(
          children: <Widget>[
            _buildTitle(),
            _buildTime()
          ],
        ),
      ),
    );
  }

  Widget _buildTime(){
    String time = TimeUtil.convertTime(conversation.sentTime);
    List<Widget> _rightArea =<Widget>[
      Text(time,style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Color(UIColor.ConTimeColor))),
      SizedBox(height: ScreenUtil().setHeight(15.0),)
    ];
    return Container(
      width:ScreenUtil().setWidth(120),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        children: _rightArea
      ),
    );
  }

  Widget _buildTitle(){
    String title = this.user.name;
    String digest = "";
    if(conversation.latestMessageContent != null) {
      digest = conversation.latestMessageContent.conversationDigest();
    }
    if(digest == null) {
      digest = "";
    }
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: ScreenUtil().setSp(30.0),color: Color(UIColor.ConTitleColor),fontWeight:FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ScreenUtil().setHeight(15.0),),
          Text(
            digest,
            style: TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Color(UIColor.ConDigestColor)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildUnreadCount(int count) {
    if(count <=0 || count == null) {
      return Container(
        
      );
    }
    return Container(
      width: ScreenUtil().setWidth(32.0),
      height: ScreenUtil().setWidth(32.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.0),
        color: Color(UIColor.ConUnreadColor)
      ),
      child: Text(count.toString(),style:TextStyle(fontSize: ScreenUtil().setSp(18),color: Color(UIColor.ConUnreadTextColor)))
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTile();
  }
}

abstract class ConversationListItemDelegate {
  void didTapConversation(Conversation conversation);
  void didLongPressConversation(Conversation conversation);
}