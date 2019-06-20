package com.example.rongcloud_im_plugin;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import io.rong.imkit.fragment.ConversationFragment;
import io.rong.imlib.model.Conversation;

public class ConversationActivity extends Activity {
    private ConversationFragment conversationFragment;
    private Conversation.ConversationType type;
    private String targetId;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.conversation);
    }

    public void initFragment() {
        conversationFragment = new ConversationFragment();
        Uri uri = Uri.parse("rong://" + "com.example.rongcloud_im_plugin").buildUpon()
                .appendPath("conversation").appendPath(type.getName().toLowerCase())
                .appendQueryParameter("targetId", targetId).build();

        conversationFragment.setUri(uri);

//        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
//        //xxx 为你要加载的 id
//        transaction.add(R.id.conversation, conversationFragment);
//        transaction.commitAllowingStateLoss();
    }

}
