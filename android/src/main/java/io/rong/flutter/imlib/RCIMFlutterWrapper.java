package io.rong.flutter.imlib;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.rong.common.RLog;
import io.rong.common.fwlog.FwLog;
import io.rong.flutter.imlib.forward.CombineMessage;
import io.rong.imlib.AnnotationNotFoundException;
import io.rong.imlib.IOperationCallback;
import io.rong.imlib.IRongCallback;
import io.rong.imlib.MessageTag;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.MentionedInfo;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageConfig;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.SearchConversationResult;
import io.rong.imlib.model.UnknownMessage;
import io.rong.imlib.model.UserInfo;
import io.rong.imlib.typingmessage.TypingStatus;
import io.rong.message.FileMessage;
import io.rong.message.GIFMessage;
import io.rong.message.HQVoiceMessage;
import io.rong.message.ImageMessage;
import io.rong.message.MessageHandler;
import io.rong.message.ReadReceiptMessage;
import io.rong.message.RecallNotificationMessage;
import io.rong.message.ReferenceMessage;
import io.rong.message.SightMessage;
import io.rong.message.VoiceMessage;

public class RCIMFlutterWrapper {

    private static Context mContext = null;
    private static MethodChannel mChannel = null;
    private static RCFlutterConfig mConfig = null;
    private Handler mMainHandler = null;

    private HashMap<String, Constructor<? extends MessageContent>> messageContentConstructorMap;

    private String appkey = null;

    private RCIMFlutterWrapper() {
        messageContentConstructorMap = new HashMap<>();
        mMainHandler = new Handler(Looper.getMainLooper());

        RongIMClient.setReadReceiptListener(new RongIMClient.ReadReceiptListener() {
            @Override
            public void onReadReceiptReceived(Message message) {
                String LOG_TAG = "onReadReceiptReceived";
                if (message.getContent() instanceof ReadReceiptMessage) {
                    Map msgMap = new HashMap();
                    msgMap.put("cType", message.getConversationType().getValue());
                    msgMap.put("messageTime", ((ReadReceiptMessage) message.getContent()).getLastMessageSendTime());
                    msgMap.put("tId", message.getTargetId());
//                    RCLog.i(LOG_TAG + " start param:" + msgMap.toString());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyReceiveReadReceipt, msgMap);
                }
            }

            @Override
            public void onMessageReceiptRequest(final Conversation.ConversationType conversationType,
                                                final String targetId, final String messageUId) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (!TextUtils.isEmpty(messageUId)) {
                            Map msgMap = new HashMap();
                            msgMap.put("targetId", targetId);
                            msgMap.put("conversationType", conversationType.getValue());
                            msgMap.put("messageUId", messageUId);
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeyReceiptRequest, msgMap);
                        }
                    }
                });

            }

            @Override
            public void onMessageReceiptResponse(final Conversation.ConversationType conversationType,
                                                 final String targetId, final String messageUId, final HashMap<String, Long> readerList) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        Map msgMap = new HashMap();
                        msgMap.put("targetId", targetId);
                        msgMap.put("conversationType", conversationType.getValue());
                        msgMap.put("messageUId", messageUId);
                        msgMap.put("readerList", readerList);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackKeyReceiptResponse, msgMap);
                    }
                });

            }
        });
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
        if (RCMethodList.MethodKeyInit.equalsIgnoreCase(call.method)) {
            initRCIM(call.arguments);
        } else if (RCMethodList.MethodKeyConfig.equalsIgnoreCase(call.method)) {
            config(call.arguments);
        } else if (RCMethodList.MethodKeySetServerInfo.equalsIgnoreCase(call.method)) {
            setServerInfo(call.arguments);
        } else if (RCMethodList.MethodKeyConnect.equalsIgnoreCase(call.method)) {
            connect(call.arguments, result);
        } else if (RCMethodList.MethodKeyDisconnect.equalsIgnoreCase(call.method)) {
            disconnect(call.arguments);
        } else if (RCMethodList.MethodKeyRefreshUserInfo.equalsIgnoreCase(call.method)) {
            refreshUserInfo(call.arguments);
        } else if (RCMethodList.MethodKeySendMessage.equalsIgnoreCase(call.method)) {
            sendMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyJoinChatRoom.equalsIgnoreCase(call.method)) {
            joinChatRoom(call.arguments);
        } else if (RCMethodList.MethodKeyQuitChatRoom.equalsIgnoreCase(call.method)) {
            quitChatRoom(call.arguments);
        } else if (RCMethodList.MethodKeyGetHistoryMessage.equalsIgnoreCase(call.method)) {
            getHistoryMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetHistoryMessages.equalsIgnoreCase(call.method)) {
            getHistoryMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetMessage.equalsIgnoreCase(call.method)) {
            getMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetConversationList.equalsIgnoreCase(call.method)) {
            getConversationList(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetConversationListByPage.equalsIgnoreCase(call.method)) {
            getConversationListByPage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetConversation.equalsIgnoreCase(call.method)) {
            getConversation(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetChatRoomInfo.equalsIgnoreCase(call.method)) {
            getChatRoomInfo(call.arguments, result);
        } else if (RCMethodList.MethodKeyClearMessagesUnreadStatus.equalsIgnoreCase(call.method)) {
            clearMessagesUnreadStatus(call.arguments, result);
        } else if (RCMethodList.MethodKeySetCurrentUserInfo.equalsIgnoreCase(call.method)) {
            setCurrentUserInfo(call.arguments);
        } else if (RCMethodList.MethodKeyInsertIncomingMessage.equalsIgnoreCase(call.method)) {
            insertIncomingMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyInsertOutgoingMessage.equalsIgnoreCase(call.method)) {
            insertOutgoingMessage(call.arguments, result);
        } else if (RCMethodList.MethodCallBackKeygetRemoteHistoryMessages.equalsIgnoreCase(call.method)) {
            getRemoteHistoryMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetTotalUnreadCount.equalsIgnoreCase(call.method)) {
            getTotalUnreadCount(result);
        } else if (RCMethodList.MethodKeyGetUnreadCountTargetId.equalsIgnoreCase(call.method)) {
            getUnreadCountTargetId(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetUnreadCountConversationTypeList.equalsIgnoreCase(call.method)) {
            getUnreadCountConversationTypeList(call.arguments, result);
        } else if (RCMethodList.MethodKeySetConversationNotificationStatus.equalsIgnoreCase(call.method)) {
            setConversationNotificationStatus(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetConversationNotificationStatus.equalsIgnoreCase(call.method)) {
            getConversationNotificationStatus(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveConversation.equalsIgnoreCase(call.method)) {
            removeConversation(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetBlockedConversationList.equalsIgnoreCase(call.method)) {
            getBlockedConversationList(call.arguments, result);
        } else if (RCMethodList.MethodKeySetConversationToTop.equalsIgnoreCase(call.method)) {
            setConversationToTop(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetTopConversationList.equalsIgnoreCase(call.method)) {
            // getTopConversationList(call.arguments,result);
        } else if (RCMethodList.MethodKeyDeleteMessages.equalsIgnoreCase(call.method)) {
            deleteMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeyDeleteMessageByIds.equalsIgnoreCase(call.method)) {
            deleteMessageByIds(call.arguments, result);
        } else if (RCMethodList.MethodKeyAddToBlackList.equalsIgnoreCase(call.method)) {
            addToBlackList(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveFromBlackList.equalsIgnoreCase(call.method)) {
            removeFromBlackList(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetBlackListStatus.equalsIgnoreCase(call.method)) {
            getBlackListStatus(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetBlackList.equalsIgnoreCase(call.method)) {
            getBlackList(result);
        } else if (RCMethodList.MethodKeySendReadReceiptMessage.equalsIgnoreCase(call.method)) {
            sendReadReceiptMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyRecallMessage.equalsIgnoreCase(call.method)) {
            recallMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetTextMessageDraft.equalsIgnoreCase(call.method)) {
            getTextMessageDraft(call.arguments, result);
        } else if (RCMethodList.MethodKeySaveTextMessageDraft.equalsIgnoreCase(call.method)) {
            saveTextMessageDraft(call.arguments, result);
        } else if (RCMethodList.MethodKeyClearHistoryMessages.equalsIgnoreCase(call.method)) {
            clearHistoryMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeySyncConversationReadStatus.equalsIgnoreCase(call.method)) {
            syncConversationReadStatus(call.arguments, result);
        } else if (RCMethodList.MethodKeySearchConversations.equalsIgnoreCase(call.method)) {
            searchConversations(call.arguments, result);
        } else if (RCMethodList.MethodKeySearchMessages.equalsIgnoreCase(call.method)) {
            searchMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeySendTypingStatus.equalsIgnoreCase(call.method)) {
            sendTypingStatus(call.arguments);
        } else if (RCMethodList.MethodKeySendReadReceiptRequest.equalsIgnoreCase(call.method)) {
            sendReadReceiptRequest(call.arguments, result);
        } else if (RCMethodList.MethodKeySendReadReceiptResponse.equalsIgnoreCase(call.method)) {
            sendReadReceiptResponse(call.arguments, result);
        } else if (RCMethodList.MethodKeyDownloadMediaMessage.equalsIgnoreCase(call.method)) {
            downloadMediaMessage(call.arguments);
        } else if (RCMethodList.MethodKeySetChatRoomEntry.equalsIgnoreCase(call.method)) {
            setChatRoomEntry(call.arguments, result);
        } else if (RCMethodList.MethodKeyForceSetChatRoomEntry.equalsIgnoreCase(call.method)) {
            forceSetChatRoomEntry(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetChatRoomEntry.equalsIgnoreCase(call.method)) {
            getChatRoomEntry(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetAllChatRoomEntries.equalsIgnoreCase(call.method)) {
            getAllChatRoomEntries(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveChatRoomEntry.equalsIgnoreCase(call.method)) {
            removeChatRoomEntry(call.arguments, result);
        } else if (RCMethodList.MethodKeyForceRemoveChatRoomEntry.equalsIgnoreCase(call.method)) {
            forceRemoveChatRoomEntry(call.arguments, result);
        } else if (RCMethodList.MethodKeySetNotificationQuietHours.equalsIgnoreCase(call.method)) {
            setNotificationQuietHours(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveNotificationQuietHours.equalsIgnoreCase(call.method)) {
            removeNotificationQuietHours(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetNotificationQuietHours.equalsIgnoreCase(call.method)) {
            getNotificationQuietHours(result);
        } else if (RCMethodList.MethodKeyGetUnreadMentionedMessages.equalsIgnoreCase(call.method)) {
            getUnreadMentionedMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeySendDirectionalMessage.equalsIgnoreCase(call.method)) {
            sendDirectionalMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeySaveMediaToPublicDir.equalsIgnoreCase(call.method)) {
            saveMediaToPublicDir(call.arguments);
        } else if (RCMethodList.MethodKeyForwardMessageByStep.equalsIgnoreCase(call.method)) {
            forwardMessageByStep(call.arguments);
        } else if (RCMethodList.MethodKeyMessageBeginDestruct.equalsIgnoreCase(call.method)) {
            messageBeginDestruct(call.arguments);
        } else if (RCMethodList.MethodKeyMessageStopDestruct.equalsIgnoreCase(call.method)) {
            messageStopDestruct(call.arguments);
        } else if (RCMethodList.MethodKeyDeleteRemoteMessages.equalsIgnoreCase(call.method)) {
            deleteRemoteMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeyClearMessages.equalsIgnoreCase(call.method)) {
            clearMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeySetMessageExtra.equalsIgnoreCase(call.method)) {
            setMessageExtra(call.arguments, result);
        } else if (RCMethodList.MethodKeySetMessageSentStatus.equalsIgnoreCase(call.method)) {
            setMessageSentStatus(call.arguments, result);
        } else if (RCMethodList.MethodKeySetMessageReceivedStatus.equalsIgnoreCase(call.method)) {
            setMessageReceivedStatus(call.arguments, result);
        } else if (RCMethodList.MethodKeyClearConversations.equalsIgnoreCase(call.method)) {
            clearConversations(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetDeltaTime.equalsIgnoreCase(call.method)) {
            getDeltaTime(result);
        } else if (RCMethodList.MethodKeySetOfflineMessageDuration.equalsIgnoreCase(call.method)) {
            setOfflineMessageDuration(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetOfflineMessageDuration.equalsIgnoreCase(call.method)) {
            getOfflineMessageDuration(result);
        } else if (RCMethodList.MethodKeySetReconnectKickEnable.equalsIgnoreCase(call.method)) {
            setReconnectKickEnable(call.arguments);
        } else if (RCMethodList.MethodKeyGetConnectionStatus.equalsIgnoreCase(call.method)) {
            getConnectionStatus(result);
        } else if (RCMethodList.MethodKeyCancelDownloadMediaMessage.equalsIgnoreCase(call.method)) {
            cancelDownloadMediaMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetRemoteChatRoomHistoryMessages.equalsIgnoreCase(call.method)) {
            getRemoteChatRoomHistoryMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetMessageByUId.equalsIgnoreCase(call.method)) {
            getMessageByUId(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetFirstUnreadMessage.equalsIgnoreCase(call.method)) {
            getFirstUnreadMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeySendIntactMessage.equalsIgnoreCase(call.method)) {
            sendIntactMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyUpdateMessageExpansion.equalsIgnoreCase(call.method)) {
            updateMessageExpansion(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveMessageExpansionForKey.equalsIgnoreCase(call.method)) {
            removeMessageExpansion(call.arguments, result);
        } else {
            result.notImplemented();
        }

    }

    public Context getMainContext() {
        return mContext;
    }

    public String getAppkey() {
        return appkey;
    }

    // 可通过该接口向Flutter传递数据
    public void sendDataToFlutter(final Map map) {
        String LOG_TAG = "sendDataToFlutter";
//        RCLog.i(LOG_TAG + " start param:" + map.toString());
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendDataToFlutter, map);
            }
        });
    }

    public void sendReadReceiptMessage(Object arg, final Result result) {
        String LOG_TAG = "sendReadReceiptMessage";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            Number timestamp = (Number) map.get("timestamp");
            RongIMClient.getInstance().sendReadReceiptMessage(type, targetId, timestamp.longValue(),
                    new IRongCallback.ISendMediaMessageCallback() {
                        @Override
                        public void onProgress(Message message, int i) {

                        }

                        @Override
                        public void onCanceled(Message message) {

                        }

                        @Override
                        public void onAttached(Message message) {

                        }

                        @Override
                        public void onSuccess(Message message) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", 0);
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            result.success(msgMap);
                        }
                    });
        } else {

        }
    }

    // 发起群组消息回执请求
    private void sendReadReceiptRequest(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Map messageMap = (Map) map.get("messageMap");
            Message message = map2Message(messageMap);
            if (message == null) {
                return;
            }
            RongIMClient.getInstance().sendReadReceiptRequest(message, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map resultMap = new HashMap();
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("code", errorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void sendReadReceiptResponse(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            int conversationType = (int) map.get("conversationType");
            String targetId = (String) map.get("targetId");
            List messageMapList = (List) map.get("messageMapList");
            List<Message> messageList = new ArrayList<>();
            if (messageMapList != null) {
                for (int i = 0; i < messageMapList.size(); i++) {
                    Map messageMap = (Map) messageMapList.get(i);
                    Message message = map2Message(messageMap);
                    if (message != null) {
                        messageList.add(message);
                    }
                }
            }
            RongIMClient.getInstance().sendReadReceiptResponse(Conversation.ConversationType.setValue(conversationType),
                    targetId, messageList, new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            Map resultMap = new HashMap();
                            resultMap.put("code", 0);
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("code", errorCode.getValue());
                            result.success(resultMap);
                        }
                    });
        }
    }

    // private method
    private void initRCIM(Object arg) {
        String LOG_TAG = "init";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof String) {
            String appkey = String.valueOf(arg);
            this.appkey = appkey;
            RongIMClient.init(mContext, appkey);

            try {
                // IMLib 默认检测到小视频 SDK 才会注册小视频消息，所以此处需要手动注册
                RongIMClient.registerMessageType(SightMessage.class);
                // 因为合并消息 定义和注册都写在 kit 里面
                RongIMClient.registerMessageType(CombineMessage.class);
            } catch (AnnotationNotFoundException e) {
                e.printStackTrace();
            }

            setReceiveMessageListener();
            setConnectStatusListener();
            setTypingStatusListener();
            setOnRecallMessageListener();
            setOnReceiveDestructionMessageListener();
            setKVStatusListener();
            setMessageExpansionListener();
        } else {
            Log.e("RCIM flutter init", "非法参数");
        }
    }

    private void config(Object arg) {
        String LOG_TAG = "config";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map conf = (Map) arg;
            RCFlutterConfig config = new RCFlutterConfig();
            config.updateConf(conf);
            mConfig = config;

            updateIMConfig();

        } else {

        }
    }

    private void setServerInfo(Object arg) {
        String LOG_TAG = "setServerInfo";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String naviServer = (String) map.get("naviServer");
            String fileServer = (String) map.get("fileServer");
            RongIMClient.setServerInfo(naviServer, fileServer);
        }
    }

    private void connect(Object arg, final Result result) {
        String LOG_TAG = "connect";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof String) {
            String token = String.valueOf(arg);
            RongIMClient.connect(token, new RongIMClient.ConnectCallback() {
                @Override
                public void onSuccess(final String userId) {
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            RCLog.i("connect success");
                            Map resultMap = new HashMap();
                            resultMap.put("userId", userId);
                            resultMap.put("code", 0);
                            try {
                                result.success(resultMap);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    });
                }

                @Override
                public void onError(RongIMClient.ConnectionErrorCode connectionErrorCode) {
                    final RongIMClient.ConnectionErrorCode code = connectionErrorCode;
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            RCLog.e("connect " + String.valueOf(code.getValue()));
                            Map resultMap = new HashMap();
                            resultMap.put("userId", "");
                            resultMap.put("code", code.getValue());
                            try {
                                result.success(resultMap);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    });
                }

                @Override
                public void onDatabaseOpened(RongIMClient.DatabaseOpenStatus databaseOpenStatus) {

                }
            });

            fetchAllMessageMapper();
        } else {

        }
    }

    private void disconnect(Object arg) {
        String LOG_TAG = "disconnect";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Boolean) {
            boolean needPush = (boolean) arg;
            if (needPush) {
                RongIMClient.getInstance().disconnect();
            } else {
                RongIMClient.getInstance().logout();
            }
        }
    }

    private void refreshUserInfo(Object arg) {
        // if(arg instanceof Map) {
        // Map map = (Map)arg;
        // String userId = (String) map.get("userId");
        // String name = (String)map.get("name");
        // String portraitUri = (String) map.get("portraitUrl");
        // UserInfo userInfo = new UserInfo(userId,name, Uri.parse(portraitUri));
        // RongIMClient.getInstance().refreshUserInfoCache(userInfo);
        // }else {
        //
        // }
    }

    /// 未实现此方法 imlib 层没有此方法
    private void setCurrentUserInfo(Object arg) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String userId = (String) map.get("userId");
            String name = (String) map.get("name");
            String portraitUri = (String) map.get("portraitUrl");
            UserInfo userInfo = new UserInfo(userId, name, Uri.parse(portraitUri));
        }
    }

    private void sendIntactMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            final Number timestamp = (Number) map.get("timestamp");
            String objectName = (String) map.get("objectName");
            if (isMediaMessage(objectName)) {
                sendMediaMessage(arg, result);
                return;
            }
            final String LOG_TAG = "sendIntactMessage";
            String pushContent = (String) map.get("pushContent");

            if (pushContent.length() <= 0) {
                pushContent = null;
            }
            String pushData = (String) map.get("pushData");
            if (pushData.length() <= 0) {
                pushData = null;
            }

            Message message = map2Message(map);
            RongIMClient.getInstance().sendMessage(message, pushContent, pushData,
                    new IRongCallback.ISendMessageCallback() {
                        @Override
                        public void onAttached(Message message) {
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("status", 10);
                            result.success(msgMap);
                            msgMap.put("code", -1);
                            msgMap.put("messageId", message.getMessageId());
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, msgMap);
                        }

                        @Override
                        public void onSuccess(Message message) {
                            RCLog.i(LOG_TAG + " success");
                            if (message == null) {
                                RCLog.e(LOG_TAG + " message is nil");
                                result.success(null);
                                return;
                            }
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 30);
                            resultMap.put("code", 0);
                            if (timestamp != null && timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + " content is nil");
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 20);
                            resultMap.put("code", errorCode.getValue());
                            if (timestamp != null && timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                    });
        }
    }

    private void sendMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String objectName = (String) map.get("objectName");
            String contentStr = (String) map.get("content");
            if (isMediaMessage(objectName)) {
                sendMediaMessage(arg, result);
                return;
            }
            final String LOG_TAG = "sendMessage";
//            RCLog.i(LOG_TAG + " start param:" + arg.toString());
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            String pushContent = (String) map.get("pushContent");
            final Number timestamp = (Number) map.get("timestamp");
            final boolean disableNotification = (boolean) map.get("disableNotification");

            if (pushContent.length() <= 0) {
                pushContent = null;
            }
            String pushData = (String) map.get("pushData");
            if (pushData.length() <= 0) {
                pushData = null;
            }
            byte[] bytes = contentStr.getBytes();

            MessageContent content = null;
            if (isVoiceMessage(objectName)) {
                JSONObject jsonObject = null;
                try {
                    jsonObject = new JSONObject(contentStr);
                    String localPath = jsonObject.getString("localPath");
                    int duration = jsonObject.getInt("duration");
                    Uri uri = Uri.parse(localPath);
                    content = VoiceMessage.obtain(uri, duration);
                } catch (JSONException e) {
                    // do nothing
                }
            } else {
                content = newMessageContent(objectName, bytes, contentStr);
                if (objectName.equalsIgnoreCase("RC:ReferenceMsg")) {
                    makeReferenceMessage(content, contentStr);
                }
            }
            // 处理引用消息内容丢失的问题

            if (content == null) {
                RCLog.e(LOG_TAG + " message content is nil");
                result.success(null);
                return;
            }
            Message message = Message.obtain(targetId, type, content);
            message.setMessageConfig(new MessageConfig.Builder().setDisableNotification(disableNotification).build());

            RongIMClient.getInstance().sendMessage(message, pushContent, pushData,
                    new IRongCallback.ISendMessageCallback() {
                        @Override
                        public void onAttached(Message message) {
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("status", 10);
                            result.success(msgMap);
                            msgMap.put("code", -1);
                            msgMap.put("messageId", message.getMessageId());
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, msgMap);
                        }

                        @Override
                        public void onSuccess(Message message) {
                            RCLog.i(LOG_TAG + " success");
                            if (message == null) {
                                RCLog.e(LOG_TAG + " message is nil");
                                result.success(null);
                                return;
                            }
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 30);
                            resultMap.put("code", 0);
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + " content is nil");
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 20);
                            resultMap.put("code", errorCode.getValue());
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                    });
//            String messageS = MessageFactory.getInstance().message2String(message);
//            Map msgMap = new HashMap();
//            msgMap.put("message", messageS);
//            msgMap.put("status", 10);
//            result.success(msgMap);
        }
    }

    private void makeReferenceMessage(MessageContent content, String contentStr) {
        if (content == null || TextUtils.isEmpty(contentStr)) {
            return;
        }
        JSONObject jsonObject = null;
        String objName;
        try {
            jsonObject = new JSONObject(contentStr);
            if (jsonObject.has("objName")) {
                objName = (String) jsonObject.get("objName");
                // 处理引用内容为 ImageMessage
                if (objName.equalsIgnoreCase("RC:ImgMsg")) {
                    if (jsonObject.has("referMsg")) {
                        JSONObject referMsgObject = (JSONObject) jsonObject.get("referMsg");
                        if (referMsgObject.has("thumbUri")) {
                            String thumbUri = (String) referMsgObject.get("thumbUri");
                            ((ImageMessage) ((ReferenceMessage) content).getReferenceContent()).setThumUri(Uri.parse(thumbUri));
                        }
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void sendMediaMessage(Object arg, final Result result) {
        final String LOG_TAG = "sendMediaMessage";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String objectName = (String) map.get("objectName");
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            String contentStr = (String) map.get("content");
            String pushContent = (String) map.get("pushContent");
            final Number timestamp = (Number) map.get("timestamp");
            if (pushContent.length() <= 0) {
                pushContent = null;
            }
            String pushData = (String) map.get("pushData");
            if (pushData.length() <= 0) {
                pushData = null;
            }

            MessageContent content = null;
            if (objectName.equalsIgnoreCase("RC:ImgMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath = (String) jsonObject.get("localPath");
                    localPath = getCorrectLocalPath(localPath);
                    Uri uri = Uri.parse(localPath);
                    content = ImageMessage.obtain(uri, uri, true);

                    Object o = jsonObject.get("extra");// 设置 extra
                    if (o instanceof String) {
                        String extra = (String) o;
                        ((ImageMessage) content).setExtra(extra);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else if (objectName.equalsIgnoreCase("RC:GIFMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath = (String) jsonObject.get("localPath");
                    localPath = getCorrectLocalPath(localPath);
                    Uri uri = Uri.parse(localPath);
                    content = GIFMessage.obtain(uri);

                    Object o = jsonObject.get("extra");// 设置 extra
                    if (o instanceof String) {
                        String extra = (String) o;
                        ((GIFMessage) content).setExtra(extra);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            } else if (objectName.equalsIgnoreCase("RC:HQVCMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath = (String) jsonObject.get("localPath");
                    localPath = getCorrectLocalPath(localPath);
                    Uri uri = Uri.parse(localPath);
                    int duration = (Integer) jsonObject.get("duration");
                    content = HQVoiceMessage.obtain(uri, duration);

                    Object o = jsonObject.get("extra");// 设置 extra
                    if (o instanceof String) {
                        String extra = (String) o;
                        ((HQVoiceMessage) content).setExtra(extra);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else if (objectName.equalsIgnoreCase("RC:SightMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath = (String) jsonObject.get("localPath");
                    localPath = getCorrectLocalPath(localPath);
                    Uri uri = Uri.parse(localPath);
                    int duration = (Integer) jsonObject.get("duration");
                    content = SightMessage.obtain(uri, duration);
                    Object o = jsonObject.get("extra");// 设置 extra
                    if (o instanceof String) {
                        String extra = (String) o;
                        ((SightMessage) content).setExtra(extra);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }

            } else if (objectName.equalsIgnoreCase("RC:FileMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath = (String) jsonObject.get("localPath");
                    String mType = (String) jsonObject.get("type");
                    localPath = getCorrectLocalPath(localPath);
                    Uri uri = Uri.parse(localPath);
                    content = FileMessage.obtain(uri);
                    ((FileMessage) content).setType(mType);
                    Object o = jsonObject.get("extra");// 设置 extra
                    if (o instanceof String) {
                        String extra = (String) o;
                        ((FileMessage) content).setExtra(extra);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else if (objectName.equalsIgnoreCase("RC:CombineMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath = (String) jsonObject.get("localPath");
                    localPath = getCorrectLocalPath(localPath);
                    Uri uri = Uri.parse(localPath);
                    content = CombineMessage.obtain(uri);
                    setInfoToCombineMessage(contentStr, content);
                    Object o = jsonObject.get("extra");// 设置 extra
                    if (o instanceof String) {
                        String extra = (String) o;
                        ((CombineMessage) content).setExtra(extra);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {

            }
            setCommonInfo(contentStr, content);
            if (content == null) {
                RCLog.e(LOG_TAG + " message content is nil");
                return;
            }

            if (content instanceof SightMessage) {
                SightMessage sightMessage = (SightMessage) content;
                if (sightMessage.getDuration() > 10) {
                    RongIMClient.ErrorCode errorCode = RongIMClient.ErrorCode.RC_SIGHT_MSG_DURATION_LIMIT_EXCEED;
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", -1);
                    resultMap.put("status", 20);
                    resultMap.put("code", errorCode.getValue());
                    if (timestamp.longValue() > 0) {
                        resultMap.put("timestamp", timestamp);
                    }
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                    return;
                }
            }
            final boolean disableNotification = (boolean) map.get("disableNotification");
            Message message = Message.obtain(targetId, type, content);
            message.setMessageConfig(new MessageConfig.Builder().setDisableNotification(disableNotification).build());
            if (map.get("canIncludeExpansion") != null) {
                message.setCanIncludeExpansion((Boolean) map.get("canIncludeExpansion"));
            }
            Map<String, String> expansionDic = (Map) map.get("expansionDic");
            if (expansionDic != null) {
                HashMap<String, String> expansionDicMap = new HashMap<>();
                expansionDicMap.putAll(expansionDic);
                message.setExpansion(expansionDicMap);
            }
            RongIMClient.getInstance().sendMediaMessage(message, pushContent, pushData,
                    new IRongCallback.ISendMediaMessageCallback() {
                        @Override
                        public void onProgress(Message message, int i) {
                            Map map = new HashMap();
                            map.put("messageId", message.getMessageId());
                            map.put("progress", i);
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeyUploadMediaProgress, map);
                        }

                        @Override
                        public void onCanceled(Message message) {

                        }

                        @Override
                        public void onAttached(Message message) {
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("status", 10);
                            result.success(msgMap);
                            msgMap.put("code", -1);
                            msgMap.put("messageId", message.getMessageId());
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, msgMap);
                        }

                        @Override
                        public void onSuccess(Message message) {
                            if (message == null) {
                                RCLog.e(LOG_TAG + " message is nil");
                                result.success(null);
                                return;
                            }
                            RCLog.i(LOG_TAG + " success");
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 30);
                            resultMap.put("code", 0);
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 20);
                            resultMap.put("code", errorCode.getValue());
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }
                    });
        }
    }

    private void setInfoToCombineMessage(String contentStr, MessageContent content) {
        try {
            JSONObject contentObject = new JSONObject(contentStr);
            if (contentObject.has("conversationType")) {
                int conversationType = (int) contentObject.get("conversationType");
                ((CombineMessage) content)
                        .setConversationType(Conversation.ConversationType.setValue(conversationType));
            }
            if (contentObject.has("nameList")) {
                Object nameListObj = contentObject.get("nameList");
                List<String> nameList = new ArrayList<>();
                if (nameListObj instanceof JSONArray) {
                    JSONArray nameArray = (JSONArray) nameListObj;
                    for (int i = 0; i < nameArray.length(); i++) {
                        String idStr = (String) nameArray.get(i);
                        nameList.add(idStr);
                    }
                }
                ((CombineMessage) content).setNameList(nameList);
            }
            if (contentObject.has("title")) {
                Object titleObj = contentObject.get("title");
                String title = "";
                if (titleObj instanceof String) {
                    title = (String) titleObj;
                }
                ((CombineMessage) content).setTitle(title);
            }
            if (contentObject.has("summaryList")) {
                Object summaryListObj = contentObject.get("summaryList");
                List<String> summaryList = new ArrayList<>();
                if (summaryListObj instanceof JSONArray) {
                    JSONArray summaryArray = (JSONArray) summaryListObj;
                    for (int i = 0; i < summaryArray.length(); i++) {
                        String summary = (String) summaryArray.get(i);
                        summaryList.add(summary);
                    }
                }
                ((CombineMessage) content).setSummaryList(summaryList);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void setCommonInfo(String contentStr, MessageContent content) {
        try {
            JSONObject contentObject = new JSONObject(contentStr);
            if (contentObject.has("user")) {
                Object userObject = contentObject.get("user");
                if (userObject instanceof JSONObject) {
                    JSONObject userJObject = (JSONObject) userObject;
                    String id = "";
                    String name = "";
                    String portrait = "";
                    if (userJObject.has("id")) {
                        id = (String) userJObject.get("id");
                    }
                    if (userJObject.has("name")) {
                        name = (String) userJObject.get("name");
                    }
                    if (userJObject.has("portrait")) {
                        portrait = (String) userJObject.get("portrait");
                    }
                    UserInfo info = new UserInfo(id, name, Uri.parse(portrait));
                    if (userJObject.has("extra")) {
                        info.setExtra((String) userJObject.get("extra"));
                    }
                    content.setUserInfo(info);
                }
            }
            if (contentObject.has("mentionedInfo")) {
                Object mentionedObject = contentObject.get("mentionedInfo");
                if (mentionedObject instanceof JSONObject) {
                    JSONObject mentionedJObject = (JSONObject) mentionedObject;
                    MentionedInfo info = new MentionedInfo();
                    if (mentionedJObject.has("type")) {
                        info.setType(MentionedInfo.MentionedType.valueOf((int) mentionedJObject.get("type")));
                    }
                    if (mentionedJObject.has("userIdList")) {
                        JSONArray userIdArray = (JSONArray) mentionedJObject.get("userIdList");
                        List<String> userIdList = new ArrayList<>();
                        for (int i = 0; i < userIdArray.length(); i++) {
                            String idStr = (String) userIdArray.get(i);
                            userIdList.add(idStr);
                        }
                        info.setMentionedUserIdList(userIdList);
                    }
                    if (mentionedJObject.has("mentionedContent")) {
                        info.setMentionedContent((String) mentionedJObject.get("mentionedContent"));
                    }
                    content.setMentionedInfo(info);
                }
            }
            if (contentObject.has("burnDuration")) {
                long burnDuration = Long.valueOf(contentObject.get("burnDuration").toString());
                content.setDestructTime(burnDuration);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void joinChatRoom(Object arg) {
        final String LOG_TAG = "joinChatRoom";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            final String targetId = (String) map.get("targetId");
            int msgCount = (int) map.get("messageCount");
            RongIMClient.getInstance().joinChatRoom(targetId, msgCount, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i(LOG_TAG + " success ");
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", 0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom, callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", 1);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom, callBackMap);
                }
            });
        }
    }

    private void quitChatRoom(Object arg) {
        final String LOG_TAG = "quitChatRoom";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            final String targetId = (String) map.get("targetId");
            RongIMClient.getInstance().quitChatRoom(targetId, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i(LOG_TAG + " success ");
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", 0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom, callBackMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", 1);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom, callBackMap);
                }
            });
        }
    }

    private void getHistoryMessage(Object arg, final Result result) {
        final String LOG_TAG = "getHistoryMessage";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            final Integer messageId = (Integer) map.get("messageId");
            Integer count = (Integer) map.get("count");
            RongIMClient.getInstance().getHistoryMessages(type, targetId, messageId, count,
                    new RongIMClient.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
                            RCLog.i(LOG_TAG + " success ");
                            if (messages == null) {
                                result.success(null);
                                return;
                            }
                            List list = new ArrayList();
                            for (Message msg : messages) {
                                String messageS = MessageFactory.getInstance().message2String(msg);
                                list.add(messageS);
                            }
                            result.success(list);

                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            result.success(null);
                        }
                    });
        }
    }

    private void getHistoryMessages(Object arg, final Result result) {
        final String LOG_TAG = "getHistoryMessages";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            Number sendTime = (Number) map.get("sentTime");
            Integer beforeCount = (Integer) map.get("beforeCount");
            Integer afterCount = (Integer) map.get("afterCount");
            RongIMClient.getInstance().getHistoryMessages(type, targetId, sendTime.longValue(), beforeCount.intValue(),
                    afterCount.intValue(), new RongIMClient.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
                            RCLog.i(LOG_TAG + " success ");
                            if (messages == null) {
                                result.success(null);
                                return;
                            }
                            List list = new ArrayList();
                            for (Message msg : messages) {
                                String messageS = MessageFactory.getInstance().message2String(msg);
                                list.add(messageS);
                            }
                            result.success(list);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            result.success(null);
                        }
                    });
        }
    }

    private void getMessage(Object arg, final Result result) {
        final String LOG_TAG = "getMessage";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer mId = (Integer) map.get("messageId");
            RongIMClient.getInstance().getMessage(mId.intValue(), new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    RCLog.i(LOG_TAG + " success ");
                    String messageS = MessageFactory.getInstance().message2String(message);
                    result.success(messageS);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            });
        }
    }

    private void getConversationList(Object arg, final Result result) {
        final String LOG_TAG = "getConversationList";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List conversationTypeList = (List) map.get("conversationTypeList");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i = 0; i < conversationTypeList.size(); i++) {
                Integer t = (Integer) conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongIMClient.getInstance().getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
                @Override
                public void onSuccess(List<Conversation> conversations) {
                    RCLog.i(LOG_TAG + " success ");
                    if (conversations == null) {
                        result.success(null);
                        return;
                    }
                    List l = new ArrayList();
                    for (Conversation con : conversations) {
                        String conStr = MessageFactory.getInstance().conversation2String(con);
                        l.add(conStr);
                    }
                    result.success(l);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            }, types);
        }

    }

    private void getConversationListByPage(Object arg, final Result result) {
        final String LOG_TAG = "getConversationListByPage";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List conversationTypeList = (List) map.get("conversationTypeList");
            Integer count = (Integer) map.get("count");
            Number startTime = (Number) map.get("startTime");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i = 0; i < conversationTypeList.size(); i++) {
                Integer t = (Integer) conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongIMClient.getInstance().getConversationListByPage(new RongIMClient.ResultCallback<List<Conversation>>() {
                @Override
                public void onSuccess(List<Conversation> conversations) {
                    RCLog.i(LOG_TAG + " success ");
                    if (conversations == null) {
                        result.success(null);
                        return;
                    }
                    List l = new ArrayList();
                    for (Conversation con : conversations) {
                        String conStr = MessageFactory.getInstance().conversation2String(con);
                        l.add(conStr);
                    }
                    result.success(l);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            }, startTime.longValue(), count, types);
        }

    }

    private void getConversation(Object arg, final Result result) {
        final String LOG_TAG = "getConversation";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongIMClient.getInstance().getConversation(type, targetId, new RongIMClient.ResultCallback<Conversation>() {
                @Override
                public void onSuccess(Conversation conversation) {
                    RCLog.i(LOG_TAG + " success ");
                    if (conversation == null) {
                        result.success(null);
                        return;
                    }
                    String conStr = MessageFactory.getInstance().conversation2String(conversation);
                    result.success(conStr);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    result.success(null);
                }
            });
        }

    }

    private void getChatRoomInfo(Object arg, final Result result) {
        final String LOG_TAG = "getChatRoomInfo";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String targetId = (String) map.get("targetId");
            Integer memberCount = (Integer) map.get("memeberCount");
            Integer order = (Integer) map.get("memberOrder");
            ChatRoomInfo.ChatRoomMemberOrder memberOrder = ChatRoomInfo.ChatRoomMemberOrder.RC_CHAT_ROOM_MEMBER_ASC;
            if (order.intValue() == 2) {
                memberOrder = ChatRoomInfo.ChatRoomMemberOrder.RC_CHAT_ROOM_MEMBER_DESC;
            }
            RongIMClient.getInstance().getChatRoomInfo(targetId, memberCount.intValue(), memberOrder,
                    new RongIMClient.ResultCallback<ChatRoomInfo>() {
                        @Override
                        public void onSuccess(ChatRoomInfo chatRoomInfo) {
                            RCLog.i(LOG_TAG + " success");
                            if (chatRoomInfo == null) {
                                result.success(null);
                                return;
                            }
                            Map resultMap = MessageFactory.getInstance().chatRoom2Map(chatRoomInfo);
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            result.success(null);
                        }
                    });
        }
    }

    private void clearMessagesUnreadStatus(Object arg, final Result result) {
        final String LOG_TAG = "clearMessagesUnreadStatus";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongIMClient.getInstance().clearMessagesUnreadStatus(type, targetId,
                    new RongIMClient.ResultCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            RCLog.i(LOG_TAG + " success");
                            result.success(true);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            result.success(false);
                        }
                    });

        }
    }

    private void getUnreadCountConversationTypeList(Object arg, final Result result) {
        final String LOG_TAG = "getUnreadCountConversationTypeList";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List conversationTypeList = (List) map.get("conversationTypeList");
            boolean isContain = (boolean) map.get("isContain");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i = 0; i < conversationTypeList.size(); i++) {
                Integer t = (Integer) conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongIMClient.getInstance().getUnreadCount(types, isContain, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    RCLog.i(LOG_TAG + " success");
                    Map msgMap = new HashMap();
                    msgMap.put("count", integer);
                    msgMap.put("code", 0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("count", 0);
                    msgMap.put("code", errorCode.getValue());
                    result.success(msgMap);
                }
            });

        }
    }

    private void getUnreadCountTargetId(Object arg, final Result result) {
        final String LOG_TAG = "getUnreadCountTargetId";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");

            RongIMClient.getInstance().getUnreadCount(type, targetId, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    RCLog.i(LOG_TAG + " success");
                    Map msgMap = new HashMap();
                    msgMap.put("count", integer);
                    msgMap.put("code", 0);
                    result.success(msgMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    Map msgMap = new HashMap();
                    msgMap.put("count", 0);
                    msgMap.put("code", errorCode.getValue());
                    result.success(msgMap);
                }
            });
        }
    }

    private void getTotalUnreadCount(final Result result) {
        final String LOG_TAG = "getTotalUnreadCount";
//        RCLog.i(LOG_TAG + " start ");
        RongIMClient.getInstance().getTotalUnreadCount(new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                RCLog.i(LOG_TAG + " success");
                Map msgMap = new HashMap();
                msgMap.put("count", integer);
                msgMap.put("code", 0);
                result.success(msgMap);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                Map msgMap = new HashMap();
                msgMap.put("count", 0);
                msgMap.put("code", errorCode.getValue());
                result.success(msgMap);
            }
        });
    }

    private void insertOutgoingMessage(Object arg, final Result result) {
        final String LOG_TAG = "insertOutgoingMessage";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String objectName = (String) map.get("objectName");
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            Integer st = (Integer) map.get("sendStatus");
            Message.SentStatus sendStatus = Message.SentStatus.setValue(st.intValue());
            Number sendTime = (Number) map.get("sendTime");

            String contentStr = (String) map.get("content");

            byte[] bytes = contentStr.getBytes();
            MessageContent content = null;
            if (isVoiceMessage(objectName)) {
                JSONObject jsonObject = null;
                try {
                    jsonObject = new JSONObject();
                    String localPath = jsonObject.getString("localPath");
                    int duration = jsonObject.getInt("duration");
                    Uri uri = Uri.parse(localPath);
                    content = VoiceMessage.obtain(uri, duration);
                } catch (JSONException e) {

                }
            } else {
                content = newMessageContent(objectName, bytes, contentStr);
            }

            if (content == null) {
                RCLog.e(LOG_TAG + " message content is null");
                Map msgMap = new HashMap();
                msgMap.put("code", RongIMClient.ErrorCode.PARAMETER_ERROR.getValue());
                result.success(msgMap);
                return;
            }
            RongIMClient.getInstance().insertOutgoingMessage(type, targetId, sendStatus, content, sendTime.longValue(),
                    new RongIMClient.ResultCallback<Message>() {
                        @Override
                        public void onSuccess(Message message) {
                            RCLog.i(LOG_TAG + " success");
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("code", 0);
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            result.success(msgMap);
                        }
                    });

        }
    }

    private void insertIncomingMessage(Object arg, final Result result) {
        final String LOG_TAG = "insertIncomingMessage";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String objectName = (String) map.get("objectName");
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            Integer st = (Integer) map.get("rececivedStatus");
            Message.ReceivedStatus receivedStatus = new Message.ReceivedStatus(st.intValue());
            String senderUserId = (String) map.get("senderUserId");
            Number sendTime = (Number) map.get("sendTime");

            String contentStr = (String) map.get("content");

            byte[] bytes = contentStr.getBytes();
            MessageContent content = null;
            if (isVoiceMessage(objectName)) {
                JSONObject jsonObject = null;
                try {
                    jsonObject = new JSONObject();
                    String localPath = jsonObject.getString("localPath");
                    int duration = jsonObject.getInt("duration");
                    Uri uri = Uri.parse(localPath);
                    content = VoiceMessage.obtain(uri, duration);
                } catch (JSONException e) {

                }
            } else {
                content = newMessageContent(objectName, bytes, contentStr);
            }

            if (content == null) {
                RCLog.e(LOG_TAG + " message content is null");
                Map msgMap = new HashMap();
                msgMap.put("code", RongIMClient.ErrorCode.PARAMETER_ERROR.getValue());
                result.success(msgMap);
                return;
            }

            RongIMClient.getInstance().insertIncomingMessage(type, targetId, senderUserId, receivedStatus, content,
                    sendTime.longValue(), new RongIMClient.ResultCallback<Message>() {
                        @Override
                        public void onSuccess(Message message) {
                            RCLog.i(LOG_TAG + " success");
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("code", 0);
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            result.success(msgMap);
                        }
                    });
        }
    }

    public void getRemoteHistoryMessages(Object arg, final Result result) {
        final String LOG_TAG = "getRemoteHistoryMessages";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            final Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            final String targetId = (String) map.get("targetId");
            Number recordTime = (Number) map.get("recordTime");
            Integer count = (Integer) map.get("count");

            RongIMClient.getInstance().getRemoteHistoryMessages(type, targetId, recordTime.longValue(), count,
                    new RongIMClient.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
                            RCLog.i(LOG_TAG + " success");
                            if (messages == null) {
                                Map callBackMap = new HashMap();
                                callBackMap.put("code", 0);
                                callBackMap.put("messages", new ArrayList());
                                result.success(callBackMap);
                                return;
                            }
                            List list = new ArrayList();
                            for (Message msg : messages) {
                                String messageS = MessageFactory.getInstance().message2String(msg);
                                list.add(messageS);
                            }
                            Map callBackMap = new HashMap();
                            callBackMap.put("code", 0);
                            callBackMap.put("messages", list);
                            result.success(callBackMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map callBackMap = new HashMap();
                            callBackMap.put("code", errorCode.getValue());
                            result.success(callBackMap);
                        }
                    });
        }
    }

    private void setConversationNotificationStatus(Object arg, final Result result) {
        final String LOG_TAG = "setConversationNotificationStatus";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            boolean isBlocked = (boolean) map.get("isBlocked");
            int blockValue = isBlocked ? 0 : 1;

            Conversation.ConversationNotificationStatus status = Conversation.ConversationNotificationStatus
                    .setValue(blockValue);

            RongIMClient.getInstance().setConversationNotificationStatus(type, targetId, status,
                    new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
                        @Override
                        public void onSuccess(
                                Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                            RCLog.i(LOG_TAG + " success");
                            Map msgMap = new HashMap();
                            msgMap.put("status", conversationNotificationStatus.getValue());
                            msgMap.put("code", 0);
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            result.success(msgMap);
                        }
                    });
        }

    }

    private void getConversationNotificationStatus(Object arg, final Result result) {
        final String LOG_TAG = "getConversationNotificationStatus";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");

            RongIMClient.getInstance().getConversationNotificationStatus(type, targetId,
                    new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
                        @Override
                        public void onSuccess(
                                Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                            RCLog.i(LOG_TAG + " success");
                            Map msgMap = new HashMap();
                            msgMap.put("status", conversationNotificationStatus.getValue());
                            msgMap.put("code", 0);
                            result.success(msgMap);
                        }

                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            result.success(msgMap);

                        }
                    });
        }
    }

    private void getBlockedConversationList(Object arg, final Result result) {
        final String LOG_TAG = "getBlockedConversationList";
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List conversationTypeList = (List) map.get("conversationTypeList");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i = 0; i < conversationTypeList.size(); i++) {
                Integer t = (Integer) conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongIMClient.getInstance()
                    .getBlockedConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
                        @Override
                        public void onSuccess(List<Conversation> conversations) {
                            RCLog.i(LOG_TAG + " success");
                            List conversationList = new ArrayList();
                            if (conversations != null) {
                                for (Conversation con : conversations) {
                                    String conStr = MessageFactory.getInstance().conversation2String(con);
                                    conversationList.add(conStr);
                                }
                            }
                            Map resultMap = new HashMap();
                            resultMap.put("conversationList", conversationList);
                            resultMap.put("code", 0);
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map resultMap = new HashMap();
                            resultMap.put("code", errorCode.getValue());
                            result.success(resultMap);
                        }
                    }, types);
        }
    }

    private void setConversationToTop(Object arg, final Result result) {
        final String LOG_TAG = "setConversationToTop";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            boolean isTop = (boolean) map.get("isTop");

            RongIMClient.getInstance().setConversationToTop(type, targetId, isTop,
                    new RongIMClient.ResultCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            RCLog.i(LOG_TAG + " success");
                            Map msgMap = new HashMap();
                            msgMap.put("status", aBoolean);
                            msgMap.put("code", 0);
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            result.success(msgMap);
                        }
                    });
        }
    }

    private void deleteMessages(Object arg, final Result result) {
        final String LOG_TAG = "deleteMessages";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongIMClient.getInstance().deleteMessages(type, targetId, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + " error:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void deleteMessageByIds(Object arg, final Result result) {
        final String LOG_TAG = "deleteMessageByIds";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List messageIds = (List) map.get("messageIds");

            int[] mIds = new int[messageIds.size()];
            for (int i = 0; i < messageIds.size(); i++) {
                int t = (int) messageIds.get(i);
                mIds[i] = t;
            }

            RongIMClient.getInstance().deleteMessages(mIds, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + " error:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void removeConversation(Object arg, final Result result) {
        final String LOG_TAG = "removeConversation";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongIMClient.getInstance().removeConversation(type, targetId, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(LOG_TAG + " success");
                    result.success(true);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    result.success(false);
                }
            });
        }
    }

    private void addToBlackList(Object arg, final Result result) {
        final String LOG_TAG = "addToBlackList";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String userId = (String) map.get("userId");
            RongIMClient.getInstance().addToBlacklist(userId, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i(LOG_TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void removeFromBlackList(Object arg, final Result result) {
        final String LOG_TAG = "removeFromBlackList";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String userId = (String) map.get("userId");
            RongIMClient.getInstance().removeFromBlacklist(userId, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i(LOG_TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void getBlackListStatus(Object arg, final Result result) {
        final String LOG_TAG = "getBlackListStatus";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String userId = (String) map.get("userId");
            RongIMClient.getInstance().getBlacklistStatus(userId,
                    new RongIMClient.ResultCallback<RongIMClient.BlacklistStatus>() {
                        @Override
                        public void onSuccess(RongIMClient.BlacklistStatus blacklistStatus) {
                            RCLog.i(LOG_TAG + " success");
                            int status = blacklistStatus.getValue();
                            Map resultMap = new HashMap();
                            resultMap.put("status", status);
                            resultMap.put("code", 0);
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                            Map resultMap = new HashMap();
                            resultMap.put("status", 1);
                            resultMap.put("code", errorCode.getValue());
                            result.success(resultMap);
                        }
                    });
        }
    }

    private void getBlackList(final Result result) {
        final String LOG_TAG = "getBlackList";
        RongIMClient.getInstance().getBlacklist(new RongIMClient.GetBlacklistCallback() {
            @Override
            public void onSuccess(String[] strings) {
                RCLog.i(LOG_TAG + " success");
                List userIdList = null;
                if (strings == null) {
                    userIdList = new ArrayList();
                } else {
                    userIdList = Arrays.asList(strings);
                }
                Map resultMap = new HashMap();
                resultMap.put("userIdList", userIdList);
                resultMap.put("code", 0);
                result.success(resultMap);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                Map resultMap = new HashMap();
                resultMap.put("userIdList", new ArrayList<>());
                resultMap.put("code", errorCode.getValue());
                result.success(resultMap);
            }
        });
    }

    // util
    private void fetchAllMessageMapper() {

        RongIMClient client = RongIMClient.getInstance();
        Field field = null;
        try {
            field = client.getClass().getDeclaredField("mRegCache");
            field.setAccessible(true);
            List<String> mRegCache = (List) field.get(client);
            for (String className : mRegCache) {
                registerMessageType(className);
            }
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }

    // util method
    public void updateIMConfig() {
        // 后续 RCFlutterConfig 如果有什么参数，可以在此同步给 RongIM
    }

    private void setReceiveMessageListener() {
        RongIMClient.setOnReceiveMessageListener(new RongIMClient.OnReceiveMessageWrapperListener() {
            @Override
            public boolean onReceived(final Message message, final int left, final boolean hasPackage,
                                      final boolean offline) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        String messageS = MessageFactory.getInstance().message2String(message);
                        final Map map = new HashMap();
                        map.put("message", messageS);
                        map.put("left", left);
                        map.put("offline", offline);
                        map.put("hasPackage", hasPackage);

                        mChannel.invokeMethod(RCMethodList.MethodCallBackKeyReceiveMessage, map);
                    }
                });
                return false;
            }
        });
    }

    private void setOnRecallMessageListener() {
        RongIMClient.getInstance().setOnRecallMessageListener(new RongIMClient.OnRecallMessageListener() {
            @Override
            public boolean onMessageRecalled(final Message message,
                                             final RecallNotificationMessage recallNotificationMessage) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        message.setContent(recallNotificationMessage);
                        message.setObjectName("RC:RcNtf");
                        String messageS = MessageFactory.getInstance().message2String(message);
                        final Map map = new HashMap();
                        map.put("message", messageS);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackRecallMessage, map);
                    }
                });
                return false;
            }
        });
    }

    // 阅后即焚销毁回调
    private void setOnReceiveDestructionMessageListener() {
        RongIMClient.getInstance().setOnReceiveDestructionMessageListener(new RongIMClient.OnReceiveDestructionMessageListener() {

            @Override
            public void onReceive(final Message message) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        invokeMessageDestructCallBack(message.getUId(), 0);
                    }
                });
            }
        });
    }

    // 聊天室 kv 状态变化监听
    private void setKVStatusListener() {
        RongIMClient.getInstance().setKVStatusListener(new RongIMClient.KVStatusListener() {
            @Override
            public void onChatRoomKVSync(final String roomId) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        final Map resultMap = new HashMap();
                        resultMap.put("roomId", roomId);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackChatRoomKVDidSync, resultMap);
                    }
                });
            }

            @Override
            public void onChatRoomKVUpdate(final String roomId, Map<String, String> chatRoomKVMap) {
                final Map<String, String> kvMap = new HashMap<>();
                kvMap.putAll(chatRoomKVMap);
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        final Map resultMap = new HashMap();
                        resultMap.put("roomId", roomId);
                        resultMap.put("entry", kvMap);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackChatRoomKVDidUpdate, resultMap);
                    }
                });
            }

            @Override
            public void onChatRoomKVRemove(final String roomId, Map<String, String> map) {
                final Map<String, String> kvMap = new HashMap<>();
                kvMap.putAll(map);
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        final Map resultMap = new HashMap();
                        resultMap.put("roomId", roomId);
                        resultMap.put("entry", kvMap);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackChatRoomKVDidRemove, resultMap);
                    }
                });
            }
        });
    }

    private void setMessageExpansionListener(){
        RongIMClient.getInstance().setMessageExpansionListener(new RongIMClient.MessageExpansionListener() {
            @Override
            public void onMessageExpansionUpdate(final Map<String, String> map, final Message message) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        final Map resultMap = new HashMap();
                        resultMap.put("expansionDic", map);
                        resultMap.put("message", MessageFactory.getInstance().message2String(message));
                        mChannel.invokeMethod(RCMethodList.MethodCallBackMessageExpansionDidUpdate, resultMap);
                    }
                });
            }

            @Override
            public void onMessageExpansionRemove(final List<String> list, final Message message) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        final Map resultMap = new HashMap();
                        resultMap.put("keyArray", list);
                        resultMap.put("message", MessageFactory.getInstance().message2String(message));
                        mChannel.invokeMethod(RCMethodList.MethodCallBackMessageExpansionDidRemove, resultMap);
                    }
                });
            }
        });
    }

    /*
     * 输入状态的监听
     */
    private void setTypingStatusListener() {
        RongIMClient.setTypingStatusListener(new RongIMClient.TypingStatusListener() {
            @Override
            public void onTypingStatusChanged(final Conversation.ConversationType conversationType,
                                              final String targetId, final Collection<TypingStatus> collection) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        final Map resultMap = new HashMap();
                        resultMap.put("conversationType", conversationType.getValue());
                        resultMap.put("targetId", targetId);
                        List statusList = new ArrayList();
                        Iterator iterator = collection.iterator();
                        while (iterator.hasNext()) {
                            String statusStr = MessageFactory.getInstance()
                                    .typingStatus2String((TypingStatus) iterator.next());
                            statusList.add(statusStr);
                        }
                        resultMap.put("typingStatus", statusList);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackKeyTypingStatus, resultMap);
                    }
                });
            }
        });
    }

    private void setConnectStatusListener() {
        RongIMClient.setConnectionStatusListener(new RongIMClient.ConnectionStatusListener() {
            @Override
            public void onChanged(ConnectionStatus connectionStatus) {
                final String LOG_TAG = "ConnectionStatusChanged";
                RCLog.i(LOG_TAG + " status:" + String.valueOf(connectionStatus.getValue()));
                Map map = new HashMap();
                map.put("status", connectionStatus.getValue());
                mChannel.invokeMethod(RCMethodList.MethodCallBackKeyConnectionStatusChange, map);
            }
        });
    }

    private boolean isLocalPathEmpty(String contentStr) {
        JSONObject jsonObject = null;
        String localPath = "";
        try {
            jsonObject = new JSONObject(contentStr);
            localPath = jsonObject.getString("localPath");
        } catch (JSONException e) {
        }
        if (TextUtils.isEmpty(localPath)) {
            return true;
        }
        return false;
    }

    private boolean isMediaMessage(String objName) {
        if (objName.equalsIgnoreCase("RC:ImgMsg") || objName.equalsIgnoreCase("RC:HQVCMsg")
                || objName.equalsIgnoreCase("RC:SightMsg") || objName.equalsIgnoreCase("RC:FileMsg")
                || objName.equalsIgnoreCase("RC:GIFMsg") || objName.equalsIgnoreCase("RC:CombineMsg")) {
            return true;
        }
        return false;
    }

    private boolean isVoiceMessage(String objName) {
        if (objName.equalsIgnoreCase("RC:VcMsg")) {
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
                Constructor<? extends MessageHandler> handlerConstructor = tag.messageHandler()
                        .getConstructor(Context.class);
                MessageHandler messageHandler = handlerConstructor.newInstance(mContext);
                messageContentConstructorMap.put(objName, constructor);
            }

        } catch (Exception e) {
            FwLog.write(FwLog.E, FwLog.IM, "L-register_type-S", "class_name", className);
            StringWriter stringWriter = new StringWriter();
            PrintWriter printWriter = new PrintWriter(stringWriter);
            e.printStackTrace(printWriter);
        } catch (Throwable throwable) {
            FwLog.write(FwLog.E, FwLog.IM, "L-regtype-E", null);
        }
    }

    // 为 localPath 拼 file 前缀
    private String getCorrectLocalPath(String localPath) {
        String path = localPath;
        if (!localPath.startsWith("file")) {// 如果没有以 file 开头，为其增加 file 前缀
            path = "file://" + localPath;
        }
        RCLog.i("sendMediaMessage localPath:" + localPath);
        return path;
    }

    private void recallMessage(Object arg, final Result result) {
        final String TAG = "recallMessage";
        if (arg instanceof Map) {
            Map map = (Map) arg;
            final String LOG_TAG = "recallMessage";
            Map messageMap = (Map) map.get("message");
            String pushContent = (String) map.get("pushContent");
            if (pushContent.length() <= 0) {
                pushContent = null;
            }
            String contentStr = null;
            Message message = new Message();
            if (messageMap != null) {
                message.setConversationType(
                        Conversation.ConversationType.setValue((int) messageMap.get("conversationType")));
                message.setTargetId((String) messageMap.get("targetId"));
                message.setMessageId((int) messageMap.get("messageId"));
                message.setMessageDirection(
                        Message.MessageDirection.setValue((int) messageMap.get("messageDirection")));
                message.setSenderUserId((String) messageMap.get("senderUserId"));
                message.setReceivedStatus(new Message.ReceivedStatus((int) messageMap.get("receivedStatus")));
                message.setSentStatus(Message.SentStatus.setValue((int) messageMap.get("sentStatus")));
                message.setSentTime((long) messageMap.get("sentTime"));
                message.setObjectName((String) messageMap.get("objectName"));
                message.setUId((String) messageMap.get("messageUId"));
                contentStr = (String) messageMap.get("content");
            }
            if (contentStr == null) {
                RCLog.e(LOG_TAG + " message content is nil");
                return;
            }
            byte[] bytes = contentStr.getBytes();
            MessageContent content = null;
            content = newMessageContent((String) messageMap.get("objectName"), bytes, contentStr);
            if (content == null) {
                RCLog.e(LOG_TAG + " message content is nil");
                return;
            }
            message.setContent(content);
            RongIMClient.getInstance().recallMessage(message, pushContent,
                    new RongIMClient.ResultCallback<RecallNotificationMessage>() {
                        @Override
                        public void onSuccess(RecallNotificationMessage recallNotificationMessage) {
                            RLog.d(TAG, "recallMessage success ");
                            Map resultMap = new HashMap();
                            resultMap.put("recallNotificationMessage",
                                    MessageFactory.getInstance().messageContent2String(recallNotificationMessage));
                            resultMap.put("errorCode", 0);
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            RLog.d(TAG, "recallMessage errorCode = " + errorCode.getValue());
                            Map resultMap = new HashMap();
                            resultMap.put("recallNotificationMessage", "");
                            resultMap.put("errorCode", errorCode.getValue());
                            result.success(resultMap);
                        }
                    });
        }
    }

    // 获取会话草稿内容
    private void getTextMessageDraft(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            RongIMClient.getInstance().getTextMessageDraft(Conversation.ConversationType.setValue(conversationType),
                    targetId, new RongIMClient.ResultCallback<String>() {
                        @Override
                        public void onSuccess(String s) {
                            result.success(s);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.error(String.valueOf(errorCode.getValue()), errorCode.getMessage(), "");
                        }
                    });

        }
    }

    // 保存草稿
    private void saveTextMessageDraft(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            String textContent = (String) paramMap.get("content");
            RongIMClient.getInstance().saveTextMessageDraft(Conversation.ConversationType.setValue(conversationType),
                    targetId, textContent, new RongIMClient.ResultCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            result.success(aBoolean);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.error(String.valueOf(errorCode.getValue()), errorCode.getMessage(), "");
                        }
                    });
        }
    }

    // 清除历史消息
    private void clearHistoryMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            long recordTime = (long) paramMap.get("recordTime");
            boolean clearRemote = (boolean) paramMap.get("clearRemote");
            RongIMClient.getInstance().cleanHistoryMessages(Conversation.ConversationType.setValue(conversationType),
                    targetId, recordTime, clearRemote, new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    // 同步会话阅读状态
    private void syncConversationReadStatus(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            long timestamp = (long) paramMap.get("timestamp");
            RongIMClient.getInstance().syncConversationReadStatus(
                    Conversation.ConversationType.setValue(conversationType), targetId, timestamp,
                    new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    // 通过关键词搜索会话
    private void searchConversations(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String keyword = (String) paramMap.get("keyword");
            List<Integer> conversationTypes = (List<Integer>) paramMap.get("conversationTypes");
            List<String> objectNames = (List<String>) paramMap.get("objectNames");
            if (conversationTypes == null || objectNames == null) {
                return;
            }
            if (conversationTypes.size() > 0) {
                Conversation.ConversationType[] typeArry = new Conversation.ConversationType[conversationTypes.size()];
                for (int i = 0; i < conversationTypes.size(); i++) {
                    typeArry[i] = Conversation.ConversationType.setValue(conversationTypes.get(i));
                }
                String[] objectNamesArr = new String[objectNames.size()];
                objectNames.toArray(objectNamesArr);
                RongIMClient.getInstance().searchConversations(keyword, typeArry, objectNamesArr,
                        new RongIMClient.ResultCallback<List<SearchConversationResult>>() {
                            @Override
                            public void onSuccess(List<SearchConversationResult> searchConversationResults) {
                                Map resultMap = new HashMap();
                                List<String> searchConversationResultStr = new ArrayList<>();
                                for (SearchConversationResult searchConversationResult : searchConversationResults) {
                                    searchConversationResultStr.add(MessageFactory.getInstance()
                                            .SearchConversationResult2String(searchConversationResult));
                                }
                                resultMap.put("code", 0);
                                resultMap.put("SearchConversationResult", searchConversationResultStr);
                                result.success(resultMap);
                            }

                            @Override
                            public void onError(RongIMClient.ErrorCode errorCode) {
                                Map resultMap = new HashMap();
                                resultMap.put("code", errorCode.getValue());
                                result.success(resultMap);
                            }
                        });
            }
        }
    }

    // 根据会话,搜索本地历史消息
    private void searchMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            String keyword = (String) paramMap.get("keyword");
            int count = (int) paramMap.get("count");
            long beginTime = Long.valueOf(paramMap.get("beginTime").toString());
            RongIMClient.getInstance().searchMessages(Conversation.ConversationType.setValue(conversationType),
                    targetId, keyword, count, beginTime, new RongIMClient.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
                            Map callBackMap = new HashMap();
                            if (messages == null) {
                                callBackMap.put("code", 0);
                                callBackMap.put("messages", new ArrayList());
                                result.success(callBackMap);
                                return;
                            }
                            List list = new ArrayList();
                            for (Message msg : messages) {
                                String messageS = MessageFactory.getInstance().message2String(msg);
                                list.add(messageS);
                            }
                            callBackMap.put("code", 0);
                            callBackMap.put("messages", list);
                            result.success(callBackMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            Map callBackMap = new HashMap();
                            callBackMap.put("code", errorCode.getValue());
                            result.success(callBackMap);
                        }
                    });
        }
    }

    // 发送输入状态
    private void sendTypingStatus(Object arg) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            String typingContentType = (String) paramMap.get("typingContentType");
            RongIMClient.getInstance().sendTypingStatus(Conversation.ConversationType.setValue(conversationType),
                    targetId, typingContentType);
        }
    }

    // 下载媒体文件
    private void downloadMediaMessage(Object arg) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Map messageMap = (Map) map.get("message");
            Message message = map2Message(messageMap);
            if (message == null) {
                return;
            }
            RongIMClient.getInstance().downloadMediaMessage(message, new IRongCallback.IDownloadMediaMessageCallback() {
                @Override
                public void onSuccess(Message message) {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("message", messageS);
                    resultMap.put("code", 0);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyDownloadMediaMessage, resultMap);
                }

                @Override
                public void onProgress(Message message, int i) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("progress", i);
                    resultMap.put("code", 10);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyDownloadMediaMessage, resultMap);
                }

                @Override
                public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("code", errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyDownloadMediaMessage, resultMap);
                }

                @Override
                public void onCanceled(Message message) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("code", 20);
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyDownloadMediaMessage, resultMap);
                }
            });

        }
    }

    // 设置聊天室自定义属性
    private void setChatRoomEntry(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String chatRoomId = (String) paramMap.get("chatRoomId");
            String key = (String) paramMap.get("key");
            String value = (String) paramMap.get("value");
            boolean sendNotification = (boolean) paramMap.get("sendNotification");
            boolean autoDelete = (boolean) paramMap.get("autoDelete");
            String notificationExtra = (String) paramMap.get("notificationExtra");
            RongIMClient.getInstance().setChatRoomEntry(chatRoomId, key, value, sendNotification, autoDelete,
                    notificationExtra, new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    private void forceSetChatRoomEntry(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String chatRoomId = (String) paramMap.get("chatRoomId");
            String key = (String) paramMap.get("key");
            String value = (String) paramMap.get("value");
            boolean sendNotification = (boolean) paramMap.get("sendNotification");
            boolean autoDelete = (boolean) paramMap.get("autoDelete");
            String notificationExtra = (String) paramMap.get("notificationExtra");
            RongIMClient.getInstance().forceSetChatRoomEntry(chatRoomId, key, value, sendNotification, autoDelete,
                    notificationExtra, new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    private void getChatRoomEntry(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String chatRoomId = (String) paramMap.get("chatRoomId");
            String key = (String) paramMap.get("key");
            RongIMClient.getInstance().getChatRoomEntry(chatRoomId, key,
                    new RongIMClient.ResultCallback<Map<String, String>>() {
                        @Override
                        public void onSuccess(final Map<String, String> stringStringMap) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", 0);
                                    resultMap.put("entry", stringStringMap);
                                    result.success(resultMap);
                                }
                            });
                        }

                        @Override
                        public void onError(final RongIMClient.ErrorCode errorCode) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", errorCode.getValue());
                                    resultMap.put("entry", new HashMap<String, String>());
                                    result.success(resultMap);
                                }
                            });

                        }
                    });
        }
    }

    private void getAllChatRoomEntries(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String chatRoomId = (String) paramMap.get("chatRoomId");
            RongIMClient.getInstance().getAllChatRoomEntries(chatRoomId,
                    new RongIMClient.ResultCallback<Map<String, String>>() {
                        @Override
                        public void onSuccess(final Map<String, String> stringStringMap) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", 0);
                                    resultMap.put("entry", stringStringMap);
                                    result.success(resultMap);
                                }
                            });
                        }

                        @Override
                        public void onError(final RongIMClient.ErrorCode errorCode) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", errorCode.getValue());
                                    resultMap.put("entry", new HashMap<String, String>());
                                    result.success(resultMap);
                                }
                            });

                        }
                    });
        }
    }

    private void removeChatRoomEntry(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String chatRoomId = (String) paramMap.get("chatRoomId");
            String key = (String) paramMap.get("key");
            boolean sendNotification = (boolean) paramMap.get("sendNotification");
            String notificationExtra = (String) paramMap.get("notificationExtra");
            RongIMClient.getInstance().removeChatRoomEntry(chatRoomId, key, sendNotification, notificationExtra,
                    new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    private void forceRemoveChatRoomEntry(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String chatRoomId = (String) paramMap.get("chatRoomId");
            String key = (String) paramMap.get("key");
            boolean sendNotification = (boolean) paramMap.get("sendNotification");
            String notificationExtra = (String) paramMap.get("notificationExtra");
            RongIMClient.getInstance().forceRemoveChatRoomEntry(chatRoomId, key, sendNotification, notificationExtra,
                    new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    // 设置消息通知免打扰时间
    private void setNotificationQuietHours(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String startTime = (String) paramMap.get("startTime");
            int spanMins = (int) paramMap.get("spanMins");
            RongIMClient.getInstance().setNotificationQuietHours(startTime, spanMins,
                    new RongIMClient.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    // 删除已设置的全局时间段消息提醒屏蔽
    private void removeNotificationQuietHours(Object arg, final Result result) {
        RongIMClient.getInstance().removeNotificationQuietHours(new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                result.success(errorCode.getValue());
            }
        });
    }

    private void getNotificationQuietHours(final Result result) {
        RongIMClient.getInstance().getNotificationQuietHours(new RongIMClient.GetNotificationQuietHoursCallback() {
            @Override
            public void onSuccess(String startTime, int spanMinutes) {
                HashMap resultMap = new HashMap();
                resultMap.put("code", 0);
                resultMap.put("startTime", startTime);
                resultMap.put("spansMin", spanMinutes);
                result.success(resultMap);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                HashMap resultMap = new HashMap();
                resultMap.put("code", errorCode.getValue());
                result.success(resultMap);
            }
        });
    }

    private void getUnreadMentionedMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            RongIMClient.getInstance().getUnreadMentionedMessages(
                    Conversation.ConversationType.setValue(conversationType), targetId,
                    new RongIMClient.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
                            Map callBackMap = new HashMap();
                            if (messages == null) {
                                callBackMap.put("messages", new ArrayList());
                                result.success(callBackMap);
                                return;
                            }
                            List list = new ArrayList();
                            for (Message msg : messages) {
                                String messageS = MessageFactory.getInstance().message2String(msg);
                                list.add(messageS);
                            }
                            callBackMap.put("messages", list);
                            result.success(callBackMap);
                        }

                        @Override
                        public void onError(RongIMClient.ErrorCode errorCode) {
                            Map callBackMap = new HashMap();
                            callBackMap.put("messages", new ArrayList());
                            result.success(callBackMap);
                        }
                    });
        }
    }

    private void sendDirectionalMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            List<String> userIdList = (List<String>) paramMap.get("userIdList");
            String content = (String) paramMap.get("content");
            String objectName = (String) paramMap.get("objectName");
            String pushContent = (String) paramMap.get("pushContent");
            String pushData = (String) paramMap.get("pushData");
            final Number timestamp = (Number) paramMap.get("timestamp");
            if (TextUtils.isEmpty(content)) {
                return;
            }
            byte[] bytes = content.getBytes();
            if (bytes.length <= 0) {
                return;
            }
            MessageContent messageContent = newMessageContent(objectName, bytes, content);
            if (userIdList == null) {
                return;
            }
            String[] userIdArr = new String[userIdList.size()];
            userIdList.toArray(userIdArr);
            RongIMClient.getInstance().sendDirectionalMessage(Conversation.ConversationType.setValue(conversationType),
                    targetId, messageContent, userIdArr, pushContent, pushData,
                    new IRongCallback.ISendMessageCallback() {
                        @Override
                        public void onAttached(Message message) {
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("status", 10);
                            result.success(msgMap);
                        }

                        @Override
                        public void onSuccess(Message message) {
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 30);
                            resultMap.put("code", 0);
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 20);
                            resultMap.put("code", errorCode.getValue());
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }
                    });
        }
    }

    private void forwardMessageByStep(Object arg) {
        final String TAG = "forwardMessageByStep";
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Map messageMap = (Map) map.get("message");
            Message message = map2Message(messageMap);
            MessageContent messageContent = message.getContent();
            String targetId = (String) map.get("targetId");
            int conversationType = (int) map.get("conversationType");
            final Number timestamp = (Number) map.get("timestamp");
            // 有些消息携带了用户信息，转发的消息必须把用户信息去掉
            messageContent.setUserInfo(null);
            Message forwardMessage = Message.obtain(targetId, Conversation.ConversationType.setValue(conversationType),
                    messageContent);

            RongIMClient.getInstance().sendMessage(forwardMessage, "", "", new IRongCallback.ISendMessageCallback() {
                @Override
                public void onAttached(Message message) {

                }

                @Override
                public void onSuccess(Message message) {
                    RCLog.i(TAG + " success");
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("status", 30);
                    resultMap.put("code", 0);
                    if (timestamp.longValue() > 0) {
                        resultMap.put("timestamp", timestamp);
                    }
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                }

                @Override
                public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                    RCLog.e(TAG + " content is nil");
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("status", 20);
                    resultMap.put("code", errorCode.getValue());
                    if (timestamp.longValue() > 0) {
                        resultMap.put("timestamp", timestamp);
                    }
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                }
            });
        }
    }

    // 开始焚烧消息（阅后即焚）
    private void messageBeginDestruct(Object arg) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Map messageMap = (Map) map.get("message");
            Message message = map2Message(messageMap);
            if (message == null) {
                return;
            }
            RongIMClient.getInstance().beginDestructMessage(message, new RongIMClient.DestructCountDownTimerListener() {
                @Override
                public void onTick(final long untilFinished, String messageUId) {
                    int remainDuration = (int) untilFinished;
                    RLog.d("messageBeginDestruct", "onTick :" + untilFinished + " remainDuration:" + remainDuration);
                    invokeMessageDestructCallBack(messageUId, remainDuration);
                }

                @Override
                public void onStop(String messageUId) {
//                    invokeMessageDestructCallBack(messageUId,0);
                }
            });
        }
    }

    private void invokeMessageDestructCallBack(String messageUId, final int remainDuration) {
        RongIMClient.getInstance().getMessageByUid(messageUId, new RongIMClient.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                Map resultMap = new HashMap();
                String messageStr = MessageFactory.getInstance().message2String(message);
                resultMap.put("remainDuration", remainDuration);
                resultMap.put("message", messageStr);
                mChannel.invokeMethod(RCMethodList.MethodCallBackDestructMessage, resultMap);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                Map resultMap = new HashMap();
                resultMap.put("remainDuration", remainDuration);
                resultMap.put("message", "");
                mChannel.invokeMethod(RCMethodList.MethodCallBackDestructMessage, resultMap);
            }
        });
    }

    // 停止焚烧消息（阅后即焚）
    private void messageStopDestruct(Object arg) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Map messageMap = (Map) map.get("message");
            Message message = map2Message(messageMap);
            if (message == null) {
                return;
            }
            RongIMClient.getInstance().stopDestructMessage(message);
        }
    }

    private void deleteRemoteMessages(Object arg, final Result result) {
        final String TAG = "deleteRemoteMessages";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            List<Map> messageMapList = (List<Map>) paramMap.get("messages");
            if (messageMapList == null || messageMapList.size() == 0) {
                RLog.e(TAG, "message list is null");
                return;
            }
            Message[] messageArray = new Message[messageMapList.size()];
            for (int i = 0; i < messageMapList.size(); i++) {
                messageArray[i] = map2Message(messageMapList.get(i));
            }
            RongIMClient.getInstance().deleteRemoteMessages(Conversation.ConversationType.setValue(conversationType), targetId, messageArray, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i(TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(TAG + " error:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void clearMessages(Object arg, final Result result) {
        final String TAG = "clearMessages";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            RongIMClient.getInstance().clearMessages(Conversation.ConversationType.setValue(conversationType), targetId, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(TAG + " error:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void setMessageExtra(Object arg, final Result result) {
        final String TAG = "setMessageExtra";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int messageId = (int) paramMap.get("messageId");
            String value = (String) paramMap.get("value");
            RongIMClient.getInstance().setMessageExtra(messageId, value, new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(TAG + " error:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void setMessageReceivedStatus(Object arg, final Result result) {
        final String TAG = "setMessageReceivedStatus";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int messageId = (int) paramMap.get("messageId");
            int receivedStatus = (int) paramMap.get("receivedStatus");
            RongIMClient.getInstance().setMessageReceivedStatus(messageId, new Message.ReceivedStatus(receivedStatus), new RongIMClient.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i(TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(TAG + " error:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void setMessageSentStatus(Object arg, final Result result) {
        final String TAG = "setMessageSentStatus";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int messageId = (int) paramMap.get("messageId");
            final int sentStatus = (int) paramMap.get("sentStatus");
            RongIMClient.getInstance().getMessage(messageId, new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    if (message != null) {
                        message.setSentStatus(Message.SentStatus.setValue(sentStatus));
                        RongIMClient.getInstance().setMessageSentStatus(message, new RongIMClient.ResultCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean aBoolean) {
                                RCLog.i(TAG + " success");
                                result.success(0);
                            }

                            @Override
                            public void onError(RongIMClient.ErrorCode errorCode) {
                                RCLog.e(TAG + " error:" + errorCode.getValue());
                                result.success(errorCode.getValue());
                            }
                        });
                    }
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(false);
                }
            });
        }
    }

    private void clearConversations(Object arg, final Result result) {
        final String TAG = "clearConversations";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            List<Integer> conversationTypes = (List<Integer>) paramMap.get("conversationTypes");
            Conversation.ConversationType[] conversationArray = new Conversation.ConversationType[conversationTypes.size()];
            for (int i = 0; i < conversationTypes.size(); i++) {
                conversationArray[i] = Conversation.ConversationType.setValue(conversationTypes.get(i));
            }
            RongIMClient.getInstance().clearConversations(new RongIMClient.ResultCallback() {
                @Override
                public void onSuccess(Object o) {
                    RCLog.i(TAG + " success");
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(TAG + " error:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            }, conversationArray);
        }
    }

    private void getDeltaTime(final Result result) {
        Long deltaTime = RongIMClient.getInstance().getDeltaTime();
        result.success(deltaTime);
    }

    private void setOfflineMessageDuration(Object arg, final Result result) {
        final String TAG = "setOfflineMessageDuration";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int duration = (int) paramMap.get("duration");
            RongIMClient.getInstance().setOfflineMessageDuration(duration, new RongIMClient.ResultCallback<Long>() {
                @Override
                public void onSuccess(Long aLong) {
                    RCLog.i(TAG + " success");
                    Map resultMap = new HashMap();
                    resultMap.put("code", 0);
                    resultMap.put("result", aLong);
                    result.success(resultMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    RCLog.e(TAG + " error:" + errorCode.getValue());
                    Map resultMap = new HashMap();
                    resultMap.put("code", errorCode.getValue());
                    resultMap.put("result", -1);
                    result.success(resultMap);
                }
            });
        }
    }

    private void getOfflineMessageDuration(final Result result) {
        final String TAG = "getOfflineMessageDuration";
        RongIMClient.getInstance().getOfflineMessageDuration(new RongIMClient.ResultCallback<String>() {
            @Override
            public void onSuccess(String s) {
                RCLog.i(TAG + " success");
                result.success(Integer.valueOf(s));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                RCLog.e(TAG + " error:" + errorCode.getValue());
                result.success(errorCode.getValue());
            }
        });
    }

    private void setReconnectKickEnable(Object arg) {
        if (arg instanceof Boolean) {
            boolean enable = (boolean) arg;
            RongIMClient.getInstance().setReconnectKickEnable(enable);
        }
    }

    private void getConnectionStatus(final Result result) {
        RongIMClient.ConnectionStatusListener.ConnectionStatus connectionStatus = RongIMClient.getInstance().getCurrentConnectionStatus();
        result.success(connectionStatus.getValue());
    }

    private void cancelDownloadMediaMessage(Object arg, final Result result) {
        if (arg instanceof Integer) {
            int messageId = (int) arg;
            RongIMClient.getInstance().getMessage(messageId, new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    if (message != null) {
                        RongIMClient.getInstance().cancelDownloadMediaMessage(message, new RongIMClient.OperationCallback() {
                            @Override
                            public void onSuccess() {
                                result.success(true);
                            }

                            @Override
                            public void onError(RongIMClient.ErrorCode errorCode) {
                                result.success(false);
                            }
                        });
                    }
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(false);
                }
            });
        }
    }

    private void getRemoteChatRoomHistoryMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String targetId = (String) paramMap.get("targetId");
            long recordTime = Long.valueOf(paramMap.get("recordTime").toString());
            int count = (int) paramMap.get("count");
            int order = (int) paramMap.get("order");
            RongIMClient.TimestampOrder timestampOrder = RongIMClient.TimestampOrder.RC_TIMESTAMP_DESC;
            if (order == 1) {
                timestampOrder = RongIMClient.TimestampOrder.RC_TIMESTAMP_ASC;
            }
            RongIMClient.getInstance().getChatroomHistoryMessages(targetId, recordTime, count, timestampOrder, new IRongCallback.IChatRoomHistoryMessageCallback() {
                @Override
                public void onSuccess(List<Message> list, long syncTime) {
                    Map resultMap = new HashMap();
                    resultMap.put("code", 0);
                    resultMap.put("syncTime", syncTime);
                    List<String> msgStrList = new ArrayList<>();
                    if (list != null) {
                        for (Message message : list) {
                            msgStrList.add(MessageFactory.getInstance().message2String(message));
                        }
                    }
                    resultMap.put("messages", msgStrList);
                    result.success(resultMap);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("code", errorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void getMessageByUId(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String uId = (String) paramMap.get("messageUId");
            RongIMClient.getInstance().getMessageByUid(uId, new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    result.success(MessageFactory.getInstance().message2String(message));
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(null);
                }
            });
        }
    }

    private void getFirstUnreadMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            RongIMClient.getInstance().getTheFirstUnreadMessage(Conversation.ConversationType.setValue(conversationType), targetId, new RongIMClient.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    result.success(MessageFactory.getInstance().message2String(message));
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(null);
                }
            });
        }
    }

    private void updateMessageExpansion(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String messageUId = (String) paramMap.get("messageUId");
            Map<String, String> expansion = (Map<String, String>) paramMap.get("expansionDic");
            if (expansion == null) {
                return;
            }
            RongIMClient.getInstance().updateMessageExpansion(expansion, messageUId, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void removeMessageExpansion(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            List<String> keyArray = (List<String>) paramMap.get("keyArray");
            String messageUId = (String) paramMap.get("messageUId");
            RongIMClient.getInstance().removeMessageExpansion(keyArray, messageUId, new RongIMClient.OperationCallback() {
                @Override
                public void onSuccess() {
                    result.success(0);
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    result.success(errorCode.getValue());
                }
            });
        }
    }


    private Message map2Message(Map messageMap) {
        String contentStr = null;
        Message message = new Message();
        if (messageMap != null) {
            message.setConversationType(
                    Conversation.ConversationType.setValue((int) messageMap.get("conversationType")));
            message.setTargetId((String) messageMap.get("targetId"));
            if (messageMap.get("messageId") != null) {
                message.setMessageId((int) messageMap.get("messageId"));
            }
            if (messageMap.get("messageDirection") != null) {
                message.setMessageDirection(Message.MessageDirection.setValue((int) messageMap.get("messageDirection")));
            }
            if (messageMap.get("senderUserId") != null) {
                message.setSenderUserId((String) messageMap.get("senderUserId"));
            }
            if (messageMap.get("receivedStatus") != null) {
                message.setReceivedStatus(new Message.ReceivedStatus((int) messageMap.get("receivedStatus")));
            }
            if (messageMap.get("sentStatus") != null) {
                message.setSentStatus(Message.SentStatus.setValue((int) messageMap.get("sentStatus")));
            }
            if (messageMap.get("sentTime") != null) {
                message.setSentTime((long) messageMap.get("sentTime"));
            }
            if (messageMap.get("objectName") != null) {
                message.setObjectName((String) messageMap.get("objectName"));
            }
            if (messageMap.get("messageUId") != null) {
                message.setUId((String) messageMap.get("messageUId"));
            }
            if (messageMap.get("disableNotification") != null) {
                message.setMessageConfig(new MessageConfig.Builder().setDisableNotification((boolean) messageMap.get("disableNotification")).build());
            }
            if (messageMap.get("canIncludeExpansion") != null) {
                message.setCanIncludeExpansion((Boolean) messageMap.get("canIncludeExpansion"));
            }
            Map<String, String> expansionDic = (Map<String, String>) messageMap.get("expansionDic");
            if (expansionDic != null) {
                HashMap<String, String> expansionDicMap = new HashMap<>();
                expansionDicMap.putAll(expansionDic);
                message.setExpansion(expansionDicMap);
            }
            contentStr = (String) messageMap.get("content");
        }
        if (contentStr == null) {
            RCLog.e("Map2Message: message content is nil");
            return null;
        }
        byte[] bytes = contentStr.getBytes();
        MessageContent content = null;
        content = newMessageContent((String) messageMap.get("objectName"), bytes, contentStr);

        if (content == null) {
            RCLog.e("Map2Message:  message content is nil");
            return null;
        }
        // 主动赋予值 thumUri 防止在 flutter 互相传递时丢失
        String objectName = (String) messageMap.get("objectName");
        if (objectName.equalsIgnoreCase("RC:ImgMsg") || objectName.equalsIgnoreCase("RC:SightMsg")) {
            try {
                JSONObject jsonObject = new JSONObject(contentStr);
                if (jsonObject.has("thumbUri")) {
                    String thumbUriStr = (String) jsonObject.get("thumbUri");
                    if (content instanceof ImageMessage) {
                        ((ImageMessage) content).setThumUri(Uri.parse(thumbUriStr));
                    } else if (content instanceof SightMessage) {
                        ((SightMessage) content).setThumbUri(Uri.parse(thumbUriStr));
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        } else if (isVoiceMessage(objectName)) {
            JSONObject jsonObject = null;
            try {
                jsonObject = new JSONObject(contentStr);
                String localPath = jsonObject.getString("localPath");
                int duration = jsonObject.getInt("duration");
                Uri uri = Uri.parse(localPath);
                content = VoiceMessage.obtain(uri, duration);
            } catch (JSONException e) {
                // do nothing
            }
        } else if (objectName.equalsIgnoreCase("RC:ReferenceMsg")) {
            makeReferenceMessage(content, contentStr);
        }
        message.setContent(content);
        return message;
    }

    private MessageContent newMessageContent(String objectName, byte[] content, String contentStr) {
        Constructor<? extends MessageContent> constructor = messageContentConstructorMap.get(objectName);
        MessageContent result = null;

        if (constructor == null || content == null) {
            return new UnknownMessage(content);
        }
        // 单独处理引用消息
//        String contentStr = content.toString();
//        JSONObject contentObject = null;
//        String objName = "";
//        try {
//            contentObject = new JSONObject(contentStr);
//            if (contentObject.has("objName")) {
//                objName = (String) contentObject.get("objName");
//            }
//        } catch (JSONException e) {
//            e.printStackTrace();
//        }
//        if (contentObject != null && "RC:ReferenceMsg".equalsIgnoreCase(objectName) && "RC:ImgMsg".equalsIgnoreCase(objName)) {
//            String referenceContent = "";
//            String referMsgUserId = "";
//            try {
//                if (contentObject.has("content")) {
//                    referenceContent = (String) contentObject.get("content");
//
//                }
//                if (contentObject.has("referMsgUserId")) {
//                    referenceContent = (String) contentObject.get("referMsgUserId");
//                }
//                if (contentObject.)
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//
//        }
//        else {
        try {
            result = constructor.newInstance(content);
        } catch (Exception e) {
            // FwLog TBC.
            result = new UnknownMessage(content);
            FwLog.write(FwLog.F, FwLog.IM, "L-decode_msg-E", "msg_type|stacks", objectName, FwLog.stackToString(e));
        }
        setCommonInfo(contentStr, result);
//        }
        return result;
    }

    private void saveMediaToPublicDir(Object arg) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String filePath = (String) paramMap.get("filePath");
            String type = (String) paramMap.get("type");
            StorageUtils.saveMediaToPublicDir(getMainContext(), new File(filePath), type);
        }
    }
}
