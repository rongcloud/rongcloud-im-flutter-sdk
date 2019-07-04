package com.example.rongcloud_im_plugin;


import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.ChatRoomMemberInfo;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;

public class MessageFactory {

    private static class SingleHolder {
        static MessageFactory instance = new MessageFactory();
    }

    public static MessageFactory getInstance() {
        return MessageFactory.SingleHolder.instance;
    }

    public String message2String(Message message) {
        Map map = new HashMap();
        map.put("conversationType",message.getConversationType().getValue());
        map.put("targetId",message.getTargetId());
        map.put("messageId",message.getMessageId());
        map.put("messageDirection",message.getMessageDirection().getValue());
        map.put("senderUserId",message.getSenderUserId());
        map.put("receivedStatus",message.getReceivedStatus().getFlag());
        map.put("sentStatus",message.getSentStatus().getValue());
        map.put("sentTime",message.getSentTime());
        map.put("objectName",message.getObjectName());
        String uid = message.getUId();
        if(uid == null || uid.length() <= 0) {
            uid = "";
        }
        map.put("messageUId",uid);

        MessageContent content = message.getContent();
        byte[] data = content.encode();
        String jsonS = new String(data);

        map.put("content",jsonS);

        JSONObject jObj = new JSONObject(map);

        String jStr = jObj.toString();

        return jStr;
    }

    public String conversation2String(Conversation conversation) {
        Map map = new HashMap();
        map.put("conversationType",conversation.getConversationType().getValue());
        map.put("targetId",conversation.getTargetId());
        map.put("unreadMessageCount",conversation.getUnreadMessageCount());
        map.put("receivedStatus",conversation.getReceivedStatus().getFlag());
        map.put("sentStatus",conversation.getSentStatus().getValue());
        map.put("sentTime",conversation.getSentTime());
        map.put("objectName",conversation.getObjectName());
        map.put("senderUserId",conversation.getSenderUserId());
        map.put("latestMessageId",conversation.getLatestMessageId());

        MessageContent content = conversation.getLatestMessage();
        byte[] data = content.encode();
        String jsonS = new String(data);

        map.put("content",jsonS);

        JSONObject jObj = new JSONObject(map);

        String jStr = jObj.toString();
        return jStr;
    }

    public Map chatRoom2Map(ChatRoomInfo chatRoomInfo) {
        Map map = new HashMap();
        map.put("targetId",chatRoomInfo.getChatRoomId());
        map.put("memberOrder",chatRoomInfo.getMemberOrder().getValue());
        map.put("totalMemeberCount",chatRoomInfo.getTotalMemberCount());

        List memList = new ArrayList();
        for(ChatRoomMemberInfo memInfo : chatRoomInfo.getMemberInfo()) {
            Map memMap = new HashMap();
            memMap.put("userId",memInfo.getUserId());
            memMap.put("joinTime",memInfo.getJoinTime());
            memList.add(memMap);
        }
        map.put("memberInfoList",memList);

        return map;
    }
}

