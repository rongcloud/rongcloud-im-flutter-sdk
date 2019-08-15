package com.example.rongcloud_im_plugin;
import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;


import org.json.JSONException;
import org.json.JSONObject;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.common.fwlog.FwLog;
import io.rong.imlib.IRongCallback;
import io.rong.imlib.MessageTag;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UnknownMessage;
import io.rong.imlib.model.UserInfo;
import io.rong.message.HQVoiceMessage;
import io.rong.message.ImageMessage;
import io.rong.message.MessageHandler;
import io.rong.message.VoiceMessage;


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
        }else if (RCMethodList.MethodKeyGetMessage.equalsIgnoreCase(call.method)) {
            getMessage(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetConversationList.equalsIgnoreCase(call.method)) {
            getConversationList(call.arguments,result);
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
            getRemoteHistoryMessages(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetTotalUnreadCount.equalsIgnoreCase(call.method)) {
            getTotalUnreadCount(result);
        }else if (RCMethodList.MethodKeyGetUnreadCountTargetId.equalsIgnoreCase(call.method)) {
            getUnreadCountTargetId(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetUnreadCountConversationTypeList.equalsIgnoreCase(call.method)) {
            getUnreadCountConversationTypeList(call.arguments,result);
        }else if (RCMethodList.MethodKeySetConversationNotificationStatus.equalsIgnoreCase(call.method)) {
            setConversationNotificationStatus(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetConversationNotificationStatus.equalsIgnoreCase(call.method)) {
            getConversationNotificationStatus(call.arguments,result);
        }else if (RCMethodList.MethodKeyRemoveConversation.equalsIgnoreCase(call.method)) {
            removeConversation(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetBlockedConversationList.equalsIgnoreCase(call.method)) {
            getBlockedConversationList(call.arguments,result);
        }else if (RCMethodList.MethodKeySetConversationToTop.equalsIgnoreCase(call.method)) {
            setConversationToTop(call.arguments,result);
        }else if (RCMethodList.MethodKeyGetTopConversationList.equalsIgnoreCase(call.method)) {
//            getTopConversationList(call.arguments,result);
        }else if(RCMethodList.MethodKeyDeleteMessages.equalsIgnoreCase(call.method)) {
            deleteMessages(call.arguments,result);
        }else if(RCMethodList.MethodKeyDeleteMessageByIds.equalsIgnoreCase(call.method)) {
            deleteMessageByIds(call.arguments,result);
        }
        else {
            result.notImplemented();
        }

    }



    //private method
    private void initRCIM(Object arg) {
        String LOG_TAG = "init";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof String) {
            String appkey = String.valueOf(arg);
            RongIMClient.init(mContext,appkey);


            setReceiveMessageListener();
            setConnectStatusListener();
        }else {
            Log.e("RCIM flutter init", "非法参数");
        }
    }

    private void config(Object arg) {
        String LOG_TAG = "config";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof Map) {
            Map conf = (Map)arg;
            RCFlutterConfig config = new RCFlutterConfig();
            config.updateConf(conf);
            mConfig = config;

            updateIMConfig();

        }else {

        }
    }

    private void setServerInfo(Object arg) {
        String LOG_TAG = "setServerInfo";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            String naviServer = (String)map.get("naviServer");
            String fileServer = (String)map.get("fileServer");
            RongIMClient.setServerInfo(naviServer,fileServer);
        }
    }

    private void connect(Object arg, final Result result) {
        String LOG_TAG = "connect";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof String) {
            String token = String.valueOf(arg);
            RongIMClient.connect(token, new RongIMClient.ConnectCallback() {
                @Override
                public void onTokenIncorrect() {
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            RCLog.e("connect "+String.valueOf(31004));
                            result.success(new Integer(31004));
                        }
                    });
                }

                @Override
                public void onSuccess(String s) {
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            RCLog.i("connect success");
                            result.success(new Integer(0));
                        }
                    });
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    final RongIMClient.ErrorCode code = errorCode;
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            RCLog.e("connect "+String.valueOf(code.getValue()));
                            result.success(new Integer(code.getValue()));
                        }
                    });

                }
            });

            fetchAllMessageMapper();
        }else {

        }
    }

    private void disconnect(Object arg) {
        String LOG_TAG = "disconnect";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof Boolean) {
            boolean needPush = (boolean)arg;
            if(needPush) {
                RongIMClient.getInstance().disconnect();
            }else {
                RongIMClient.getInstance().logout();
            }
        }
    }

    private void refreshUserInfo(Object arg) {
//        if(arg instanceof Map) {
//            Map map = (Map)arg;
//            String userId = (String) map.get("userId");
//            String name = (String)map.get("name");
//            String portraitUri = (String) map.get("portraitUrl");
//            UserInfo userInfo = new UserInfo(userId,name, Uri.parse(portraitUri));
//            RongIMClient.getInstance().refreshUserInfoCache(userInfo);
//        }else {
//
//        }
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
            final String LOG_TAG = "sendMessage";
            RCLog.i(LOG_TAG+" start param:"+arg.toString());
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
                RCLog.e(LOG_TAG+" message content is nil");
                result.success(null);
                return;
            }

            Message message = RongIMClient.getInstance().sendMessage(type, targetId, content, null, null, new RongIMClient.SendMessageCallback() {
                @Override
                public void onError(Integer messageId, RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+" content is nil");
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",messageId);
                    resultMap.put("status",20);
                    resultMap.put("code",errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }

                @Override
                public void onSuccess(Integer messageId) {
                    RCLog.e(LOG_TAG+" success");
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
        final String LOG_TAG = "sendMediaMessage";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
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

                    Object o = jsonObject.get("extra");//设置 extra
                    if(o instanceof String) {
                        String extra = (String)o;
                        ((ImageMessage) content).setExtra(extra);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else if (objectName.equalsIgnoreCase("RC:HQVCMsg")){
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath =  (String)jsonObject.get("localPath");
                    Uri uri = Uri.parse(localPath);
                    int duration = (Integer) jsonObject.get("duration");
                    content = HQVoiceMessage.obtain(uri,duration);

                    Object o = jsonObject.get("extra");//设置 extra
                    if(o instanceof String) {
                        String extra = (String)o;
                        ((HQVoiceMessage) content).setExtra(extra);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {

            }

            if(content == null) {
                RCLog.e(LOG_TAG+" message content is nil");
                return;
            }

            Message message = Message.obtain(targetId,type,content);
            RongIMClient.getInstance().sendMediaMessage(message, null, null, new IRongCallback.ISendMediaMessageCallback() {
                @Override
                public void onProgress(Message message, int i) {
                    Map map = new HashMap();
                    map.put("messageId",message.getMessageId());
                    map.put("progress",i);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyUploadMediaProgress,map);
                }

                @Override
                public void onCanceled(Message message) {

                }

                @Override
                public void onAttached(Message message) {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map msgMap = new HashMap();
                    msgMap.put("message",messageS);
                    msgMap.put("status",10);
                    result.success(msgMap);
                }

                @Override
                public void onSuccess(Message message) {
                    if(message == null) {
                        RCLog.e(LOG_TAG+" message is nil");
                        result.success(null);
                        return;
                    }
                    RCLog.i(LOG_TAG+" success");
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",message.getMessageId());
                    resultMap.put("status",30);
                    resultMap.put("code",0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }

                @Override
                public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+ String.valueOf(errorCode.getValue()));
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",message.getMessageId());
                    resultMap.put("status",20);
                    resultMap.put("code",errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }
            });
        }
    }

    private void joinChatRoom(Object arg) {
        final String LOG_TAG = "joinChatRoom";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            final String targetId = (String)map.get("targetId");
            int msgCount = (int)map.get("messageCount");
            RongIMClient.getInstance().joinChatRoom(targetId, msgCount, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i(LOG_TAG+" success ");
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom,callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",1);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom,callBackMap);
                }
            });
        }
    }

    private void quitChatRoom(Object arg) {
        final String LOG_TAG = "quitChatRoom";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            final String targetId = (String)map.get("targetId");
            RongIMClient.getInstance().quitChatRoom(targetId, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i(LOG_TAG+" success ");
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom,callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId",targetId);
                    callBackMap.put("status",1);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom,callBackMap);
                }
            });
        }
    }

    private void getHistoryMessage(Object arg, final Result result) {
        final String LOG_TAG = "quitChatRoom";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            final Integer messageId = (Integer)map.get("messageId");
            Integer count = (Integer)map.get("count");
            RongIMClient.getInstance().getHistoryMessages(type, targetId, messageId, count, new RongIMClient.ResultCallback<List<Message>>() {
                @Override
                public void onSuccess(List<Message> messages) {
                    RCLog.i(LOG_TAG+" success ");
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
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            });
        }
    }

    private void getMessage(Object arg, final Result result) {
        final String LOG_TAG = "getMessage";
        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer mId = (Integer)map.get("messageId");
            RongIMClient.getInstance().getMessage(mId.intValue(), new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    RCLog.i(LOG_TAG+" success ");
                    String messageS = MessageFactory.getInstance().message2String(message);
                    result.success(messageS);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            });
        }
    }

    private void getConversationList(Object arg, final Result result) {
        final String LOG_TAG = "getConversationList";
        RCLog.i(LOG_TAG+" start ");
        if (arg instanceof Map) {
            Map map = (Map)arg;
            List conversationTypeList = (List)map.get("conversationTypeList");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i=0;i<conversationTypeList.size();i++) {
                Integer t = (Integer)conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongIMClient.getInstance().getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
                @Override
                public void onSuccess(List<Conversation> conversations) {
                    RCLog.i(LOG_TAG+" success ");
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
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            },types);
        }

    }

    private void getChatRoomInfo(Object arg, final Result result) {
        final String LOG_TAG = "getChatRoomInfo";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
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
                    RCLog.i(LOG_TAG+" success");
                    if(chatRoomInfo == null) {
                        result.success(null);
                        return;
                    }
                    Map resultMap = MessageFactory.getInstance().chatRoom2Map(chatRoomInfo);
                    result.success(resultMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            });
        }
    }

    private void clearMessagesUnreadStatus(Object arg,final Result result) {
        final String LOG_TAG = "clearMessagesUnreadStatus";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            RongIMClient.getInstance().clearMessagesUnreadStatus(type, targetId, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG+" success");
                    result.success(true);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    result.success(false);
                }
            });

        }
    }



    private void getUnreadCountConversationTypeList(Object arg, final Result result) {
        final String LOG_TAG = "getUnreadCountConversationTypeList";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
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
                    RCLog.i(LOG_TAG+" success");
                    Map msgMap = new HashMap();
                    msgMap.put("count",integer);
                    msgMap.put("code",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("count",0);
                    msgMap.put("code",errorCode.getValue());
                    result.success(msgMap);
                }
            });

        }
    }

    private void getUnreadCountTargetId(Object arg,final Result result) {
        final String LOG_TAG = "getUnreadCountTargetId";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");

            RongIMClient.getInstance().getUnreadCount(type, targetId, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    RCLog.i(LOG_TAG+" success");
                    Map msgMap = new HashMap();
                    msgMap.put("count",integer);
                    msgMap.put("code",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("count",0);
                    msgMap.put("code",errorCode.getValue());
                    result.success(msgMap);
                }
            });
        }
    }
    private void getTotalUnreadCount(final Result result) {
        final String LOG_TAG = "getTotalUnreadCount";
        RCLog.i(LOG_TAG+" start ");
        RongIMClient.getInstance().getTotalUnreadCount(new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                RCLog.i(LOG_TAG+" success");
                Map msgMap = new HashMap();
                msgMap.put("count",integer);
                msgMap.put("code",0);
                result.success(msgMap);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                Map msgMap = new HashMap();
                msgMap.put("count",0);
                msgMap.put("code",errorCode.getValue());
                result.success(msgMap);
            }
        });
    }

    private void insertOutgoingMessage(Object arg, final Result result) {
        final String LOG_TAG = "insertOutgoingMessage";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
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
                RCLog.e(LOG_TAG+" message content is null");
                Map msgMap = new HashMap();
                msgMap.put("code",RongIMClient.ErrorCode.PARAMETER_ERROR.getValue());
                result.success(msgMap);
                return;
            }
            RongIMClient.getInstance().insertOutgoingMessage(type, targetId, sendStatus, content, sendTime.longValue(), new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    RCLog.i(LOG_TAG+" success");
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map msgMap = new HashMap();
                    msgMap.put("message",messageS);
                    msgMap.put("code",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("code",errorCode.getValue());
                    result.success(msgMap);
                }
            });

        }
    }

    private void insertIncomingMessage(Object arg, final Result result) {
        final String LOG_TAG = "insertIncomingMessage";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            Map map = (Map)arg;
            String objectName = (String)map.get("objectName");
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            Integer st = (Integer)map.get("rececivedStatus");
            Message.ReceivedStatus receivedStatus = new Message.ReceivedStatus(st.intValue());
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
                RCLog.e(LOG_TAG+" message content is null");
                Map msgMap = new HashMap();
                msgMap.put("code",RongIMClient.ErrorCode.PARAMETER_ERROR.getValue());
                result.success(msgMap);
                return;
            }

            RongIMClient.getInstance().insertIncomingMessage(type, targetId, senderUserId, receivedStatus, content, sendTime.longValue(), new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    RCLog.i(LOG_TAG+" success");
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map msgMap = new HashMap();
                    msgMap.put("message",messageS);
                    msgMap.put("code",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("code",errorCode.getValue());
                    result.success(msgMap);
                }
            });
        }
    }

    public void getRemoteHistoryMessages(Object arg, final Result result){
        final String LOG_TAG = "getRemoteHistoryMessages";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            final Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            final String targetId = (String)map.get("targetId");
            Long recordTime = (Long)map.get("recordTime");
            Integer count = (Integer)map.get("count");

            RongIMClient.getInstance().getRemoteHistoryMessages(type, targetId, recordTime.longValue(), count, new RongIMClient.ResultCallback<List<Message>>() {
                @Override
                public void onSuccess(List<Message> messages) {
                    RCLog.i(LOG_TAG+" success");
                    if(messages == null) {
                        Map callBackMap = new HashMap();
                        callBackMap.put("code",0);
                        callBackMap.put("messages",new ArrayList());
                        result.success(callBackMap);
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
                    result.success(callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map callBackMap = new HashMap();
                    callBackMap.put("code",errorCode.getValue());
                    result.success(callBackMap);
                }
            });
        }
    }

    private void setConversationNotificationStatus(Object arg, final Result result) {
        final String LOG_TAG = "setConversationNotificationStatus";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            boolean isBlocked = (boolean)map.get("isBlocked");
            int blockValue = isBlocked ? 0 : 1;

            Conversation.ConversationNotificationStatus status = Conversation.ConversationNotificationStatus.setValue(blockValue);

            RongIMClient.getInstance().setConversationNotificationStatus(type, targetId, status, new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
                @Override
                public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                    RCLog.i(LOG_TAG+" success");
                    Map msgMap = new HashMap();
                    msgMap.put("status",conversationNotificationStatus);
                    msgMap.put("code",0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("code",errorCode.getValue());
                    result.success(msgMap);
                }
            });
        }

    }

    private void getConversationNotificationStatus(Object arg, final Result result) {
        final String LOG_TAG = "getConversationNotificationStatus";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");

            RongIMClient.getInstance().getConversationNotificationStatus(type, targetId, new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
                @Override
                public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                    RCLog.i(LOG_TAG+" success");
                    Map msgMap = new HashMap();
                    msgMap.put("status", conversationNotificationStatus);
                    msgMap.put("code", 0);
                    result.success(msgMap);
                }

                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("code", errorCode.getValue());
                    result.success(msgMap);

                }
            });
        }
    }

    private void getBlockedConversationList(Object arg, final Result result) {
        final String LOG_TAG = "getBlockedConversationList";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List conversationTypeList = (List)map.get("conversationTypeList");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i=0;i<conversationTypeList.size();i++) {
                Integer t = (Integer)conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongIMClient.getInstance().getBlockedConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
                @Override
                public void onSuccess(List<Conversation> conversations) {
                    RCLog.i(LOG_TAG+" success");
                    if(conversations == null) {
                        result.success(null);
                        return ;
                    }
                    List l = new ArrayList();
                    for(Conversation con : conversations) {
                        String conStr = MessageFactory.getInstance().conversation2String(con);
                        l.add(conStr);
                    }

                    Map resultMap =  new HashMap();
                    resultMap.put("conversationList",l);
                    resultMap.put("code",0);
                    result.success(resultMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map resultMap =  new HashMap();
                    resultMap.put("code",errorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void setConversationToTop(Object arg, final Result result) {
        final String LOG_TAG = "setConversationToTop";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            boolean isTop = (boolean)map.get("isTop");

            RongIMClient.getInstance().setConversationToTop(type, targetId, isTop, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG+" success");
                    Map msgMap = new HashMap();
                    msgMap.put("status", aBoolean);
                    msgMap.put("code", 0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("code", errorCode.getValue());
                    result.success(msgMap);
                }
            });
        }
    }

    private void deleteMessages(Object arg, final Result result) {
        final String LOG_TAG = "deleteMessages";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof  Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongIMClient.getInstance().deleteMessages(type, targetId, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG+" success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+" error:"+errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void deleteMessageByIds(Object arg, final Result result) {
        final String LOG_TAG = "deleteMessageByIds";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if(arg instanceof  Map) {
            Map map = (Map) arg;
            List messageIds = (List)map.get("messageIds");

            int[] mIds = new int[messageIds.size()];
            for (int i=0;i<messageIds.size();i++) {
                int t = (int)messageIds.get(i);
                mIds[i] = t;
            }

            RongIMClient.getInstance().deleteMessages(mIds, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG+" success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+" error:"+errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

//    private void getTopConversationList(Object arg, final Result result)  {
//        if (arg instanceof Map) {
//            Map map = (Map) arg;
//            List conversationTypeList = (List)map.get("conversationTypeList");
//
//            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
//            for (int i=0;i<conversationTypeList.size();i++) {
//                Integer t = (Integer)conversationTypeList.get(i);
//                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
//                types[i] = type;
//            }
//
//            RongIMClient.getInstance().getBlockedConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
//                @Override
//                public void onSuccess(List<Conversation> conversations) {
//
//                    if(conversations == null) {
//                        result.success(null);
//                        return ;
//                    }
//                    List l = new ArrayList();
//                    for(Conversation con : conversations) {
//                        String conStr = MessageFactory.getInstance().conversation2String(con);
//                        l.add(conStr);
//                    }
//
//                    Map resultMap =  new HashMap();
//                    resultMap.put("conversationList",l);
//                    resultMap.put("code",0);
//                    result.success(resultMap);
//                }
//
//                @Override
//                public void onError(RongIMClient.ErrorCode errorCode) {
//                    Map resultMap =  new HashMap();
//                    resultMap.put("code",errorCode.getValue());
//                    result.success(resultMap);
//                }
//            });
//        }
//    }

    private void removeConversation(Object arg, final Result result)  {
        final String LOG_TAG = "removeConversation";
        RCLog.i(LOG_TAG+" start param:"+arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongIMClient.getInstance().removeConversation(type, targetId, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG+" success");
                    result.success(true);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG+String.valueOf(errorCode.getValue()));
                    result.success(false);
                }
            });
        }
    }


    //util
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


    private void setReceiveMessageListener() {

        RongIMClient.setOnReceiveMessageListener(new RongIMClient.OnReceiveMessageListener() {
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

    private void setConnectStatusListener() {
        RongIMClient.setConnectionStatusListener(new RongIMClient.ConnectionStatusListener() {
            @Override
            public void onChanged(ConnectionStatus connectionStatus) {
                final String LOG_TAG = "ConnectionStatusChanged";
                RCLog.i(LOG_TAG+" status:"+String.valueOf(connectionStatus.getValue()));
                Map map = new HashMap();
                map.put("status",connectionStatus.getValue());
                mChannel.invokeMethod(RCMethodList.MethodCallBackKeyConnectionStatusChange,map);
            }
        });
    }

    private boolean isMediaMessage(String objName) {
        if(objName.equalsIgnoreCase("RC:ImgMsg") || objName.equalsIgnoreCase("RC:HQVCMsg")) {
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

}
