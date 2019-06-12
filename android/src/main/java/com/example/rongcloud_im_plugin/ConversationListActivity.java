package com.example.rongcloud_im_plugin;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import java.util.Locale;

import io.rong.imkit.RongIM;
import io.rong.imkit.model.UIConversation;
import io.rong.imlib.model.Conversation;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

public class ConversationListActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.conversationlist);
        RongIM.setConversationListBehaviorListener(new RCFlutterConversationListBehaviorListener());
    }

    private  class RCFlutterConversationListBehaviorListener implements RongIM.ConversationListBehaviorListener {

        @Override
        public boolean onConversationPortraitClick(Context context, Conversation.ConversationType conversationType, String s) {
            return false;
        }

        @Override
        public boolean onConversationPortraitLongClick(Context context, Conversation.ConversationType conversationType, String s) {
            return false;
        }

        @Override
        public boolean onConversationLongClick(Context context, View view, UIConversation uiConversation) {
            return false;
        }

        @Override
        public boolean onConversationClick(Context context, View view, UIConversation uiConversation) {
            Conversation.ConversationType type = uiConversation.getConversationType();
            String targetId = uiConversation.getConversationTargetId();
            Uri uri = Uri.parse("rong://" + "com.example.rongcloud_im_plugin").buildUpon()
                    .appendPath("conversation").appendPath(type.getName().toLowerCase(Locale.US))
                    .appendQueryParameter("targetId", targetId).appendQueryParameter("title", "").build();
            Intent intent = new Intent(Intent.ACTION_VIEW, uri);
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        }
    }
}
