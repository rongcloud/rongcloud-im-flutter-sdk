package com.example.rongcloud_im_plugin;


import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

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
        map.put("conversationType",message.getConversationType());
        map.put("targetId",message.getTargetId());
        map.put("messageId",message.getMessageId());
        map.put("messageDirection",message.getMessageDirection());
        map.put("senderUserId",message.getSenderUserId());
        map.put("receivedStatus",message.getReceivedStatus());
        map.put("sentStatus",message.getSentStatus());
        map.put("sentTime",message.getSentTime());
        map.put("objectName",message.getObjectName());
        map.put("messageUId",message.getUId());

        MessageContent content = message.getContent();
        byte[] data = content.encode();
        String jsonS = new String(data);

        map.put("content",jsonS);

        JSONObject jObj = new JSONObject(map);

        String jStr = jObj.toString();

        return jStr;
    }
}

