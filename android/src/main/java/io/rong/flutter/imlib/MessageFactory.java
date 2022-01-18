package io.rong.flutter.imlib;


import android.net.Uri;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.ChatRoomMemberInfo;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.ConversationTagInfo;
import io.rong.imlib.model.MentionedInfo;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageConfig;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.MessagePushConfig;
import io.rong.imlib.model.ReadReceiptInfo;
import io.rong.imlib.model.SearchConversationResult;
import io.rong.imlib.model.TagInfo;
import io.rong.imlib.model.UserInfo;
import io.rong.imlib.typingmessage.TypingStatus;
import io.rong.message.GIFMessage;
import io.rong.message.ImageMessage;
import io.rong.message.ReferenceMessage;
import io.rong.message.SightMessage;
import io.rong.message.TextMessage;

public class MessageFactory {

    private static class SingleHolder {
        static MessageFactory instance = new MessageFactory();
    }

    public static MessageFactory getInstance() {
        return SingleHolder.instance;
    }

    public String message2String(Message message) {
        if (message == null) {
            return "";
        }

        Map map = messageToMap(message);

        JSONObject jObj = new JSONObject(map);

        String jStr = jObj.toString();

        return jStr;
    }

    public Map messageToMap(Message message) {
        Map map = new HashMap();
        map.put("conversationType", message.getConversationType().getValue());
        map.put("targetId", message.getTargetId());
        map.put("messageId", message.getMessageId());
        map.put("channelId", message.getChannelId());
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
        MessagePushConfig messagePushConfig = message.getMessagePushConfig();
        if (messagePushConfig != null) {
            HashMap messagePushConfigMap = new HashMap();
            messagePushConfigMap.put("pushTitle", messagePushConfig.getPushTitle());
            messagePushConfigMap.put("pushContent", messagePushConfig.getPushContent());
            messagePushConfigMap.put("pushData", messagePushConfig.getPushData());
            messagePushConfigMap.put("forceShowDetailContent", messagePushConfig.isForceShowDetailContent());
            messagePushConfigMap.put("disablePushTitle", messagePushConfig.isDisablePushTitle());
            messagePushConfigMap.put("templateId", messagePushConfig.getTemplateId());
            if (messagePushConfig.getAndroidConfig() != null) {
                HashMap androidConfigMap = new HashMap();
                androidConfigMap.put("notificationId", messagePushConfig.getAndroidConfig().getNotificationId());
                androidConfigMap.put("channelIdMi", messagePushConfig.getAndroidConfig().getChannelIdMi());
                androidConfigMap.put("channelIdHW", messagePushConfig.getAndroidConfig().getChannelIdHW());
                androidConfigMap.put("channelIdOPPO", messagePushConfig.getAndroidConfig().getChannelIdOPPO());
                androidConfigMap.put("typeVivo", messagePushConfig.getAndroidConfig().getTypeVivo());
                messagePushConfigMap.put("androidConfig", androidConfigMap);
            }
            if (messagePushConfig.getIOSConfig() != null) {
                HashMap iosConfigMap = new HashMap();
                iosConfigMap.put("thread_id", messagePushConfig.getIOSConfig().getThread_id());
                iosConfigMap.put("apns_collapse_id", messagePushConfig.getIOSConfig().getApns_collapse_id());
                messagePushConfigMap.put("iOSConfig", iosConfigMap);
            }
            map.put("messagePushConfig", messagePushConfigMap);
        }
        map.put("sentTime", message.getSentTime());
        map.put("objectName", message.getObjectName());
        map.put("extra", message.getExtra());
        map.put("canIncludeExpansion", message.isCanIncludeExpansion());
        map.put("expansionDic", message.getExpansion());
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
        return map;
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
        map.put("channelId", conversation.getChannelId());
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
        if (conversation.getNotificationStatus() != null) {
            map.put("blockStatus", conversation.getNotificationStatus().getValue());
        }
        map.put("receivedTime", conversation.getReceivedTime());

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

    public String conversationTagInfo2String(ConversationTagInfo conversationTagInfo) {
        if (conversationTagInfo == null) {
            return "";
        }
        Map map = new HashMap();
        map.put("tagInfo", tagInfo2String(conversationTagInfo.getTagInfo()));
        map.put("isTop", conversationTagInfo.isTop());
        JSONObject jObj = new JSONObject(map);

        String jStr = jObj.toString();
        return jStr;
    }

    public String tagInfo2String(TagInfo tagInfo) {
        if (tagInfo == null) {
            return "";
        }
        Map map = new HashMap();
        map.put("tagId", tagInfo.getTagId());
        map.put("tagName", tagInfo.getTagName());
        map.put("count", tagInfo.getCount());
        map.put("timestamp", tagInfo.getTimestamp());

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

    public void setCommonInfo(String contentStr, MessageContent content) {
        try {
            JSONObject contentObject = new JSONObject(contentStr);
            if (contentObject.has("user")) {
                Object userObject = contentObject.get("user");
                if (userObject instanceof JSONObject) {
                    JSONObject userJObject = (JSONObject) userObject;
                    String id = "";
                    String name = "";
                    String portrait = "";
                    if (userJObject.has("id")) {
                        id = (String) userJObject.get("id");
                    }
                    if (userJObject.has("name")) {
                        name = (String) userJObject.get("name");
                    }
                    if (userJObject.has("portrait")) {
                        portrait = (String) userJObject.get("portrait");
                    }
                    UserInfo info = new UserInfo(id, name, Uri.parse(portrait));
                    if (userJObject.has("extra")) {
                        info.setExtra((String) userJObject.get("extra"));
                    }
                    content.setUserInfo(info);
                }
            }
            if (contentObject.has("mentionedInfo")) {
                Object mentionedObject = contentObject.get("mentionedInfo");
                if (mentionedObject instanceof JSONObject) {
                    JSONObject mentionedJObject = (JSONObject) mentionedObject;
                    MentionedInfo info = new MentionedInfo();
                    if (mentionedJObject.has("type")) {
                        info.setType(MentionedInfo.MentionedType.valueOf((int) mentionedJObject.get("type")));
                    }
                    if (mentionedJObject.has("userIdList")) {
                        JSONArray userIdArray = (JSONArray) mentionedJObject.get("userIdList");
                        List<String> userIdList = new ArrayList<>();
                        for (int i = 0; i < userIdArray.length(); i++) {
                            String idStr = (String) userIdArray.get(i);
                            userIdList.add(idStr);
                        }
                        info.setMentionedUserIdList(userIdList);
                    }
                    if (mentionedJObject.has("mentionedContent")) {
                        info.setMentionedContent((String) mentionedJObject.get("mentionedContent"));
                    }
                    content.setMentionedInfo(info);
                }
            }
            if (contentObject.has("burnDuration")) {
                long burnDuration = Long.valueOf(contentObject.get("burnDuration").toString());
                content.setDestructTime(burnDuration);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}

