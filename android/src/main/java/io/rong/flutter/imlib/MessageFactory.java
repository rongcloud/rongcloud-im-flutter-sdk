package io.rong.flutter.imlib;


import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.ChatRoomMemberInfo;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageConfig;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.ReadReceiptInfo;
import io.rong.imlib.model.SearchConversationResult;
import io.rong.imlib.typingmessage.TypingStatus;
import io.rong.message.GIFMessage;
import io.rong.message.ImageMessage;
import io.rong.message.LocationMessage;
import io.rong.message.ReferenceMessage;
import io.rong.message.SightMessage;
import io.rong.message.TextMessage;

public class MessageFactory {

    private static class SingleHolder {
        static MessageFactory instance = new MessageFactory();
    }

    public static MessageFactory getInstance() {
        return MessageFactory.SingleHolder.instance;
    }

    public String message2String(Message message) {
        if (message == null) {
            return "";
        }
        Map map = new HashMap();
        map.put("conversationType", message.getConversationType().getValue());
        map.put("targetId", message.getTargetId());
        map.put("messageId", message.getMessageId());
        if (message.getMessageDirection() != null) {
            map.put("messageDirection", message.getMessageDirection().getValue());
        }
        map.put("senderUserId", message.getSenderUserId());
        if (message.getReceivedStatus() != null) {
            map.put("receivedStatus", message.getReceivedStatus().getFlag());
        }
        if (message.getSentStatus() != null) {
            map.put("sentStatus", message.getSentStatus().getValue());
        }
        ReadReceiptInfo readInfo = message.getReadReceiptInfo();
        if (readInfo != null) {
            HashMap readReceiptMap = new HashMap();
            readReceiptMap.put("isReceiptRequestMessage", readInfo.isReadReceiptMessage());
            readReceiptMap.put("hasRespond", readInfo.hasRespond());
            readReceiptMap.put("userIdList", readInfo.getRespondUserIdList());
            map.put("readReceiptInfo", readReceiptMap);
        }
        MessageConfig messageConfig = message.getMessageConfig();
        if (messageConfig != null) {
            HashMap messageConfigMap = new HashMap();
            messageConfigMap.put("disableNotification", messageConfig.isDisableNotification());
            map.put("messageConfig", messageConfigMap);
        }
        map.put("sentTime", message.getSentTime());
        map.put("objectName", message.getObjectName());
        map.put("extra", message.getExtra());
        map.put("canIncludeExpansion",message.isCanIncludeExpansion());
        map.put("expansionDic",message.getExpansion());
        String uid = message.getUId();
        if (uid == null || uid.length() <= 0) {
            uid = "";
        }
        map.put("messageUId", uid);

        MessageContent content = message.getContent();
        if (message.getContent() instanceof ImageMessage) {
            RCMessageHandler.encodeImageMessage(message);
        } else if (message.getContent() instanceof SightMessage) {
            RCMessageHandler.encodeSightMessage(message);
        } else if (message.getContent() instanceof GIFMessage) {
            RCMessageHandler.encodeGifMessage(message);
        } else if (message.getContent() instanceof LocationMessage) {
            RCMessageHandler.encodeLocationMessage(message);
        } else if (message.getContent() instanceof ReferenceMessage) {
            // 引用消息的引用内容的类型需要判断
            RCMessageHandler.encodeReferenceMessage(message);
        }
        // 判断 TextMessage 内容不能为 null
        if (content instanceof TextMessage) {
            if (((TextMessage) content).getContent() == null) {
                ((TextMessage) content).setContent("");
            }
        }

        byte[] data = null;
        if (content instanceof ImageMessage) {
            // 处理 thumbUri 丢失的问题
            data = RCMessageHandler.encodeImageContent((ImageMessage) content);
        } else if (content instanceof SightMessage) {
            data = RCMessageHandler.encodeSightContent((SightMessage) content);
        } else if (content != null) {
            data = content.encode();
        }

        if (data != null && data.length > 0) {
            String jsonS = new String(data);
            map.put("content", jsonS);
        }

        JSONObject jObj = new JSONObject(map);

        String jStr = jObj.toString();

        return jStr;
    }

    public String messageContent2String(MessageContent content) {
        if (content == null) {
            return null;
        }
        byte[] data = content.encode();
        String jsonS = new String(data);
        return jsonS;
    }

    public String conversation2String(Conversation conversation) {
        Map map = new HashMap();
        map.put("conversationType", conversation.getConversationType().getValue());
        map.put("targetId", conversation.getTargetId());
        map.put("unreadMessageCount", conversation.getUnreadMessageCount());
        map.put("receivedStatus", conversation.getReceivedStatus().getFlag());
        map.put("sentStatus", conversation.getSentStatus().getValue());
        map.put("sentTime", conversation.getSentTime());
        map.put("isTop", conversation.isTop());
        map.put("objectName", conversation.getObjectName());
        map.put("senderUserId", conversation.getSenderUserId());
        map.put("latestMessageId", conversation.getLatestMessageId());
        map.put("mentionedCount", conversation.getMentionedCount());
        map.put("draft", conversation.getDraft());

        MessageContent content = conversation.getLatestMessage();
        if (content != null) {
            byte[] data = content.encode();
            if (data != null && data.length > 0) {
                String jsonS = new String(data);
                map.put("content", jsonS);
            }
        } else {
//            map.put("content","");
        }


        JSONObject jObj = new JSONObject(map);

        String jStr = jObj.toString();
        return jStr;
    }

    public Map chatRoom2Map(ChatRoomInfo chatRoomInfo) {
        Map map = new HashMap();
        map.put("targetId", chatRoomInfo.getChatRoomId());
        map.put("memberOrder", chatRoomInfo.getMemberOrder().getValue());
        map.put("totalMemeberCount", chatRoomInfo.getTotalMemberCount());

        List memList = new ArrayList();
        for (ChatRoomMemberInfo memInfo : chatRoomInfo.getMemberInfo()) {
            Map memMap = new HashMap();
            memMap.put("userId", memInfo.getUserId());
            memMap.put("joinTime", memInfo.getJoinTime());
            memList.add(memMap);
        }
        map.put("memberInfoList", memList);

        return map;
    }

    public String typingStatus2String(TypingStatus status) {
        Map map = new HashMap();
        map.put("userId", status.getUserId());
        map.put("typingContentType", status.getTypingContentType());
        map.put("sentTime", status.getSentTime());
        JSONObject jObj = new JSONObject(map);
        String jStr = jObj.toString();
        return jStr;
    }

    public String SearchConversationResult2String(SearchConversationResult result) {
        Map map = new HashMap();
        map.put("mConversation", conversation2String(result.getConversation()));
        map.put("mMatchCount", result.getMatchCount());
        JSONObject jObj = new JSONObject(map);
        String jStr = jObj.toString();
        return jStr;
    }
}

