package com.example.rongcloud_im_plugin;

import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.content.Intent;
import android.view.View;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import io.rong.imkit.fragment.ConversationFragment;
import io.rong.imlib.model.Conversation;

public class ChatView implements PlatformView {

//    private final Fragment conversationFragment;
    private final ConversationFragment conversationFragment;


    ChatView(Context context, BinaryMessenger messenger, int viewId, Map<String, Object> params) {
        Integer t = (Integer)params.get("conversationType");
        Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
        String targetId = (String)params.get("targetId");

        conversationFragment = new ConversationFragment();
//        conversationFragment.onCreate(null);

//        conversationFragment.onCreateView(null,null,null);
//        ChatViewActivity chatViewActivity = new ChatViewActivity();
//        FragmentManager fragmentManager = chatViewActivity.getFragmentManager();
//        conversationFragment =  fragmentManager.findFragmentById(R.id.conversation);


//        conversationFragment = chatViewActivity.getFragmentManager();
//        conversationFragment = new ConversationFragmentEX();

//        Uri uri = Uri.parse("rong://" + "com.example.rongcloud_im_plugin").buildUpon()
//                .appendPath("conversation").appendPath(type.getName().toLowerCase())
//                .appendQueryParameter("targetId", targetId).build();
//
//        conversationFragment.setUri(uri);

    }

    @Override
    public View getView() {
        return conversationFragment.getView();
    }

    @Override
    public void dispose() {

    }
}
