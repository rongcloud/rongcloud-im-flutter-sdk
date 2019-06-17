package com.example.rongcloud_im_plugin;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;


import org.json.JSONObject;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
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
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UnknownMessage;
import io.rong.imlib.model.UserInfo;
import io.rong.message.MessageHandler;
import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;


public class RCIMFlutterWrapper {

    private static Context mContext = null;
    private static MethodChannel mChannel = null;
    private static RCFlutterConfig mConfig = null;

    private HashMap<String, Constructor<? extends MessageContent>> messageContentConstructorMap;

    private RCIMFlutterWrapper() {
        messageContentConstructorMap = new HashMap<>();
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
        }else if(RCMethodList.MethodKeyConfig.equalsIgnoreCase(call.method)) {
            config(call.arguments);
        }else if(RCMethodList.MethodKeyConnect.equalsIgnoreCase(call.method)){
            connect(call.arguments,result);
        }else if(RCMethodList.MethodKeyPushToConversationList.equalsIgnoreCase(call.method)) {
            pushToConversationList(call.arguments);
        }else if(RCMethodList.MethodKeyPushToConversation.equalsIgnoreCase(call.method)) {
            pushToConversation(call.arguments);
        }else if(RCMethodList.MethodKeyRefrechUserInfo.equalsIgnoreCase(call.method)) {
            refreshUserInfo(call.arguments);
        }else if(RCMethodList.MethodKeySendMessage.equalsIgnoreCase(call.method)) {
            sendMessage(call.arguments,result);
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

    private void pushToConversationList(Object arg) {
        if(arg instanceof List) {
            List list = (List)arg;
            Map<String,Boolean> map = new HashMap<>();
            for(Object obj : list) {
                Integer t = Integer.parseInt(obj.toString());
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                map.put(type.getName(),false);
            }
            Uri.Builder builder = Uri.parse("rong://" + "com.example.rongcloud_im_plugin").buildUpon().appendPath("conversationlist");
            if (map != null && map.size() > 0) {
                Set<String> keys = map.keySet();
                Iterator var5 = keys.iterator();

                while(var5.hasNext()) {
                    String key = (String)var5.next();
                    builder.appendQueryParameter(key, (Boolean)map.get(key) ? "true" : "false");
                }
            }
            Intent intent = new Intent(Intent.ACTION_VIEW, builder.build());
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
            mContext.startActivity(intent);
        }else {

        }
    }

    private void pushToConversation(Object arg) {
        if(arg instanceof Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            Uri uri = Uri.parse("rong://" + "com.example.rongcloud_im_plugin").buildUpon()
                    .appendPath("conversation").appendPath(type.getName().toLowerCase(Locale.US))
                    .appendQueryParameter("targetId", targetId).appendQueryParameter("title", "").build();
            Intent intent = new Intent(Intent.ACTION_VIEW, uri);
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
            mContext.startActivity(intent);
        }else {

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

    private void sendMessage(Object arg, final Result result) {
        if(arg instanceof  Map) {
            Map map = (Map)arg;
            Integer t = (Integer)map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String)map.get("targetId");
            String contentStr = (String)map.get("content");
            String objectName = (String)map.get("objectName");

            byte[] bytes = contentStr.getBytes() ;

            MessageContent content = newMessageContent(objectName,bytes);

            Message message = RongIM.getInstance().sendMessage(type, targetId, content, null, null, new RongIMClient.SendMessageCallback() {
                @Override
                public void onError(Integer messageId, RongIMClient.ErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",messageId);
                    resultMap.put("status",20);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage,resultMap);
                }

                @Override
                public void onSuccess(Integer messageId) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId",messageId);
                    resultMap.put("status",30);
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
            public boolean onReceived(Message message, int i) {
                String messageS = MessageFactory.getInstance().message2String(message);
                Map map = new HashMap();
                map.put("message",messageS);
                map.put("left",i);
                mChannel.invokeMethod(RCMethodList.MethodCallBackKeyReceiveMessage,map);

                return false;
            }
        });
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
