package com.example.rongcloud_im_plugin;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;


import org.json.JSONException;
import org.json.JSONObject;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Array;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.security.acl.LastOwnerException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.common.fwlog.FwLog;
import io.rong.imkit.RongIM;
import io.rong.imlib.MessageTag;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.RongIMClient.SendImageMessageCallback;
import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UnknownMessage;
import io.rong.imlib.model.UserInfo;
import io.rong.message.ImageMessage;
import io.rong.message.MessageHandler;
import io.rong.message.VoiceMessage;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;


public class RCIMFlutterWrapper {

    private static Context mContext = null;
    private static MethodChannel mChannel = null;
    private static RCFlutterConfig mConfig = null;
    private Handler mMainHandler = null;

    private HashMap<String, Constructor<? extends MessageContent>> messageContentConstructorMap;

    private RCIMFlutterWrapper() {
        messageContentConstructorMap = new HashMap<>();
        mMainHandler = new Handler(Looper.getMainLooper());
    }

    private static class SingleHolder {
        static RCIMFlutterWrapper instance = new RCIMFlutterWrapper();
    }

    public static RCIMFlutterWrapper getInstance() {
        return SingleHolder.instance;
    }

    public void saveContext(Context context) {
        mContext = context;
    }

    public void saveChannel(MethodChannel channel) {
        mChannel = channel;
    }

    public void onFlutterMethodCall(MethodCall call, Result result) {
        if(RCMethodList.MethodKeyInit.equalsIgnoreCase(call.method)) {
            initRCIM(call.arguments);
        }else if (RCMethodList.MethodKeyConfig.equalsIgnoreCase(call.method)) {
            config(call.arguments);
        }else if (RCMethodList.MethodKeySetServerInfo.equalsIgnoreCase(call.method)){
            setServerInfo(call.arguments);
        }else if (RCMethodList.MethodKeyConnect.equalsIgnoreCase(call.method)){
            connect(call.arguments,result);
        }else if (RCMethodList.MethodKeyDisconnect.equalsIgnoreCase(call.method)) {
            disconnect(call.arguments);
        }else if (RCMethodList.MethodKeyRefrechUserInfo.equalsIgnoreCase(call.method)) {
            refreshUserInfo(call.arguments);
        }else if (RCMethodList.MethodKeySendMessage.equalsIgnoreCase(call.method)) {
            sendMessage(call.arguments,result);
        }else if (RCMethodList.MethodKeyJoinChatRoom.equalsIgnoreCase(call.method)) {
            joinChatRoom(call.arguments);
        }else if (RCMethodList.MethodKeyQuitChatRoom.equalsIgnoreCase(call.method)) {
            quitChatRoom(call.arguments);
        }else if (RCMethodList.MethodKeyGetHistoryMessage.equalsIgnoreCase(call.method)) {
            getHistoryMessage(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetConversationList.equalsIgnoreCase(call.method)) {
            getConversationList(result);
        }else if (RCMethodList.MethodKeyGetChatRoomInfo.equalsIgnoreCase(call.method)) {
            getChatRoomInfo(call.arguments,result);
        }else if (RCMethodList.MethodKeyClearMessagesUnreadStatus.equalsIgnoreCase(call.method)) {
            clearMessagesUnreadStatus(call.arguments,result);
        }else if (RCMethodList.MethodKeySetCurrentUserInfo.equalsIgnoreCase(call.method)) {
            setCurrentUserInfo(call.arguments);
        }else if (RCMethodList.MethodKeyInsertIncomingMessage.equalsIgnoreCase(call.method)) {
            insertIncomingMessage(call.arguments,result);
        }else if (RCMethodList.MethodKeyInsertOutgoingMessage.equalsIgnoreCase(call.method)) {
            insertOutgoingMessage(call.arguments,result);
        }else if (RCMethodList.MethodCallBackKeygetRemoteHistoryMessages.equalsIgnoreCase(call.method)) {
            getRemoteHistoryMessages(call.arguments);
        }else if (RCMethodList.MethodKeyGetTotalUnreadCount.equalsIgnoreCase(call.method)) {
            getTotalUnreadCount(result);
        }else if (RCMethodList.MethodKeyGetUnreadCountTargetId.equalsIgnoreCase(call.method)) {
            getUnreadCountTargetId(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetUnreadCountConversationTypeList.equalsIgnoreCase(call.method)) {
            getUnreadCountConversationTypeList(call.arguments,result);
        }
    }


    //private method
    private void initRCIM(Object arg) {
        if(arg instanceof String) {
            String appkey = String.valueOf(arg);
            RongIM.init(mContext,appkey);
        }else {
            Log.e("RCIM flutter init", "非法参数");
        }
    }

    private void config(Object arg) {
        if(arg instanceof Map) {
            Map conf = (Map)arg;
            RCFlutterConfig config = new RCFlutterConfig();
            config.updateConf(conf);
            mConfig = config;

            updateIMConfig();

            RongIM.setUserInfoProvider(new RCFlutterIMInfoProvider() ,config.isEnablePersistentUserInfoCache());
        }else {

        }
    }

    private void setServerInfo(Object arg) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            String naviServer = (String)map.get("naviServer");
            String fileServer = (String)map.get("fileServer");
            RongIMClient.setServerInfo(naviServer,fileServer);
        }
    }

    private void connect(Object arg, final Result result) {
        if(arg instanceof String) {
            String token = String.valueOf(arg);
            RongIM.connect(token, new RongIMClient.ConnectCallback() {
                @Override
                public void onTokenIncorrect() {
                    result.success(new Integer(31004));
                }

                @Override
                public void onSuccess(String s) {
                    result.success(new Integer(0));
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(new Integer(errorCode.getValue()));
                }
            });

            fetchAllMessageMapper();
            setReceiveMessageListener();
        }else {

        }
    }

    private void disconnect(Object arg) {
        if(arg instanceof Boolean) {
            boolean needPush = (boolean)arg;
            if(needPush) {
                RongIM.getInstance().disconnect();
            }else {
                RongIM.getInstance().logout();
            }
        }
    }

    private void refreshUserInfo(Object arg) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            String userId = (String) map.get("userId");
            String name = (String)map.get("name");
            String portraitUri = (String) map.get("portraitUrl");
            UserInfo userInfo = new UserInfo(userId,name, Uri.parse(portraitUri));
            RongIM.getInstance().refreshUserInfoCache(userInfo);
        }else {

        }
    }

    /// 未实现此方法 imlib 层没有此方法
    private void setCurrentUserInfo(Object arg) {
        if (arg instanceof Map) {
            Map map = (Map)arg;
            String userId = (String) map.get("userId");
            String name = (String)map.get("name");
            String portraitUri = (String) map.get("portraitUrl");
            UserInfo userInfo = new UserInfo(userId, name, Uri.parse(portraitUri));
        }
    }

    private void sendMessage(Object arg, final Result result) {
        if(arg instanceof  Map) {
            Map map = (Map)arg;
            String objectName = (String)map.get("objectName");
            if(isMediaMessage(objectName)) {
                sendMediaMessage(arg,result);
                return;
            }
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            String contentStr = (String)map.get("content");

            byte[] bytes = contentStr.getBytes() ;

            MessageContent content = null;
            if(isVoiceMessage(objectName)) {
                JSONObject jsonObject = null;
                try {
                    jsonObject = new JSONObject(contentStr);
                    String localPath = jsonObject.getString("localPath");
                    int duration = jsonObject.getInt("duration");
                    Uri uri = Uri.parse(localPath);
                    content = VoiceMessage.obtain(uri,duration);
                } catch (JSONException e) {
                    //do nothing
                }
            }else {
                content = newMessageContent(objectName,bytes);
            }

            if(content == null) {
                Log.e("该消息无法构建",map.toString());
                result.success(null);
                return;
            }

            Message message = RongIM.getInstance().sendMessage(type, targetId, content, null, null, new RongIMClient.SendMessageCallback() {
                @Override
                public void onError(Integer messageId, RongIMClient.ErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",messageId);
                    resultMap.put("status",20);
                    resultMap.put("code",errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }

                @Override
                public void onSuccess(Integer messageId) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",messageId);
                    resultMap.put("status",30);
                    resultMap.put("code",0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }
            });

            String messageS = MessageFactory.getInstance().message2String(message);
            Map msgMap = new HashMap();
            msgMap.put("message",messageS);
            msgMap.put("status",10);
            result.success(msgMap);
        }
    }

    private void sendMediaMessage(Object arg, final Result result) {
        if(arg instanceof  Map) {
            Map map = (Map)arg;
            String objectName = (String)map.get("objectName");
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            String contentStr = (String)map.get("content");


            MessageContent content = null;
            if(objectName.equalsIgnoreCase("RC:ImgMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath =  (String)jsonObject.get("localPath");
                    Uri uri = Uri.parse(localPath);
                    content = ImageMessage.obtain(uri,uri,true);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }else {

            }

            if(content == null) {
                Log.e("sendMediaMessage","不支持该消息类型");
                return;
            }

            RongIM.getInstance().sendImageMessage(type, targetId, content, null, null, new SendImageMessageCallback() {
                @Override
                public void onAttached(Message message) {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map msgMap = new HashMap();
                    msgMap.put("message",messageS);
                    msgMap.put("status",10);
                    result.success(msgMap);
                }

                @Override
                public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",message.getMessageId());
                    resultMap.put("status",20);
                    resultMap.put("code",errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }

                @Override
                public void onSuccess(Message message) {
                    if(message == null) {
                        result.success(null);
                        return;
                    }
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",message.getMessageId());
                    resultMap.put("status",30);
                    resultMap.put("code",0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }

                @Override
                public void onProgress(Message message, int i) {
                    Map map = new HashMap();
                    map.put("messageId",message.getMessageId());
                    map.put("progress",i);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyUploadMediaProgress,map);
                }
            });
        }
    }

    private void joinChatRoom(Object arg) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            final String targetId = (String)map.get("targetId");
            int msgCount = (int)map.get("messageCount");
            RongIMClient.getInstance().joinChatRoom(targetId, msgCount, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom,callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",1);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom,callBackMap);
                }
            });
        }
    }

    private void quitChatRoom(Object arg) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            final String targetId = (String)map.get("targetId");
            RongIMClient.getInstance().quitChatRoom(targetId, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom,callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",1);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom,callBackMap);
                }
            });
        }
    }

    private void getHistoryMessage(Object arg, final Result result) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            final Integer messageId = (Integer)map.get("messageId");
            Integer count = (Integer)map.get("count");
            RongIM.getInstance().getHistoryMessages(type, targetId, messageId, count, new RongIMClient.ResultCallback<List<Message>>() {
                @Override
                public void onSuccess(List<Message> messages) {
                    if(messages == null) {
                        result.success(null);
                        return;
                    }
                    List list = new ArrayList();
                    for(Message msg : messages) {
                        String messageS = MessageFactory.getInstance().message2String(msg);
                        list.add(messageS);
                    }
                    result.success(list);

                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(null);
                }
            });
        }
    }

    private void getConversationList(final Result result) {
        RongIM.getInstance().getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
            @Override
            public void onSuccess(List<Conversation> conversations) {
                if(conversations == null) {
                    result.success(null);
                    return ;
                }
                List l = new ArrayList();
                for(Conversation con : conversations) {
                    String conStr = MessageFactory.getInstance().conversation2String(con);
                    l.add(conStr);
                }
                result.success(l);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                result.success(null);
            }
        });
    }

    private void getChatRoomInfo(Object arg, final Result result) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            String targetId = (String)map.get("targetId");
            Integer memberCount = (Integer)map.get("memeberCount");
            Integer order = (Integer)map.get("memberOrder");
            ChatRoomInfo.ChatRoomMemberOrder memberOrder = ChatRoomInfo.ChatRoomMemberOrder.RC_CHAT_ROOM_MEMBER_ASC;
            if(order.intValue() == 2) {
                memberOrder = ChatRoomInfo.ChatRoomMemberOrder.RC_CHAT_ROOM_MEMBER_DESC;
            }
            RongIMClient.getInstance().getChatRoomInfo(targetId, memberCount.intValue(), memberOrder, new RongIMClient.ResultCallback<ChatRoomInfo>() {
                @Override
                public void onSuccess(ChatRoomInfo chatRoomInfo) {
                    if(chatRoomInfo == null) {
                        result.success(null);
                        return;
                    }
                    Map resultMap = MessageFactory.getInstance().chatRoom2Map(chatRoomInfo);
                    result.success(resultMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(null);
                }
            });
        }
    }

    private void clearMessagesUnreadStatus(Object arg,final Result result) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            RongIM.getInstance().clearMessagesUnreadStatus(type, targetId, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    result.success(true);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(false);
                }
            });

        }
    }



    private void getUnreadCountConversationTypeList(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map)arg;
            List conversationTypeList = (List)map.get("conversationTypeList");
            boolean isContain = (boolean)map.get("isContain");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i=0;i<conversationTypeList.size();i++) {
                Integer t = (Integer)conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongIMClient.getInstance().getUnreadCount(types, isContain, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    Map msgMap = new HashMap();
                    msgMap.put("count",integer);
                    msgMap.put("code",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map msgMap = new HashMap();
                    msgMap.put("count",0);
                    msgMap.put("code",errorCode);
                    result.success(msgMap);
                }
            });

        }
    }

    private void getUnreadCountTargetId(Object arg,final Result result) {
        if (arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");

            RongIMClient.getInstance().getUnreadCount(type, targetId, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    Map msgMap = new HashMap();
                    msgMap.put("count",integer);
                    msgMap.put("code",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map msgMap = new HashMap();
                    msgMap.put("count",0);
                    msgMap.put("code",errorCode);
                    result.success(msgMap);
                }
            });
        }
    }
    private void getTotalUnreadCount(final Result result) {
        RongIMClient.getInstance().getTotalUnreadCount(new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                Map msgMap = new HashMap();
                msgMap.put("count",integer);
                msgMap.put("code",0);
                result.success(msgMap);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                Map msgMap = new HashMap();
                msgMap.put("count",0);
                msgMap.put("code",errorCode);
                result.success(msgMap);
            }
        });
    }

    private void insertOutgoingMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map)arg;
            String objectName = (String)map.get("objectName");
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            Integer st = (Integer) map.get("sendStatus");
            Message.SentStatus sendStatus = Message.SentStatus.setValue(st.intValue());
            Long sendTime = (Long)map.get("sendTime");

            String contentStr = (String)map.get("content");

            byte[] bytes = contentStr.getBytes();
            MessageContent content = null;
            if (isVoiceMessage(objectName)) {
                JSONObject jsonObject = null;
                try {
                    jsonObject = new JSONObject();
                    String localPath = jsonObject.getString("localPath");
                    int duration = jsonObject.getInt("duration");
                    Uri uri = Uri.parse(localPath);
                    content = VoiceMessage.obtain(uri,duration);
                } catch (JSONException e) {

                }
            } else {
                content = newMessageContent(objectName,bytes);
            }

            if (content == null) {
                Log.e("该消息无法构建", map.toString());
                return;
            }

            RongIMClient.getInstance().insertOutgoingMessage(type, targetId, sendStatus, content, new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map msgMap = new HashMap();
                    msgMap.put("message",messageS);
                    msgMap.put("status",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map msgMap = new HashMap();
                    msgMap.put("status",errorCode);
                    result.success(msgMap);
                }
            });

        }
    }

    private void insertIncomingMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map)arg;
            String objectName = (String)map.get("objectName");
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            Integer st = (Integer)map.get("receivedStatus");
            Message.ReceivedStatus receivedStatus = new Message.ReceivedStatus(st);
            String senderUserId = (String)map.get("senderUserId");
            Long sendTime = (Long)map.get("sendTime");

            String contentStr = (String)map.get("content");

            byte[] bytes = contentStr.getBytes();
            MessageContent content = null;
            if (isVoiceMessage(objectName)) {
                JSONObject jsonObject = null;
                try {
                    jsonObject = new JSONObject();
                    String localPath = jsonObject.getString("localPath");
                    int duration = jsonObject.getInt("duration");
                    Uri uri = Uri.parse(localPath);
                    content = VoiceMessage.obtain(uri,duration);
                } catch (JSONException e) {

                }
            } else {
                content = newMessageContent(objectName,bytes);
            }

            if (content == null) {
                Log.e("该消息无法构建", map.toString());
                return;
            }

            RongIMClient.getInstance().insertIncomingMessage(type, targetId, senderUserId, receivedStatus, content, sendTime, new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map msgMap = new HashMap();
                    msgMap.put("message",messageS);
                    msgMap.put("status",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map msgMap = new HashMap();
                    msgMap.put("status",errorCode);
                    result.success(msgMap);
                }
            });
        }
    }

    private void fetchAllMessageMapper(){

        RongIMClient client = RongIMClient.getInstance();
        Field field = null;
        try {
            field = client.getClass().getDeclaredField("mRegCache");
            field.setAccessible(true);
            List<String> mRegCache = (List)field.get(client);
            for(String className : mRegCache) {
                registerMessageType(className);
            }
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }

    //util method
    public void updateIMConfig() {
        //后续 RCFlutterConfig 如果有什么参数，可以在此同步给 RongIM
    }

    //RongIM UserInfoProvider
    private class RCFlutterIMInfoProvider implements RongIM.UserInfoProvider {
        @Override
        public UserInfo getUserInfo(String s) {
            mChannel.invokeMethod(RCMethodList.MethodCallBackKeyRefrechUserInfo,s);
            return null;
        }
    }

    private void setReceiveMessageListener() {

        RongIM.setOnReceiveMessageListener(new RongIMClient.OnReceiveMessageListener() {
            @Override
            public boolean onReceived(final Message message,final int i) {

                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        String messageS = MessageFactory.getInstance().message2String(message);
                        final Map map = new HashMap();
                        map.put("message",messageS);
                        map.put("left",i);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackKeyReceiveMessage,map);
                    }
                });

                return false;
            }
        });
    }

    private boolean isMediaMessage(String objName) {
        if(objName.equalsIgnoreCase("RC:ImgMsg")) {
            return true;
        }
        return false;
    }

    private boolean isVoiceMessage(String objName) {
        if(objName.equalsIgnoreCase("RC:VcMsg")) {
            return true;
        }
        return false;
    }

    public void registerMessageType(String className) {
        try {
            Class<? extends MessageContent> msgType = (Class<? extends MessageContent>) Class.forName(className);
            MessageTag tag = msgType.getAnnotation(MessageTag.class);
            if (tag != null) {
                String objName = tag.value();
                Constructor<? extends MessageContent> constructor = msgType.getDeclaredConstructor(byte[].class);
                Constructor<? extends MessageHandler> handlerConstructor = tag.messageHandler().getConstructor(Context.class);
                MessageHandler messageHandler = handlerConstructor.newInstance(mContext);
                messageContentConstructorMap.put(objName, constructor);
            }

        } catch (Exception e) {
            FwLog.write(FwLog.E, FwLog.MSG, "L-register_type-S", "class_name", className);
            StringWriter stringWriter = new StringWriter();
            PrintWriter printWriter = new PrintWriter(stringWriter);
            e.printStackTrace(printWriter);
        }catch (Throwable throwable) {
            FwLog.write(FwLog.E, FwLog.MSG, "L-regtype-E", null);
        }
    }

    private MessageContent newMessageContent(String objectName, byte[] content) {
        Constructor<? extends MessageContent> constructor = messageContentConstructorMap.get(objectName);
        MessageContent result = null;

        if (constructor == null || content == null) {
            return new UnknownMessage(content);
        }
        try {
            result = constructor.newInstance(content);
        } catch (Exception e) {
            // FwLog TBC.
            result = new UnknownMessage(content);
            FwLog.write(FwLog.F, FwLog.MSG, "L-decode_msg-E", "msg_type|stacks", objectName, FwLog.stackToString(e));
        }
        return result;
    }

    public void getRemoteHistoryMessages(Object arg){
        if (arg instanceof Map) {
            final Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            final String targetId = (String)map.get("targetId");
            Integer recordTime = (Integer)map.get("recordTime");
            Integer count = (Integer)map.get("count");

            RongIMClient.getInstance().getRemoteHistoryMessages(type, targetId, recordTime, count, new RongIMClient.ResultCallback<List<Message>>() {
                @Override
                public void onSuccess(List<Message> messages) {
                    if(messages == null) {
                        Map callBackMap = new HashMap();
                        callBackMap.put("code",0);
                        callBackMap.put("messages",null);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackKeygetRemoteHistoryMessages,callBackMap);
                        return;
                    }
                    List list = new ArrayList();
                    for(Message msg : messages) {
                        String messageS = MessageFactory.getInstance().message2String(msg);
                        list.add(messageS);
                    }
                    Map callBackMap = new HashMap();
                    callBackMap.put("code",0);
                    callBackMap.put("messages",list);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeygetRemoteHistoryMessages,callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map callBackMap = new HashMap();
                    callBackMap.put("code",errorCode);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeygetRemoteHistoryMessages,callBackMap);
                }
            });
        }
    }

}
