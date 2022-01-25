package io.rong.flutter.imlib;

import android.os.Handler;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.rong.imlib.IRongCoreListener;
import io.rong.imlib.chatroom.base.RongChatRoomClient;
import io.rong.imlib.listener.OnReceiveMessageWrapperListener;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.ReceivedProfile;

/**
 * @author panmingda
 * @date 2022/1/17
 */
public class RCListenerImpl {

    public RCListenerImpl(MethodChannel channel, Handler handler) {
        this.channel = channel;
        this.handler = handler;

        receiveMessageWrapperListener = new ReceiveMessageWrapperListenerImpl();
        kvStatusListener = new KVStatusListenerImpl();
        connectionStatusListener = new ConnectionStatusListenerImpl();
    }

    class ReceiveMessageWrapperListenerImpl extends OnReceiveMessageWrapperListener {
        @Override
        public void onReceivedMessage(final Message message, final ReceivedProfile profile) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    final Map map = new HashMap();
                    map.put("message", messageS);
                    map.put("left", profile.getLeft());
                    map.put("offline", profile.isOffline());
                    map.put("hasPackage", profile.hasPackage());

                    channel.invokeMethod(RCMethodList.MethodCallBackKeyReceiveMessage, map);
                }
            });
        }
    }

    class KVStatusListenerImpl implements RongChatRoomClient.KVStatusListener {

        @Override
        public void onChatRoomKVSync(final String roomId) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    final Map<String, String> resultMap = new HashMap<>();
                    resultMap.put("roomId", roomId);
                    channel.invokeMethod(RCMethodList.MethodCallBackChatRoomKVDidSync, resultMap);
                }
            });
        }

        @Override
        public void onChatRoomKVUpdate(final String roomId, final Map<String, String> chatRoomKvMap) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    final Map<String, Object> resultMap = new HashMap<>();
                    resultMap.put("roomId", roomId);
                    resultMap.put("entry", chatRoomKvMap);
                    channel.invokeMethod(RCMethodList.MethodCallBackChatRoomKVDidUpdate, resultMap);
                }
            });
        }

        @Override
        public void onChatRoomKVRemove(final String roomId, final Map<String, String> chatRoomKvMap) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    final Map<String, Object> resultMap = new HashMap<>();
                    resultMap.put("roomId", roomId);
                    resultMap.put("entry", chatRoomKvMap);
                    channel.invokeMethod(RCMethodList.MethodCallBackChatRoomKVDidRemove, resultMap);
                }
            });
        }
    }

    class ConnectionStatusListenerImpl implements IRongCoreListener.ConnectionStatusListener {

        @Override
        public void onChanged(ConnectionStatus status) {
            Map<String, Object> map = new HashMap<>();
            map.put("status", status.getValue());
            channel.invokeMethod(RCMethodList.MethodCallBackKeyConnectionStatusChange, map);
        }
    }

    private final MethodChannel channel;
    private final Handler handler;

    public final ReceiveMessageWrapperListenerImpl receiveMessageWrapperListener;
    public final KVStatusListenerImpl kvStatusListener;
    public final ConnectionStatusListenerImpl connectionStatusListener;
}
