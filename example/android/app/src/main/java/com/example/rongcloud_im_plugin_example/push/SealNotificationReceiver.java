package com.example.rongcloud_im_plugin_example.push;

import android.content.Context;
import android.content.Intent;

import com.example.rongcloud_im_plugin_example.MainActivity;

import io.rong.push.PushType;
import io.rong.push.notification.PushMessageReceiver;
import io.rong.push.notification.PushNotificationMessage;


/**
 * 通知广播， 可在此让法中进行通知消息处理和点击自定义跳转
 */
public class SealNotificationReceiver extends PushMessageReceiver {

    @Override
    public boolean onNotificationMessageArrived(Context context, PushType pushType, PushNotificationMessage message) {
        return false;
    }

    @Override
    public boolean onNotificationMessageClicked(Context context, PushType pushType, PushNotificationMessage message) {
        if (!message.getSourceType().equals(PushNotificationMessage.PushSourceType.FROM_ADMIN)) {
            String targetId = message.getTargetId();
            //根据自己需求填写点击跳转逻辑
            Intent intentMain = new Intent(context, MainActivity.class);
            intentMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intentMain);
        }
        return false;
    }

    @Override
    public void onThirdPartyPushState(PushType pushType, String action, long resultCode) {
        super.onThirdPartyPushState(pushType, action, resultCode);
    }
}
