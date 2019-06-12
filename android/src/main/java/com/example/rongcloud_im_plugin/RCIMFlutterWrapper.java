package com.example.rongcloud_im_plugin;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.imkit.RongIM;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.UserInfo;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;



public class RCIMFlutterWrapper {

    private static Context mContext = null;
    private static MethodChannel mChannel = null;
    private static RCFlutterConfig mConfig = null;

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

    //util method
    public void updateIMConfig() {
        //后续 RCFlutterConfig 如果有什么参数，可以在此同步给 RongIM
    }

    //RongIM UserInfoProvider
    private class RCFlutterIMInfoProvider implements RongIM.UserInfoProvider {
        @Override
        public UserInfo getUserInfo(String s) {
            mChannel.invokeMethod(RCMethodList.MethodKeyFetchUserInfo,s);
            return null;
        }
    }

}
