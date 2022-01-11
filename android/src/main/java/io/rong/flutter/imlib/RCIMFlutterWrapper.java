package io.rong.flutter.imlib;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
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
import io.rong.common.ExpansionUtils;
import io.rong.common.RLog;
import io.rong.common.fwlog.FwLog;
import io.rong.flutter.imlib.forward.CombineMessage;
import io.rong.imlib.IRongCoreCallback;
import io.rong.imlib.IRongCoreEnum;
import io.rong.imlib.IRongCoreListener;
import io.rong.imlib.ISendMediaMessageCallback;
import io.rong.imlib.MessageTag;
import io.rong.imlib.NativeClient;
import io.rong.imlib.RongCoreClient;
import io.rong.imlib.chatroom.base.RongChatRoomClient;
import io.rong.imlib.model.AndroidConfig;
import io.rong.imlib.model.BlockedMessageInfo;
import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.ConversationIdentifier;
import io.rong.imlib.model.ConversationTagInfo;
import io.rong.imlib.model.HistoryMessageOption;
import io.rong.imlib.model.IOSConfig;
import io.rong.imlib.model.MentionedInfo;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageConfig;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.MessagePushConfig;
import io.rong.imlib.model.SearchConversationResult;
import io.rong.imlib.model.TagInfo;
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
import io.rong.push.RongPushClient;
import io.rong.push.pushconfig.PushConfig;

public class RCIMFlutterWrapper implements MethodChannel.MethodCallHandler {

    private static Context mContext = null;
    private static MethodChannel mChannel = null;
    private static RCFlutterConfig mConfig = null;
    private Handler mMainHandler = null;
    private List<Class<? extends MessageContent>> messageContentClassList;

    private HashMap<String, Constructor<? extends MessageContent>> messageContentConstructorMap;

    private String appkey = null;
    private static String sdkVersion = "";

    private RCIMFlutterWrapper() {
        messageContentConstructorMap = new HashMap<>();
        messageContentClassList = new ArrayList<>();
        mMainHandler = new Handler(Looper.getMainLooper());

        RongCoreClient.setReadReceiptListener(new IRongCoreListener.ReadReceiptListener() {
            @Override
            public void onReadReceiptReceived(Message message) {
                if (message.getContent() instanceof ReadReceiptMessage) {
                    Map msgMap = new HashMap();
                    msgMap.put("cType", message.getConversationType().getValue());
                    msgMap.put("messageTime", ((ReadReceiptMessage) message.getContent()).getLastMessageSendTime());
                    msgMap.put("tId", message.getTargetId());
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

    public void onMethodCall(MethodCall call, Result result) {
        if (RCMethodList.MethodKeyInit.equalsIgnoreCase(call.method)) {
            initRCIM(call.arguments, result);
        } else if (RCMethodList.MethodKeyConfig.equalsIgnoreCase(call.method)) {
            config(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeySetServerInfo.equalsIgnoreCase(call.method)) {
            setServerInfo(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeyConnect.equalsIgnoreCase(call.method)) {
            connect(call.arguments, result);
        } else if (RCMethodList.MethodKeyDisconnect.equalsIgnoreCase(call.method)) {
            disconnect(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeyRefreshUserInfo.equalsIgnoreCase(call.method)) {
            refreshUserInfo(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeySendMessage.equalsIgnoreCase(call.method)) {
            sendMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyJoinChatRoom.equalsIgnoreCase(call.method)) {
            joinChatRoom(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeyJoinExistChatRoom.equalsIgnoreCase(call.method)) {
            joinExitChatRoom(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeyQuitChatRoom.equalsIgnoreCase(call.method)) {
            quitChatRoom(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeyGetHistoryMessage.equalsIgnoreCase(call.method)) {
            getHistoryMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetHistoryMessages.equalsIgnoreCase(call.method)) {
            getHistoryMessages(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetMessage.equalsIgnoreCase(call.method)) {
            getMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetMessages.equalsIgnoreCase(call.method)) {
            getMessages(call.arguments, result);
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
            result.success(null);
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
            result.success(null);
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
            result.success(null);
        } else if (RCMethodList.MethodKeySendReadReceiptRequest.equalsIgnoreCase(call.method)) {
            sendReadReceiptRequest(call.arguments, result);
        } else if (RCMethodList.MethodKeySendReadReceiptResponse.equalsIgnoreCase(call.method)) {
            sendReadReceiptResponse(call.arguments, result);
        } else if (RCMethodList.MethodKeyDownloadMediaMessage.equalsIgnoreCase(call.method)) {
            downloadMediaMessage(call.arguments);
            result.success(null);
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
        } else if (RCMethodList.MethodKeySetChatRoomEntries.equalsIgnoreCase(call.method)) {
            setChatRoomEntries(call, result);
        } else if (RCMethodList.MethodKeyRemoveChatRoomEntries.equalsIgnoreCase(call.method)) {
            removeChatRoomEntries(call, result);
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
        } else if (RCMethodList.MethodKeyForwardMessageByStep.equalsIgnoreCase(call.method)) {
            forwardMessageByStep(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeyMessageBeginDestruct.equalsIgnoreCase(call.method)) {
            messageBeginDestruct(call.arguments);
            result.success(null);
        } else if (RCMethodList.MethodKeyMessageStopDestruct.equalsIgnoreCase(call.method)) {
            messageStopDestruct(call.arguments);
            result.success(null);
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
            result.success(null);
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
        } else if (RCMethodList.MethodKeyAddTag.equalsIgnoreCase(call.method)) {
            addTag(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveTag.equalsIgnoreCase(call.method)) {
            removeTag(call.arguments, result);
        } else if (RCMethodList.MethodKeyUpdateTag.equalsIgnoreCase(call.method)) {
            updateTag(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetTags.equalsIgnoreCase(call.method)) {
            getTags(call.arguments, result);
        } else if (RCMethodList.MethodKeyAddConversationsToTag.equalsIgnoreCase(call.method)) {
            addConversationsToTag(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveConversationsFromTag.equalsIgnoreCase(call.method)) {
            removeConversationsFromTag(call.arguments, result);
        } else if (RCMethodList.MethodKeyRemoveTagsFromConversation.equalsIgnoreCase(call.method)) {
            removeTagsFromConversation(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetTagsFromConversation.equalsIgnoreCase(call.method)) {
            getTagsFromConversation(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetConversationsFromTagByPage.equalsIgnoreCase(call.method)) {
            getConversationsFromTagByPage(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetUnreadCountByTag.equalsIgnoreCase(call.method)) {
            getUnreadCountByTag(call.arguments, result);
        } else if (RCMethodList.MethodKeySetConversationToTopInTag.equalsIgnoreCase(call.method)) {
            setConversationToTopInTag(call.arguments, result);
        } else if (RCMethodList.MethodKeyGetConversationTopStatusInTag.equalsIgnoreCase(call.method)) {
            getConversationTopStatusInTag(call.arguments, result);
        } else if (RCMethodList.MethodKeyBatchInsertMessage.equalsIgnoreCase(call.method)) {
            batchInsertMessage(call.arguments, result);
        } else if (RCMethodList.MethodKeySetAndroidPushConfig.equalsIgnoreCase(call.method)) {
            setPushConfig(call.arguments, result);
        } else if (RCMethodList.MethodKeySetStatisticServer.equalsIgnoreCase(call.method)) {
            setStatisticServer(call.arguments);
            result.success(null);
        }else {
            result.notImplemented();
        }

    }

    public Context getMainContext() {
        return mContext;
    }

    public String getAppkey() {
        return appkey;
    }

    public void setPushConfig(Object arg, Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            PushConfig.Builder configBuilder = new PushConfig.Builder();
            if (paramMap.get("enableHWPush") != null) {
                configBuilder.enableHWPush((boolean) paramMap.get("enableHWPush"));
            }
            if (paramMap.get("enableFCM") != null) {
                configBuilder.enableFCM((boolean) paramMap.get("enableFCM"));
            }
            if (paramMap.get("enableVivoPush") != null) {
                configBuilder.enableVivoPush((boolean) paramMap.get("enableVivoPush"));
            }
            if (paramMap.get("miAppId") != null && paramMap.get("miAppKey") != null) {
                String miAppId = (String) paramMap.get("miAppId");
                String miAppKey = (String) paramMap.get("miAppKey");
                if (!TextUtils.isEmpty(miAppId) && !TextUtils.isEmpty(miAppKey)) {
                    configBuilder.enableMiPush(miAppId, miAppKey);
                }
            }
            if (paramMap.get("mzAppId") != null && paramMap.get("mzAppKey") != null) {
                String mzAppId = (String) paramMap.get("mzAppId");
                String mzAppKey = (String) paramMap.get("mzAppKey");
                if (!TextUtils.isEmpty(mzAppId) && !TextUtils.isEmpty(mzAppKey)) {
                    configBuilder.enableMeiZuPush(mzAppId, mzAppKey);
                }
            }
            if (paramMap.get("oppoAppKey") != null && paramMap.get("oppoAppSecret") != null) {
                String oppoAppKey = (String) paramMap.get("oppoAppKey");
                String oppoAppSecret = (String) paramMap.get("oppoAppSecret");
                if (!TextUtils.isEmpty(oppoAppKey) && !TextUtils.isEmpty(oppoAppSecret)) {
                    configBuilder.enableOppoPush(oppoAppKey, oppoAppSecret);
                }
            }
            RongPushClient.setPushConfig(configBuilder.build());
        }
        result.success(null);
    }


    // 可通过该接口向Flutter传递数据
    public void sendDataToFlutter(final Map map) {
        if (map == null) {
            return;
        }
        RCLog.i("sendDataToFlutter start param:" + map.toString());
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendDataToFlutter, map);
            }
        });
    }

    public void sendReadReceiptMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            Number timestamp = (Number) map.get("timestamp");
            RongCoreClient.getInstance().sendReadReceiptMessage(type, targetId, timestamp.longValue(),
                    new IRongCoreCallback.ISendMediaMessageCallback() {
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
                            RCLog.i("[sendReadReceiptMessage] onSuccess:");
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(Message message, IRongCoreEnum.CoreErrorCode errorCode) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            RCLog.e("[sendReadReceiptMessage] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().sendReadReceiptRequest(message, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map resultMap = new HashMap();
                    resultMap.put("code", 0);
                    RCLog.i("[sendReadReceiptRequest] onSuccess:");
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("code", errorCode.getValue());
                    RCLog.e("[sendReadReceiptRequest] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().sendReadReceiptResponse(Conversation.ConversationType.setValue(conversationType),
                    targetId, messageList, new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            Map resultMap = new HashMap();
                            resultMap.put("code", 0);
                            RCLog.i("[sendReadReceiptResponse] onSuccess:");
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("code", errorCode.getValue());
                            RCLog.e("[sendReadReceiptResponse] onError:" + errorCode.getValue());
                            result.success(resultMap);
                        }
                    });
        }
    }

    // private method
    private void initRCIM(Object arg, Result result) {
        String LOG_TAG = "init";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Map) {
            Map param = (Map) arg;
            this.appkey = (String) param.get("appkey");
            this.sdkVersion = (String) param.get("version");
            RongCoreClient.init(mContext, appkey);

            // IMLib 默认检测到小视频 SDK 才会注册小视频消息，所以此处需要手动注册
            RongCoreClient.registerMessageType(SightMessage.class);
            // 因为合并消息 定义和注册都写在 kit 里面
            RongCoreClient.registerMessageType(CombineMessage.class);

            setReceiveMessageListener();
            setConnectStatusListener();
            setTypingStatusListener();
            setOnRecallMessageListener();
            setOnReceiveDestructionMessageListener();
            setKVStatusListener();
            setMessageExpansionListener();
            setConversationTagListener();
            setTagListenerListener();
            setChatRoomAdvancedActionListener();
            setMessageBlockListener();
        } else {
            Log.e("RCIM flutter init", "非法参数");
        }

        result.success(null);
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
            RongCoreClient.setServerInfo(naviServer, fileServer);
        }
    }

    private void setStatisticServer(Object arg) {
        String LOG_TAG = "setStatisticServer";
        if (arg instanceof Map) {
            Map params = (Map)arg;
            String statisticServer = (String)params.get("statisticServer");
            RongCoreClient.setStatisticDomain(statisticServer);
        }
    }

    public void registerMessage(Class<? extends MessageContent> messageClass) {
        if (messageContentClassList != null) {
            messageContentClassList.add(messageClass);
        }
    }

    private void connect(Object arg, final Result result) {
        // 连接前对自定义消息进行注册，防止注册时序错误导致的注册失败
        if (messageContentClassList != null && messageContentClassList.size() > 0) {
            RongCoreClient.registerMessageType(messageContentClassList);
            messageContentClassList.clear();
        }
        if (arg instanceof String) {
            final String token = String.valueOf(arg);
            RongCoreClient.connect(token, new IRongCoreCallback.ConnectCallback() {
                @Override
                public void onSuccess(final String userId) {
                    fetchAllMessageMapper();
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            Map resultMap = new HashMap();
                            resultMap.put("userId", userId);
                            resultMap.put("code", 0);
                            RCLog.i("[connect] onSuccess");
                            try {
                                result.success(resultMap);
                            } catch (Exception e) {
                                RCLog.i("[connect] onSuccess Exception:" + e.toString());
                                e.printStackTrace();
                            }
                        }
                    });
                }

                @Override
                public void onError(IRongCoreEnum.ConnectionErrorCode connectionErrorCode) {
                    fetchAllMessageMapper();
                    final IRongCoreEnum.ConnectionErrorCode code = connectionErrorCode;
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            Map resultMap = new HashMap();
                            resultMap.put("userId", "");
                            resultMap.put("code", code.getValue());
                            RCLog.e("[connect] onError " + code.getValue());
                            try {
                                result.success(resultMap);
                            } catch (Exception e) {
                                RCLog.e("[connect] onError Exception:" + e.toString());
                                e.printStackTrace();
                            }
                        }
                    });
                }

                @Override
                public void onDatabaseOpened(final IRongCoreEnum.DatabaseOpenStatus databaseOpenStatus) {
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (databaseOpenStatus != null) {
                                Map resultMap = new HashMap();
                                resultMap.put("status", databaseOpenStatus.getValue());
                                RCLog.i("[connect] onDatabaseOpened:" + databaseOpenStatus.getValue());
                                mChannel.invokeMethod(RCMethodList.MethodCallBackDatabaseOpened, resultMap);
                            }
                        }
                    });
                }
            });
        } else {

        }
    }

    private void disconnect(Object arg) {
        String LOG_TAG = "disconnect";
//        RCLog.i(LOG_TAG + " start param:" + arg.toString());
        if (arg instanceof Boolean) {
            boolean needPush = (boolean) arg;
            if (needPush) {
                RongCoreClient.getInstance().disconnect();
            } else {
                RongCoreClient.getInstance().logout();
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
        // RongCoreClient.getInstance().refreshUserInfoCache(userInfo);
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

            filterSendMessage(message);
            RongCoreClient.getInstance().sendMessage(message, pushContent, pushData,
                    new IRongCoreCallback.ISendMessageCallback() {
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
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 30);
                            resultMap.put("code", 0);
                            if (timestamp != null && timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            RCLog.i("[sendIntactMessage] onSuccess:" + resultMap.toString());
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(Message message, IRongCoreEnum.CoreErrorCode errorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 20);
                            resultMap.put("code", errorCode.getValue());
                            if (timestamp != null && timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            RCLog.e("[sendIntactMessage] onError:" + resultMap.toString());
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
                if (objectName.equalsIgnoreCase("RC:ReferenceMsg")) {
                    content = makeReferenceMessage(contentStr);
                } else {
                    content = newMessageContent(objectName, bytes, contentStr);
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

            filterSendMessage(message);
            RongCoreClient.getInstance().sendMessage(message, pushContent, pushData,
                    new IRongCoreCallback.ISendMessageCallback() {
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
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 30);
                            resultMap.put("code", 0);
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            RCLog.i("[sendMessage] onSuccess:" + resultMap.toString());
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(final Message message, final IRongCoreEnum.CoreErrorCode errorCode) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    Map resultMap = new HashMap();
                                    resultMap.put("messageId", message.getMessageId());
                                    resultMap.put("status", 20);
                                    resultMap.put("code", errorCode.getValue());
                                    if (timestamp.longValue() > 0) {
                                        resultMap.put("timestamp", timestamp);
                                    }
                                    RCLog.e("[sendMessage] onError:" + resultMap.toString());
                                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                                }
                            });
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

    private MessageContent makeReferenceMessage(String contentStr) {
        if (TextUtils.isEmpty(contentStr)) {
            return null;
        }
        try {
            JSONObject jsonObj = new JSONObject(contentStr);
            String userId = "";
            if (jsonObj.has("referMsgUserId")) {
                userId = jsonObj.getString("referMsgUserId");
            }

            String editSendText = "";
            if (jsonObj.has("content")) {
                editSendText = jsonObj.getString("content");
            }
            String objName = "";
            if (jsonObj.has("objName")) {
                objName = jsonObj.getString("objName");
            }

            MessageContent messageContent = null;
            if (jsonObj.has("referMsg") && !TextUtils.isEmpty(objName)) {
                JSONObject jsonObject = (JSONObject) jsonObj.get("referMsg");
                byte[] bytes = jsonObject.toString().getBytes("UTF-8");
                messageContent = newMessageContent(objName, bytes, jsonObject.toString());
//                this.setContent(NativeClient.getInstance().newMessageContent(this.getObjName(), bytes));
            }

            ReferenceMessage referenceMessage = ReferenceMessage.obtainMessage(userId, messageContent);
            referenceMessage.setEditSendText(editSendText);

            String extra = "";
            if (jsonObj.has("extra")) {
                extra = jsonObj.getString("extra");
            }
            referenceMessage.setExtra(extra);

            if (jsonObj.has("user")) {
                referenceMessage.setUserInfo(parseJsonToUserInfo(jsonObj.getJSONObject("user")));
            }

            if (jsonObj.has("mentionedInfo")) {
                referenceMessage.setMentionedInfo(parseJsonToMentionInfo(jsonObj.getJSONObject("mentionedInfo")));
            }
            return referenceMessage;
        } catch (JSONException var6) {
            RLog.e("ReferenceMessage", "JSONException " + var6.getMessage());
        } catch (UnsupportedEncodingException var7) {
            RLog.e("ReferenceMessage", "ReferenceMessage UnsupportedEncodingException", var7);
        }
        return null;
    }

    public UserInfo parseJsonToUserInfo(JSONObject jsonObj) {
        UserInfo info = null;
        String id = jsonObj.optString("id");
        String name = jsonObj.optString("name");
        String icon = jsonObj.optString("portrait");
        String extra = jsonObj.optString("extra");
        if (TextUtils.isEmpty(icon)) {
            icon = jsonObj.optString("icon");
        }

        if (!TextUtils.isEmpty(id) && !TextUtils.isEmpty(name)) {
            Uri portrait = icon != null ? Uri.parse(icon) : null;
            info = new UserInfo(id, name, portrait);
            info.setExtra(extra);
        }

        return info;
    }

    protected MentionedInfo parseJsonToMentionInfo(JSONObject jsonObject) {
        MentionedInfo.MentionedType type = MentionedInfo.MentionedType.valueOf(jsonObject.optInt("type"));
        JSONArray userList = jsonObject.optJSONArray("userIdList");
        String mentionContent = jsonObject.optString("mentionedContent");
        if (type.equals(MentionedInfo.MentionedType.NONE)) {
            return null;
        } else {
            MentionedInfo mentionedInfo;
            if (type.equals(MentionedInfo.MentionedType.ALL)) {
                mentionedInfo = new MentionedInfo(type, (List) null, mentionContent);
            } else {
                List<String> list = new ArrayList();
                if (userList == null || userList.length() <= 0) {
                    return null;
                }

                try {
                    for (int i = 0; i < userList.length(); ++i) {
                        list.add((String) userList.get(i));
                    }
                } catch (JSONException var8) {
                    var8.printStackTrace();
                }

                mentionedInfo = new MentionedInfo(type, list, mentionContent);
            }

            return mentionedInfo;
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
                    if (jsonObject.has("imageUri")) {
                        String imageUri = (String) jsonObject.get("imageUri");
                        if (!TextUtils.isEmpty(imageUri)) {
                            ((ImageMessage) content).setRemoteUri(Uri.parse(imageUri));
                        }
                    }
                    if (jsonObject.has("extra")) {
                        Object o = jsonObject.get("extra");// 设置 extra
                        if (o instanceof String) {
                            String extra = (String) o;
                            ((ImageMessage) content).setExtra(extra);
                        }
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

                    if (jsonObject.has("extra")) {
                        Object o = jsonObject.get("extra");// 设置 extra
                        if (o instanceof String) {
                            String extra = (String) o;
                            ((GIFMessage) content).setExtra(extra);
                        }
                    }
                    if (jsonObject.has("remoteUrl")) {
                        String remoteUrl = jsonObject.optString("remoteUrl");
                        if (!TextUtils.isEmpty(remoteUrl) && !"null".equals(remoteUrl)) {
                            ((GIFMessage) content).setRemoteUri(Uri.parse(remoteUrl));
                        }
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

                    if (jsonObject.has("extra")) {
                        Object o = jsonObject.get("extra");// 设置 extra
                        if (o instanceof String) {
                            String extra = (String) o;
                            ((HQVoiceMessage) content).setExtra(extra);
                        }
                    }
                    String remoteUrl = (String) jsonObject.optString("remoteUrl");
                    if (!TextUtils.isEmpty(remoteUrl) && !"null".equals(remoteUrl)) {
                        ((HQVoiceMessage) content).setMediaUrl(Uri.parse(remoteUrl));
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
                    if (jsonObject.has("extra")) {
                        Object o = jsonObject.get("extra");// 设置 extra
                        if (o instanceof String) {
                            String extra = (String) o;
                            ((SightMessage) content).setExtra(extra);
                        }
                    }
                    String sightUrl = (String) jsonObject.optString("sightUrl");
                    if (!TextUtils.isEmpty(sightUrl)) {
                        ((SightMessage) content).setMediaUrl(Uri.parse(sightUrl));
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            } else if (objectName.equalsIgnoreCase("RC:FileMsg")) {
                try {
                    JSONObject jsonObject = new JSONObject(contentStr);
                    String localPath = (String) jsonObject.get("localPath");
                    if (!TextUtils.isEmpty(localPath)) {
                        localPath = getCorrectLocalPath(localPath);
                    }
                    Uri uri = Uri.parse(localPath);
                    content = FileMessage.obtain(uri);
                    if (jsonObject.has("type")) {
                        String mType = (String) jsonObject.get("type");
                        ((FileMessage) content).setType(mType);
                    }
                    if (jsonObject.has("extra")) {
                        Object o = jsonObject.get("extra");// 设置 extra
                        if (o instanceof String) {
                            String extra = (String) o;
                            ((FileMessage) content).setExtra(extra);
                        }
                    }
                    if (jsonObject.has("fileUrl")) {
                        String fileUrl = (String) jsonObject.get("fileUrl");
                        if (!TextUtils.isEmpty(fileUrl)) {
                            ((FileMessage) content).setMediaUrl(Uri.parse(fileUrl));
                        }
                    }
                    if (jsonObject.has("size")) {
                        Number size = (Number) jsonObject.get("size");
                        if (size != null && size.intValue() > 0) {
                            ((FileMessage) content).setSize(size.intValue());
                        }
                    }
                    if (jsonObject.has("name")) {
                        String name = jsonObject.optString("name");
                        if (!TextUtils.isEmpty(name)) {
                            ((FileMessage) content).setName(name);
                        }
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
                    if (jsonObject.has("extra")) {
                        Object o = jsonObject.get("extra");// 设置 extra
                        if (o instanceof String) {
                            String extra = (String) o;
                            ((CombineMessage) content).setExtra(extra);
                        }
                    }
                    if (jsonObject.has("remoteUrl")) {
                        String remoteUrl = jsonObject.optString("remoteUrl");
                        if (!TextUtils.isEmpty(remoteUrl) && !"null".equals(remoteUrl)) {
                            ((CombineMessage) content).setMediaUrl(Uri.parse(remoteUrl));
                        }
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
                if (sightMessage.getDuration() > 120) {
                    IRongCoreEnum.CoreErrorCode errorCode = IRongCoreEnum.CoreErrorCode.RC_SIGHT_MSG_DURATION_LIMIT_EXCEED;
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
            Message message = Message.obtain(targetId, type, content);
            setExtraValue(map, message);
            RongCoreClient.getInstance().sendMediaMessage(message, pushContent, pushData,
                    new IRongCoreCallback.ISendMediaMessageCallback() {
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
                            RCLog.i("[sendMediaMessage] onSuccess:" + resultMap.toString());
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(final Message message, final IRongCoreEnum.CoreErrorCode errorCode) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                                    Map resultMap = new HashMap();
                                    resultMap.put("messageId", message.getMessageId());
                                    resultMap.put("status", 20);
                                    resultMap.put("code", errorCode.getValue());
                                    if (timestamp.longValue() > 0) {
                                        resultMap.put("timestamp", timestamp);
                                    }
                                    RCLog.e("[sendMediaMessage] onError:" + resultMap.toString());
                                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                                }
                            });
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
        if (arg instanceof Map) {
            Map map = (Map) arg;
            final String targetId = (String) map.get("targetId");
            int msgCount = (int) map.get("messageCount");
            RongChatRoomClient.getInstance().joinChatRoom(targetId, msgCount, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", 0);
                    RCLog.i("[joinChatRoom] onSuccess ");
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom, callBackMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", errorCode.getValue());
                    RCLog.e("[joinChatRoom] onError: " + errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom, callBackMap);
                }
            });
        }
    }

    private void joinExitChatRoom(Object arg) {
        final String LOG_TAG = "joinExitChatRoom";
        if (arg instanceof Map) {
            Map map = (Map) arg;
            final String targetId = (String) map.get("targetId");
            int msgCount = 0;
            if (map.get("messageCount") != null) {
                msgCount = (int) map.get("messageCount");
            }
            RongChatRoomClient.getInstance().joinExistChatRoom(targetId, msgCount, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", 0);
                    RCLog.i("[joinExitChatRoom] onSuccess: ");
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom, callBackMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e(LOG_TAG + String.valueOf(errorCode.getValue()));
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", errorCode.getValue());
                    RCLog.e("[joinExitChatRoom] onError:" + errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyJoinChatRoom, callBackMap);
                }
            });
        }
    }

    private void quitChatRoom(Object arg) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            final String targetId = (String) map.get("targetId");
            RongChatRoomClient.getInstance().quitChatRoom(targetId, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", 0);
                    RCLog.i("[quitChatRoom] onSuccess:");
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom, callBackMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    Map callBackMap = new HashMap();
                    callBackMap.put("targetId", targetId);
                    callBackMap.put("status", errorCode.getValue());
                    RCLog.e("[quitChatRoom] onError:" + errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyQuitChatRoom, callBackMap);
                }
            });
        }
    }

    private void getHistoryMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            final Integer messageId = (Integer) map.get("messageId");
            Integer count = (Integer) map.get("count");
            RongCoreClient.getInstance().getHistoryMessages(type, targetId, messageId, count,
                    new IRongCoreCallback.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
                            if (messages == null) {
                                result.success(null);
                                return;
                            }
                            List list = new ArrayList();
                            for (Message msg : messages) {
                                String messageS = MessageFactory.getInstance().message2String(msg);
                                list.add(messageS);
                            }
                            RCLog.i("[getHistoryMessage] onSuccess:");
                            result.success(list);

                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[getHistoryMessage] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().getHistoryMessages(type, targetId, sendTime.longValue(), beforeCount.intValue(),
                    afterCount.intValue(), new IRongCoreCallback.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
                            if (messages == null) {
                                result.success(null);
                                return;
                            }
                            List list = new ArrayList();
                            for (Message msg : messages) {
                                String messageS = MessageFactory.getInstance().message2String(msg);
                                list.add(messageS);
                            }
                            RCLog.i("[getHistoryMessages] onSuccess:");
                            result.success(list);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[getHistoryMessages] onError:" + errorCode.getValue());
                            result.success(null);
                        }
                    });
        }
    }

    private void getMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer mId = (Integer) map.get("messageId");
            RongCoreClient.getInstance().getMessage(mId.intValue(), new IRongCoreCallback.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    RCLog.i("[getMessage] onSuccess:");
                    result.success(messageS);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[getMessage] onError:" + errorCode.getValue());
                    result.success(null);
                }
            });
        }
    }

    private void getMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            if (map.get("conversationType") == null || map.get("targetId") == null) {
                return;
            }
            int t = (int) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t);
            String targetId = (String) map.get("targetId");

            int count = 0;
            int order = 0;
            long time = -1;

            if (map.get("count") != null) {
                count = (int) map.get("count");
            }
            if (map.get("order") != null) {
                order = (int) map.get("order");
            }
            if (map.get("recordTime") != null) {
                Number recordTime = (Number) map.get("recordTime");
                time = recordTime.longValue();
            }
            HistoryMessageOption.PullOrder pullOrder;
            if (order == 0) {
                pullOrder = HistoryMessageOption.PullOrder.DESCEND;
            } else {
                pullOrder = HistoryMessageOption.PullOrder.ASCEND;
            }

            RongCoreClient.getInstance().getMessages(type, targetId, new HistoryMessageOption(time, count, pullOrder), new IRongCoreCallback.IGetMessageCallback() {
                @Override
                public void onComplete(List<Message> list, IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    final Map resultMap = new HashMap();
                    resultMap.put("code", coreErrorCode.getValue());
                    List<String> messageList = new ArrayList<>();
                    if (list != null) {
                        for (Message message : list) {
                            messageList.add(MessageFactory.getInstance().message2String(message));
                        }
                    }
                    resultMap.put("messages", messageList);
                    mMainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            result.success(resultMap);
                        }
                    });
                }
            });
        }
    }

    private void getConversationList(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List conversationTypeList = (List) map.get("conversationTypeList");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i = 0; i < conversationTypeList.size(); i++) {
                Integer t = (Integer) conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            final ResultRecord resultRecord = new ResultRecord();

            RongCoreClient.getInstance().getConversationList(new IRongCoreCallback.ResultCallback<List<Conversation>>() {
                @Override
                public void onSuccess(List<Conversation> conversations) {
                    if (resultRecord.isResultReturned) {
                        RCLog.e("[getConversationList] onSuccess: result is returned");
                        return;
                    }
                    if (conversations == null) {
                        result.success(null);
                        resultRecord.isResultReturned = true;
                        return;
                    }
                    List l = new ArrayList();
                    for (Conversation con : conversations) {
                        String conStr = MessageFactory.getInstance().conversation2String(con);
                        l.add(conStr);
                    }
                    RCLog.i("[getConversationList] onSuccess:");
                    result.success(l);
                    resultRecord.isResultReturned = true;
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[getConversationList] onError:" + errorCode.getValue());
                    if (resultRecord.isResultReturned) {
                        RCLog.e("[getConversationList] onError: result is returned");
                        return;
                    }
                    result.success(null);
                    resultRecord.isResultReturned = true;
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

            RongCoreClient.getInstance().getConversationListByPage(new IRongCoreCallback.ResultCallback<List<Conversation>>() {
                @Override
                public void onSuccess(List<Conversation> conversations) {
                    if (conversations == null) {
                        result.success(null);
                        return;
                    }
                    List l = new ArrayList();
                    for (Conversation con : conversations) {
                        String conStr = MessageFactory.getInstance().conversation2String(con);
                        l.add(conStr);
                    }
                    RCLog.i("[getConversationListByPage] onSuccess:");
                    result.success(l);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.i("[getConversationListByPage] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().getConversation(type, targetId, new IRongCoreCallback.ResultCallback<Conversation>() {
                @Override
                public void onSuccess(Conversation conversation) {
                    if (conversation == null) {
                        result.success(null);
                        return;
                    }
                    String conStr = MessageFactory.getInstance().conversation2String(conversation);
                    RCLog.i("[getConversation] onSuccess:");
                    result.success(conStr);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[getConversation] onError:" + errorCode.getValue());
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
            RongChatRoomClient.getInstance().getChatRoomInfo(targetId, memberCount.intValue(), memberOrder,
                    new IRongCoreCallback.ResultCallback<ChatRoomInfo>() {
                        @Override
                        public void onSuccess(ChatRoomInfo chatRoomInfo) {
                            if (chatRoomInfo == null) {
                                result.success(null);
                                return;
                            }
                            Map resultMap = MessageFactory.getInstance().chatRoom2Map(chatRoomInfo);
                            RCLog.i("[getChatRoomInfo] onSuccess:");
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[getChatRoomInfo] onError:" + errorCode.getValue());
                            result.success(null);
                        }
                    });
        }
    }

    private void clearMessagesUnreadStatus(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongCoreClient.getInstance().clearMessagesUnreadStatus(type, targetId,
                    new IRongCoreCallback.ResultCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            RCLog.i("[clearMessagesUnreadStatus] onSuccess:");
                            result.success(true);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[clearMessagesUnreadStatus] onError:" + errorCode.getValue());
                            result.success(false);
                        }
                    });

        }
    }

    private void getUnreadCountConversationTypeList(Object arg, final Result result) {
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

            RongCoreClient.getInstance().getUnreadCount(types, isContain, new IRongCoreCallback.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    Map msgMap = new HashMap();
                    msgMap.put("count", integer);
                    msgMap.put("code", 0);
                    RCLog.i("[getUnreadCountConversationTypeList] onSuccess:" + msgMap.toString());
                    result.success(msgMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    Map msgMap = new HashMap();
                    msgMap.put("count", 0);
                    msgMap.put("code", errorCode.getValue());
                    RCLog.e("[getUnreadCountConversationTypeList] onError:" + errorCode.getValue());
                    result.success(msgMap);
                }
            });

        }
    }

    private void getUnreadCountTargetId(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");

            RongCoreClient.getInstance().getUnreadCount(type, targetId, new IRongCoreCallback.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    Map msgMap = new HashMap();
                    msgMap.put("count", integer);
                    msgMap.put("code", 0);
                    RCLog.i("[getUnreadCountTargetId] onSuccess:" + msgMap.toString());
                    result.success(msgMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    Map msgMap = new HashMap();
                    msgMap.put("count", 0);
                    msgMap.put("code", errorCode.getValue());
                    RCLog.e("[getUnreadCountTargetId] onError:" + errorCode.getValue());
                    result.success(msgMap);
                }
            });
        }
    }

    private void getTotalUnreadCount(final Result result) {
        RongCoreClient.getInstance().getTotalUnreadCount(new IRongCoreCallback.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                Map msgMap = new HashMap();
                msgMap.put("count", integer);
                msgMap.put("code", 0);
                RCLog.i("[getTotalUnreadCount] onSuccess:" + msgMap.toString());
                result.success(msgMap);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                Map msgMap = new HashMap();
                msgMap.put("count", 0);
                msgMap.put("code", errorCode.getValue());
                RCLog.e("[getTotalUnreadCount] onError:" + errorCode.getValue());
                result.success(msgMap);
            }
        });
    }

    private void insertOutgoingMessage(Object arg, final Result result) {
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
                RCLog.e("[insertOutgoingMessage] message content is null");
                Map msgMap = new HashMap();
                msgMap.put("code", IRongCoreEnum.CoreErrorCode.PARAMETER_ERROR.getValue());
                result.success(msgMap);
                return;
            }
            RongCoreClient.getInstance().insertOutgoingMessage(type, targetId, sendStatus, content, sendTime.longValue(),
                    new IRongCoreCallback.ResultCallback<Message>() {
                        @Override
                        public void onSuccess(Message message) {
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("code", 0);
                            RCLog.i("[insertOutgoingMessage] onSuccess:");
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            RCLog.e("[insertOutgoingMessage] onError:" + msgMap.toString());
                            result.success(msgMap);
                        }
                    });

        }
    }

    private void insertIncomingMessage(Object arg, final Result result) {
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
                RCLog.e("[insertOutgoingMessage] message content is null");
                Map msgMap = new HashMap();
                msgMap.put("code", IRongCoreEnum.CoreErrorCode.PARAMETER_ERROR.getValue());
                result.success(msgMap);
                return;
            }

            RongCoreClient.getInstance().insertIncomingMessage(type, targetId, senderUserId, receivedStatus, content,
                    sendTime.longValue(), new IRongCoreCallback.ResultCallback<Message>() {
                        @Override
                        public void onSuccess(Message message) {
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("code", 0);
                            RCLog.i("[insertOutgoingMessage] onSuccess:");
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            RCLog.e("[insertOutgoingMessage] onError:" + errorCode.getValue());
                            result.success(msgMap);
                        }
                    });
        }
    }

    public void getRemoteHistoryMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            final Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            final String targetId = (String) map.get("targetId");
            Number recordTime = (Number) map.get("recordTime");
            Integer count = (Integer) map.get("count");

            RongCoreClient.getInstance().getRemoteHistoryMessages(type, targetId, recordTime.longValue(), count,
                    new IRongCoreCallback.ResultCallback<List<Message>>() {
                        @Override
                        public void onSuccess(List<Message> messages) {
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
                            RCLog.i("[getRemoteHistoryMessages] onSuccess:");
                            result.success(callBackMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map callBackMap = new HashMap();
                            callBackMap.put("code", errorCode.getValue());
                            RCLog.e("[getRemoteHistoryMessages] onError:" + errorCode.getValue());
                            result.success(callBackMap);
                        }
                    });
        }
    }

    private void setConversationNotificationStatus(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            boolean isBlocked = (boolean) map.get("isBlocked");
            int blockValue = isBlocked ? 0 : 1;

            Conversation.ConversationNotificationStatus status = Conversation.ConversationNotificationStatus
                    .setValue(blockValue);

            RongCoreClient.getInstance().setConversationNotificationStatus(type, targetId, status,
                    new IRongCoreCallback.ResultCallback<Conversation.ConversationNotificationStatus>() {
                        @Override
                        public void onSuccess(
                                Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                            Map msgMap = new HashMap();
                            msgMap.put("status", conversationNotificationStatus.getValue());
                            msgMap.put("code", 0);
                            RCLog.i("[setConversationNotificationStatus] onSuccess:" + msgMap.toString());
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            RCLog.i("[setConversationNotificationStatus] onError:" + msgMap.toString());
                            result.success(msgMap);
                        }
                    });
        }

    }

    private void getConversationNotificationStatus(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");

            RongCoreClient.getInstance().getConversationNotificationStatus(type, targetId,
                    new IRongCoreCallback.ResultCallback<Conversation.ConversationNotificationStatus>() {
                        @Override
                        public void onSuccess(
                                Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                            Map msgMap = new HashMap();
                            msgMap.put("status", conversationNotificationStatus.getValue());
                            msgMap.put("code", 0);
                            RCLog.i("[getConversationNotificationStatus] onSuccess:" + msgMap.toString());
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            RCLog.e("[getConversationNotificationStatus] onSuccess:" + msgMap.toString());
                            result.success(msgMap);

                        }
                    });
        }
    }

    private void getBlockedConversationList(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List conversationTypeList = (List) map.get("conversationTypeList");

            Conversation.ConversationType[] types = new Conversation.ConversationType[conversationTypeList.size()];
            for (int i = 0; i < conversationTypeList.size(); i++) {
                Integer t = (Integer) conversationTypeList.get(i);
                Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
                types[i] = type;
            }

            RongCoreClient.getInstance()
                    .getBlockedConversationList(new IRongCoreCallback.ResultCallback<List<Conversation>>() {
                        @Override
                        public void onSuccess(List<Conversation> conversations) {
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
                            RCLog.i("[getBlockedConversationList] onSuccess:");
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("code", errorCode.getValue());
                            RCLog.e("[getBlockedConversationList] onError:" + errorCode.getValue());
                            result.success(resultMap);
                        }
                    }, types);
        }
    }

    private void setConversationToTop(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            boolean isTop = (boolean) map.get("isTop");

            RongCoreClient.getInstance().setConversationToTop(type, targetId, isTop,
                    new IRongCoreCallback.ResultCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            Map msgMap = new HashMap();
                            msgMap.put("status", aBoolean);
                            msgMap.put("code", 0);
                            RCLog.i("[setConversationToTop] onSuccess:");
                            result.success(msgMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map msgMap = new HashMap();
                            msgMap.put("code", errorCode.getValue());
                            RCLog.e("[setConversationToTop] onError:" + errorCode.getValue());
                            result.success(msgMap);
                        }
                    });
        }
    }

    private void deleteMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongCoreClient.getInstance().deleteMessages(type, targetId, new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i("[deleteMessages] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[deleteMessages] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void deleteMessageByIds(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            List messageIds = (List) map.get("messageIds");

            int[] mIds = new int[messageIds.size()];
            for (int i = 0; i < messageIds.size(); i++) {
                int t = (int) messageIds.get(i);
                mIds[i] = t;
            }

            RongCoreClient.getInstance().deleteMessages(mIds, new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i("[deleteMessageByIds] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[deleteMessageByIds] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void removeConversation(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            Integer t = (Integer) map.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) map.get("targetId");
            RongCoreClient.getInstance().removeConversation(type, targetId, new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i("[removeConversation] onSuccess:");
                    result.success(true);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[removeConversation] onError:" + errorCode.getValue());
                    result.success(false);
                }
            });
        }
    }

    private void addToBlackList(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String userId = (String) map.get("userId");
            RongCoreClient.getInstance().addToBlacklist(userId, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i("[addToBlackList] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.i("[addToBlackList] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void removeFromBlackList(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String userId = (String) map.get("userId");
            RongCoreClient.getInstance().removeFromBlacklist(userId, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i("[removeFromBlackList] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[removeFromBlackList] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void getBlackListStatus(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map map = (Map) arg;
            String userId = (String) map.get("userId");
            RongCoreClient.getInstance().getBlacklistStatus(userId,
                    new IRongCoreCallback.ResultCallback<IRongCoreEnum.BlacklistStatus>() {
                        @Override
                        public void onSuccess(IRongCoreEnum.BlacklistStatus blacklistStatus) {
                            int status = blacklistStatus.getValue();
                            Map resultMap = new HashMap();
                            resultMap.put("status", status);
                            resultMap.put("code", 0);
                            RCLog.i("[getBlackListStatus] onSuccess:" + resultMap.toString());
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("status", errorCode.getValue());
                            resultMap.put("code", errorCode.getValue());
                            RCLog.e("[getBlackListStatus] onError:" + resultMap.toString());
                            result.success(resultMap);
                        }
                    });
        }
    }

    private void getBlackList(final Result result) {
        RongCoreClient.getInstance().getBlacklist(new IRongCoreCallback.GetBlacklistCallback() {
            @Override
            public void onSuccess(String[] strings) {
                List userIdList = null;
                if (strings == null) {
                    userIdList = new ArrayList();
                } else {
                    userIdList = Arrays.asList(strings);
                }
                Map resultMap = new HashMap();
                resultMap.put("userIdList", userIdList);
                resultMap.put("code", 0);
                RCLog.i("[getBlackList] onSuccess:");
                result.success(resultMap);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                Map resultMap = new HashMap();
                resultMap.put("userIdList", new ArrayList<>());
                resultMap.put("code", errorCode.getValue());
                RCLog.e("[getBlackList] onError:" + errorCode.getValue());
                result.success(resultMap);
            }
        });
    }

    // util
    private void fetchAllMessageMapper() {
        RongCoreClient client = RongCoreClient.getInstance();
        Field field = null;
        try {
            field = client.getClass().getDeclaredField("mRegCache");
            field.setAccessible(true);
//            List<String> mRegCache = (List) field.get(client)
            List<String> mRegCache = new ArrayList<>((List) field.get(client));
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
        RongCoreClient.setOnReceiveMessageListener(new IRongCoreListener.OnReceiveMessageWrapperListener() {
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
        RongCoreClient.setOnRecallMessageListener(new IRongCoreListener.OnRecallMessageListener() {
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
        RongCoreClient.getInstance().setOnReceiveDestructionMessageListener(new IRongCoreListener.OnReceiveDestructionMessageListener() {

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
        RongChatRoomClient.getInstance().setKVStatusListener(new RongChatRoomClient.KVStatusListener() {
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

    private void setMessageExpansionListener() {
        RongCoreClient.getInstance().setMessageExpansionListener(new IRongCoreListener.MessageExpansionListener() {
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

    private void setConversationTagListener() {
        RongCoreClient.getInstance().setConversationTagListener(new IRongCoreListener.ConversationTagListener() {
            @Override
            public void onConversationTagChanged() {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mChannel.invokeMethod(RCMethodList.MethodCallBackConversationTagChanged, new HashMap<>());
                    }
                });
            }
        });
    }

    private void setTagListenerListener() {
        RongCoreClient.getInstance().setTagListener(new IRongCoreListener.TagListener() {
            @Override
            public void onTagChanged() {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mChannel.invokeMethod(RCMethodList.MethodCallBackTagChanged, new HashMap<>());
                    }
                });
            }
        });
    }

    private void setChatRoomAdvancedActionListener() {
        RongChatRoomClient.setChatRoomAdvancedActionListener(new RongChatRoomClient.ChatRoomAdvancedActionListener() {
            @Override
            public void onJoining(String s) {

            }

            @Override
            public void onJoined(String s) {

            }

            @Override
            public void onReset(final String targetId) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        Map resultMap = new HashMap();
                        resultMap.put("targetId", targetId);
                        mChannel.invokeMethod(RCMethodList.MethodCallBackKeyChatRoomReset, resultMap);
                    }
                });
            }

            @Override
            public void onQuited(String s) {

            }

            @Override
            public void onDestroyed(final String targetId, final IRongCoreEnum.ChatRoomDestroyType chatRoomDestroyType) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        Map resultMap = new HashMap();
                        resultMap.put("targetId", targetId);
                        resultMap.put("type", chatRoomDestroyType.getType());
                        mChannel.invokeMethod(RCMethodList.MethodCallBackKeyChatRoomDestroyed, resultMap);
                    }
                });
            }

            @Override
            public void onError(String s, IRongCoreEnum.CoreErrorCode coreErrorCode) {

            }
        });
    }

    /*
     * 输入状态的监听
     */
    private void setTypingStatusListener() {
        RongCoreClient.setTypingStatusListener(new IRongCoreListener.TypingStatusListener() {
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
        RongCoreClient.setConnectionStatusListener(new IRongCoreListener.ConnectionStatusListener() {
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

    private void setMessageBlockListener() {
        RongCoreClient.getInstance().setMessageBlockListener(new IRongCoreListener.MessageBlockListener() {
            @Override
            public void onMessageBlock(final BlockedMessageInfo info) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        Map<String, Object> arguments = new HashMap<>();
                        arguments.put("conversationType", info.getConversationType().getValue());
                        arguments.put("targetId", info.getTargetId());
                        arguments.put("blockMsgUId", info.getBlockMsgUId());
                        arguments.put("blockType", info.getType().value);
                        arguments.put("extra", info.getExtra());
                        mChannel.invokeMethod(RCMethodList.MethodCallBackMessageBlocked, arguments);
                    }
                });
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
        if (TextUtils.isEmpty(objName)) {
            return false;
        }
        if (objName.equalsIgnoreCase("RC:ImgMsg") || objName.equalsIgnoreCase("RC:HQVCMsg")
                || objName.equalsIgnoreCase("RC:SightMsg") || objName.equalsIgnoreCase("RC:FileMsg")
                || objName.equalsIgnoreCase("RC:GIFMsg") || objName.equalsIgnoreCase("RC:CombineMsg")) {
            return true;
        }
        return false;
    }

    private boolean isVoiceMessage(String objName) {
        if (TextUtils.isEmpty(objName)) {
            return false;
        }
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
                if (messageMap.get("sentTime") != null) {
                    message.setSentTime(((Number) messageMap.get("sentTime")).longValue());
                }
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
            RongCoreClient.getInstance().recallMessage(message, pushContent,
                    new IRongCoreCallback.ResultCallback<RecallNotificationMessage>() {
                        @Override
                        public void onSuccess(RecallNotificationMessage recallNotificationMessage) {
                            RLog.d(TAG, "recallMessage success ");
                            Map resultMap = new HashMap();
                            resultMap.put("recallNotificationMessage",
                                    MessageFactory.getInstance().messageContent2String(recallNotificationMessage));
                            resultMap.put("errorCode", 0);
                            RCLog.i("[recallMessage] onSuccess:");
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RLog.d(TAG, "recallMessage errorCode = " + errorCode.getValue());
                            Map resultMap = new HashMap();
                            resultMap.put("recallNotificationMessage", "");
                            resultMap.put("errorCode", errorCode.getValue());
                            RCLog.e("[recallMessage] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().getTextMessageDraft(Conversation.ConversationType.setValue(conversationType),
                    targetId, new IRongCoreCallback.ResultCallback<String>() {
                        @Override
                        public void onSuccess(String s) {
                            RCLog.i("[getTextMessageDraft] onSuccess:" + s);
                            result.success(s);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[getTextMessageDraft] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().saveTextMessageDraft(Conversation.ConversationType.setValue(conversationType),
                    targetId, textContent, new IRongCoreCallback.ResultCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            RCLog.i("[saveTextMessageDraft] onSuccess:");
                            result.success(aBoolean);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.i("[saveTextMessageDraft] onError:");
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
            long recordTime = 0;
            if (paramMap.get("recordTime") != null) {
                recordTime = ((Number) paramMap.get("recordTime")).longValue();
            }
            boolean clearRemote = (boolean) paramMap.get("clearRemote");
            RongCoreClient.getInstance().cleanHistoryMessages(Conversation.ConversationType.setValue(conversationType),
                    targetId, recordTime, clearRemote, new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            RCLog.i("[clearHistoryMessages] onSuccess:");
                            result.success(0);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[clearHistoryMessages] onSuccess:" + errorCode.getValue());
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
            RongCoreClient.getInstance().syncConversationReadStatus(
                    Conversation.ConversationType.setValue(conversationType), targetId, timestamp,
                    new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            RCLog.i("[syncConversationReadStatus] onSuccess:");
                            result.success(0);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[syncConversationReadStatus] onError:" + errorCode.getValue());
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
                RongCoreClient.getInstance().searchConversations(keyword, typeArry, objectNamesArr,
                        new IRongCoreCallback.ResultCallback<List<SearchConversationResult>>() {
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
                                RCLog.i("[searchConversations] onSuccess:");
                                result.success(resultMap);
                            }

                            @Override
                            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                                Map resultMap = new HashMap();
                                resultMap.put("code", errorCode.getValue());
                                RCLog.e("[searchConversations] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().searchMessages(Conversation.ConversationType.setValue(conversationType),
                    targetId, keyword, count, beginTime, new IRongCoreCallback.ResultCallback<List<Message>>() {
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
                            RCLog.i("[searchMessages] onSuccess:");
                            result.success(callBackMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map callBackMap = new HashMap();
                            callBackMap.put("code", errorCode.getValue());
                            RCLog.i("[searchMessages] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().sendTypingStatus(Conversation.ConversationType.setValue(conversationType),
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
            RongCoreClient.getInstance().downloadMediaMessage(message, new IRongCoreCallback.IDownloadMediaMessageCallback() {
                @Override
                public void onSuccess(Message message) {
                    String messageS = MessageFactory.getInstance().message2String(message);
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("message", messageS);
                    resultMap.put("code", 0);
                    RCLog.i("[downloadMediaMessage] onSuccess:");
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
                public void onError(Message message, IRongCoreEnum.CoreErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("code", errorCode.getValue());
                    RCLog.e("[downloadMediaMessage] onError:" + errorCode.getValue());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeyDownloadMediaMessage, resultMap);
                }

                @Override
                public void onCanceled(Message message) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("code", 20);
                    RCLog.e("[downloadMediaMessage] onCanceled:");
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
            RongChatRoomClient.getInstance().setChatRoomEntry(chatRoomId, key, value, sendNotification, autoDelete,
                    notificationExtra, new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(0);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
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
            RongChatRoomClient.getInstance().forceSetChatRoomEntry(chatRoomId, key, value, sendNotification, autoDelete,
                    notificationExtra, new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            RCLog.i("[forceSetChatRoomEntry] onSuccess:");
                            result.success(0);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[forceSetChatRoomEntry] onError:" + errorCode.getValue());
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
            RongChatRoomClient.getInstance().getChatRoomEntry(chatRoomId, key,
                    new IRongCoreCallback.ResultCallback<Map<String, String>>() {
                        @Override
                        public void onSuccess(final Map<String, String> stringStringMap) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", 0);
                                    resultMap.put("entry", stringStringMap);
                                    RCLog.i("[getChatRoomEntry] onSuccess:" + resultMap.toString());
                                    result.success(resultMap);
                                }
                            });
                        }

                        @Override
                        public void onError(final IRongCoreEnum.CoreErrorCode errorCode) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", errorCode.getValue());
                                    resultMap.put("entry", new HashMap<String, String>());
                                    RCLog.e("[getChatRoomEntry] onError:" + resultMap.toString());
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
            RongChatRoomClient.getInstance().getAllChatRoomEntries(chatRoomId,
                    new IRongCoreCallback.ResultCallback<Map<String, String>>() {
                        @Override
                        public void onSuccess(final Map<String, String> stringStringMap) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", 0);
                                    resultMap.put("entry", stringStringMap);
                                    RCLog.i("[getAllChatRoomEntries] onSuccess:" + resultMap.toString());
                                    result.success(resultMap);
                                }
                            });
                        }

                        @Override
                        public void onError(final IRongCoreEnum.CoreErrorCode errorCode) {
                            mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    HashMap resultMap = new HashMap();
                                    resultMap.put("code", errorCode.getValue());
                                    resultMap.put("entry", new HashMap<String, String>());
                                    RCLog.e("[getAllChatRoomEntries] onError:" + resultMap.toString());
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
            RongChatRoomClient.getInstance().removeChatRoomEntry(chatRoomId, key, sendNotification, notificationExtra,
                    new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            RCLog.i("[removeChatRoomEntry] onSuccess:");
                            result.success(0);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[removeChatRoomEntry] onError:" + errorCode.getValue());
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
            RongChatRoomClient.getInstance().forceRemoveChatRoomEntry(chatRoomId, key, sendNotification, notificationExtra,
                    new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            RCLog.i("[forceRemoveChatRoomEntry] onSuccess:");
                            result.success(0);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[forceRemoveChatRoomEntry] onError:" + errorCode.getValue());
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    private void setChatRoomEntries(MethodCall call, final Result result) {
        String chatRoomId = call.argument("chatRoomId");
        Map<String, String> chatRoomEntryMap = call.argument("chatRoomEntryMap");
        Boolean autoRemove = call.argument("autoRemove");
        assert autoRemove != null;
        Boolean overWrite = call.argument("overWrite");
        assert overWrite != null;
        RongChatRoomClient.getInstance().setChatRoomEntries(chatRoomId, chatRoomEntryMap, autoRemove, overWrite, new IRongCoreCallback.SetChatRoomKVCallback() {
            @Override
            public void onSuccess() {
                Map<String, Object> map = new HashMap<>();
                map.put("code", 0);
                result.success(map);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode code, Map<String, IRongCoreEnum.CoreErrorCode> errors) {
                Map<String, Object> map = new HashMap<>();
                map.put("code", code.getValue());
                map.put("errors", errors);
                result.success(map);
            }
        });
    }

    private void removeChatRoomEntries(MethodCall call, final Result result) {
        String chatRoomId = call.argument("chatRoomId");
        List<String> chatRoomEntryList = call.argument("chatRoomEntryList");
        Boolean force = call.argument("force");
        assert force != null;
        RongChatRoomClient.getInstance().deleteChatRoomEntries(chatRoomId, chatRoomEntryList, force, new IRongCoreCallback.SetChatRoomKVCallback() {
            @Override
            public void onSuccess() {
                Map<String, Object> map = new HashMap<>();
                map.put("code", 0);
                result.success(map);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode code, Map<String, IRongCoreEnum.CoreErrorCode> errors) {
                Map<String, Object> map = new HashMap<>();
                map.put("code", code.getValue());
                if (errors != null) {
                    Map<String, Integer> errorMap = new HashMap<>();
                    for (String key : errors.keySet()) {
                        errorMap.put(key, errors.get(key).getValue());
                    }
                    map.put("errors", errorMap);
                }
                result.success(map);
            }
        });
    }

    // 设置消息通知免打扰时间
    private void setNotificationQuietHours(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String startTime = (String) paramMap.get("startTime");
            int spanMins = (int) paramMap.get("spanMins");
            RongCoreClient.getInstance().setNotificationQuietHours(startTime, spanMins,
                    new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            RCLog.i("[setNotificationQuietHours] onSuccess:");
                            result.success(0);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            RCLog.e("[setNotificationQuietHours] onError:" + errorCode.getValue());
                            result.success(errorCode.getValue());
                        }
                    });
        }
    }

    // 删除已设置的全局时间段消息提醒屏蔽
    private void removeNotificationQuietHours(Object arg, final Result result) {
        RongCoreClient.getInstance().removeNotificationQuietHours(new IRongCoreCallback.OperationCallback() {
            @Override
            public void onSuccess() {
                RCLog.i("[removeNotificationQuietHours] onSuccess:");
                result.success(0);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                RCLog.e("[setNotificationQuietHours] onError:" + errorCode.getValue());
                result.success(errorCode.getValue());
            }
        });
    }

    private void getNotificationQuietHours(final Result result) {
        RongCoreClient.getInstance().getNotificationQuietHours(new IRongCoreCallback.GetNotificationQuietHoursCallback() {
            @Override
            public void onSuccess(String startTime, int spanMinutes) {
                HashMap resultMap = new HashMap();
                resultMap.put("code", 0);
                resultMap.put("startTime", startTime);
                resultMap.put("spansMin", spanMinutes);
                RCLog.i("[getNotificationQuietHours] onSuccess:" + resultMap.toString());
                result.success(resultMap);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                HashMap resultMap = new HashMap();
                resultMap.put("code", errorCode.getValue());
                RCLog.e("[getNotificationQuietHours] onError:" + resultMap.toString());
                result.success(resultMap);
            }
        });
    }

    private void getUnreadMentionedMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            RongCoreClient.getInstance().getUnreadMentionedMessages(
                    Conversation.ConversationType.setValue(conversationType), targetId,
                    new IRongCoreCallback.ResultCallback<List<Message>>() {
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
                            RCLog.i("[getUnreadMentionedMessages] onSuccess:");
                            result.success(callBackMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                            Map callBackMap = new HashMap();
                            callBackMap.put("messages", new ArrayList());
                            RCLog.e("[getUnreadMentionedMessages] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().sendDirectionalMessage(Conversation.ConversationType.setValue(conversationType),
                    targetId, messageContent, userIdArr, pushContent, pushData,
                    new IRongCoreCallback.ISendMessageCallback() {
                        @Override
                        public void onAttached(Message message) {
                            String messageS = MessageFactory.getInstance().message2String(message);
                            Map msgMap = new HashMap();
                            msgMap.put("message", messageS);
                            msgMap.put("status", 10);
                            RCLog.i("[sendDirectionalMessage] onAttached:");
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
                            RCLog.i("[sendDirectionalMessage] onSuccess:");
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }

                        @Override
                        public void onError(Message message, IRongCoreEnum.CoreErrorCode errorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("messageId", message.getMessageId());
                            resultMap.put("status", 20);
                            resultMap.put("code", errorCode.getValue());
                            if (timestamp.longValue() > 0) {
                                resultMap.put("timestamp", timestamp);
                            }
                            RCLog.i("[sendDirectionalMessage] onError:" + errorCode.getValue());
                            mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                        }
                    });
        }
    }

    private void forwardMessageByStep(Object arg) {
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

            filterSendMessage(forwardMessage);
            RongCoreClient.getInstance().sendMessage(forwardMessage, "", "", new IRongCoreCallback.ISendMessageCallback() {
                @Override
                public void onAttached(Message message) {

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
                    RCLog.i("[forwardMessageByStep] onSuccess:" + resultMap.toString());
                    mChannel.invokeMethod(RCMethodList.MethodCallBackKeySendMessage, resultMap);
                }

                @Override
                public void onError(Message message, IRongCoreEnum.CoreErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("messageId", message.getMessageId());
                    resultMap.put("status", 20);
                    resultMap.put("code", errorCode.getValue());
                    if (timestamp.longValue() > 0) {
                        resultMap.put("timestamp", timestamp);
                    }
                    RCLog.e("[forwardMessageByStep] onError:" + resultMap.toString());
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
            RongCoreClient.getInstance().beginDestructMessage(message, new IRongCoreListener.DestructCountDownTimerListener() {
                @Override
                public void onTick(final long untilFinished, String messageUId) {
                    int remainDuration = (int) untilFinished;
                    RLog.i("messageBeginDestruct", "onTick :" + untilFinished + " remainDuration:" + remainDuration);
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
        RongCoreClient.getInstance().getMessageByUid(messageUId, new IRongCoreCallback.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                Map resultMap = new HashMap();
                String messageStr = MessageFactory.getInstance().message2String(message);
                resultMap.put("remainDuration", remainDuration);
                resultMap.put("message", messageStr);
                mChannel.invokeMethod(RCMethodList.MethodCallBackDestructMessage, resultMap);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
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
            RongCoreClient.getInstance().stopDestructMessage(message);
        }
    }

    private void deleteRemoteMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            List<Map> messageMapList = (List<Map>) paramMap.get("messages");
            if (messageMapList == null || messageMapList.size() == 0) {
                RCLog.e("[deleteRemoteMessages] message list is null ");
                return;
            }
            Message[] messageArray = new Message[messageMapList.size()];
            for (int i = 0; i < messageMapList.size(); i++) {
                messageArray[i] = map2Message(messageMapList.get(i));
            }
            RongCoreClient.getInstance().deleteRemoteMessages(Conversation.ConversationType.setValue(conversationType), targetId, messageArray, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i("[deleteRemoteMessages] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[deleteRemoteMessages] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void clearMessages(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int conversationType = (int) paramMap.get("conversationType");
            String targetId = (String) paramMap.get("targetId");
            RongCoreClient.getInstance().clearMessages(Conversation.ConversationType.setValue(conversationType), targetId, new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i("[clearMessages] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[clearMessages] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void setMessageExtra(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int messageId = (int) paramMap.get("messageId");
            String value = (String) paramMap.get("value");
            RongCoreClient.getInstance().setMessageExtra(messageId, value, new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i("[setMessageExtra] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[setMessageExtra] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void setMessageReceivedStatus(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int messageId = (int) paramMap.get("messageId");
            int receivedStatus = (int) paramMap.get("receivedStatus");
            RongCoreClient.getInstance().setMessageReceivedStatus(messageId, new Message.ReceivedStatus(receivedStatus), new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    RCLog.i("[setMessageReceivedStatus] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[setMessageReceivedStatus] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void setMessageSentStatus(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int messageId = (int) paramMap.get("messageId");
            final int sentStatus = (int) paramMap.get("sentStatus");
            RongCoreClient.getInstance().getMessage(messageId, new IRongCoreCallback.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    if (message != null) {
                        message.setSentStatus(Message.SentStatus.setValue(sentStatus));
                        RongCoreClient.getInstance().setMessageSentStatus(message, new IRongCoreCallback.ResultCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean aBoolean) {
                                RCLog.i("[setMessageSentStatus] onSuccess:");
                                result.success(0);
                            }

                            @Override
                            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                                RCLog.e("[setMessageSentStatus] onError:" + errorCode.getValue());
                                result.success(errorCode.getValue());
                            }
                        });
                    }
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    result.success(false);
                }
            });
        }
    }

    private void clearConversations(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            List<Integer> conversationTypes = (List<Integer>) paramMap.get("conversationTypes");
            Conversation.ConversationType[] conversationArray = new Conversation.ConversationType[conversationTypes.size()];
            for (int i = 0; i < conversationTypes.size(); i++) {
                conversationArray[i] = Conversation.ConversationType.setValue(conversationTypes.get(i));
            }
            RongCoreClient.getInstance().clearConversations(new IRongCoreCallback.ResultCallback() {
                @Override
                public void onSuccess(Object o) {
                    RCLog.i("[clearConversations] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.i("[clearConversations] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            }, conversationArray);
        }
    }

    private void getDeltaTime(final Result result) {
        Long deltaTime = RongCoreClient.getInstance().getDeltaTime();
        result.success(deltaTime);
    }

    private void setOfflineMessageDuration(Object arg, final Result result) {
        final String TAG = "setOfflineMessageDuration";
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            int duration = (int) paramMap.get("duration");
            RongCoreClient.getInstance().setOfflineMessageDuration(duration, new IRongCoreCallback.ResultCallback<Long>() {
                @Override
                public void onSuccess(Long aLong) {
                    RCLog.i(TAG + " success");
                    Map resultMap = new HashMap();
                    resultMap.put("code", 0);
                    resultMap.put("result", aLong);
                    RCLog.i("[setOfflineMessageDuration] onSuccess:");
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e(TAG + " error:" + errorCode.getValue());
                    Map resultMap = new HashMap();
                    resultMap.put("code", errorCode.getValue());
                    resultMap.put("result", -1);
                    RCLog.e("[setOfflineMessageDuration] onError:" + errorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void getOfflineMessageDuration(final Result result) {
        RongCoreClient.getInstance().getOfflineMessageDuration(new IRongCoreCallback.ResultCallback<String>() {
            @Override
            public void onSuccess(String s) {
                RCLog.i("[getOfflineMessageDuration] onSuccess:");
                result.success(Integer.valueOf(s));
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                RCLog.e("[getOfflineMessageDuration] onError:" + errorCode.getValue());
                result.success(errorCode.getValue());
            }
        });
    }

    private void setReconnectKickEnable(Object arg) {
        if (arg instanceof Boolean) {
            boolean enable = (boolean) arg;
            RongCoreClient.getInstance().setReconnectKickEnable(enable);
        }
    }

    private void getConnectionStatus(final Result result) {
        IRongCoreListener.ConnectionStatusListener.ConnectionStatus connectionStatus = RongCoreClient.getInstance().getCurrentConnectionStatus();
        result.success(connectionStatus.getValue());
    }

    private void cancelDownloadMediaMessage(Object arg, final Result result) {
        if (arg instanceof Integer) {
            int messageId = (int) arg;
            RongCoreClient.getInstance().getMessage(messageId, new IRongCoreCallback.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    if (message != null) {
                        RongCoreClient.getInstance().cancelDownloadMediaMessage(message, new IRongCoreCallback.OperationCallback() {
                            @Override
                            public void onSuccess() {
                                RCLog.i("[cancelDownloadMediaMessage] onSuccess:");
                                result.success(true);
                            }

                            @Override
                            public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                                RCLog.e("[cancelDownloadMediaMessage] onError:" + errorCode.getValue());
                                result.success(false);
                            }
                        });
                    }
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
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
            IRongCoreEnum.TimestampOrder timestampOrder = IRongCoreEnum.TimestampOrder.RC_TIMESTAMP_DESC;
            if (order == 1) {
                timestampOrder = IRongCoreEnum.TimestampOrder.RC_TIMESTAMP_ASC;
            }
            RongChatRoomClient.getInstance().getChatroomHistoryMessages(targetId, recordTime, count, timestampOrder, new IRongCoreCallback.IChatRoomHistoryMessageCallback() {
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
                    RCLog.i("[getRemoteChatRoomHistoryMessages] onSuccess:");
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("code", errorCode.getValue());
                    RCLog.e("[getRemoteChatRoomHistoryMessages] onError:" + errorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void getMessageByUId(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String uId = (String) paramMap.get("messageUId");
            RongCoreClient.getInstance().getMessageByUid(uId, new IRongCoreCallback.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    RCLog.i("[getMessageByUId] onSuccess:");
                    result.success(MessageFactory.getInstance().message2String(message));
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[getMessageByUId] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().getTheFirstUnreadMessage(Conversation.ConversationType.setValue(conversationType), targetId, new IRongCoreCallback.ResultCallback<Message>() {
                @Override
                public void onSuccess(Message message) {
                    RCLog.i("[getFirstUnreadMessage] onSuccess:");
                    result.success(MessageFactory.getInstance().message2String(message));
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[getFirstUnreadMessage] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().updateMessageExpansion(expansion, messageUId, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i("[updateMessageExpansion] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[updateMessageExpansion] onError:" + errorCode.getValue());
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
            RongCoreClient.getInstance().removeMessageExpansion(keyArray, messageUId, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    RCLog.i("[removeMessageExpansion] onSuccess:");
                    result.success(0);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode errorCode) {
                    RCLog.e("[removeMessageExpansion] onError:" + errorCode.getValue());
                    result.success(errorCode.getValue());
                }
            });
        }
    }

    private void batchInsertMessage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            List<Map> messageMapList = (List<Map>) paramMap.get("messageMapList");
            if (messageMapList == null || messageMapList.size() == 0) {
                RCLog.e("[batchInsertMessage] message list is null ");
                return;
            }
            List<Message> messageList = new ArrayList<>();
            for (int i = 0; i < messageMapList.size(); i++) {
                messageList.add(map2Message(messageMapList.get(i)));
            }
            RongCoreClient.getInstance().batchInsertMessage(messageList, new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", aBoolean);
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", false);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void addTag(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String tagId = "";
            if (paramMap.get("tagId") != null) {
                tagId = (String) paramMap.get("tagId");
            }
            String tagName = "";
            if (paramMap.get("tagName") != null) {
                tagName = (String) paramMap.get("tagName");
            }
            int count = 0;
            if (paramMap.get("count") != null) {
                count = (int) paramMap.get("count");
            }
            long timestamp = 0;
            if (paramMap.get("timestamp") != null) {
                timestamp = (((Number) paramMap.get("timestamp")).longValue());
            }
            RongCoreClient.getInstance().addTag(new TagInfo(tagId, tagName, count, timestamp), new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map resultMap = new HashMap();
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void removeTag(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String tagId = "";
            if (paramMap.get("tagId") != null) {
                tagId = (String) paramMap.get("tagId");
            }
            RongCoreClient.getInstance().removeTag(tagId, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map resultMap = new HashMap();
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void updateTag(Object arg, final Result result) {
        Map paramMap = (Map) arg;
        String tagId = "";
        if (paramMap.get("tagId") != null) {
            tagId = (String) paramMap.get("tagId");
        }
        String tagName = "";
        if (paramMap.get("tagName") != null) {
            tagName = (String) paramMap.get("tagName");
        }
        int count = 0;
        if (paramMap.get("count") != null) {
            count = (int) paramMap.get("count");
        }
        long timestamp = 0;
        if (paramMap.get("timestamp") != null) {
            timestamp = (((Number) paramMap.get("timestamp")).longValue());
        }
        RongCoreClient.getInstance().updateTag(new TagInfo(tagId, tagName, count, timestamp), new IRongCoreCallback.OperationCallback() {
            @Override
            public void onSuccess() {
                Map resultMap = new HashMap();
                resultMap.put("code", 0);
                result.success(resultMap);
            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                Map resultMap = new HashMap();
                resultMap.put("code", coreErrorCode.getValue());
                result.success(resultMap);
            }
        });
    }

    private void getTags(Object arg, final Result result) {
        RongCoreClient.getInstance().getTags(new IRongCoreCallback.ResultCallback<List<TagInfo>>() {
            @Override
            public void onSuccess(List<TagInfo> tagInfos) {
                Map resultMap = new HashMap();
                List list = new ArrayList();
                if (tagInfos != null) {
                    for (TagInfo info : tagInfos) {
                        String conStr = MessageFactory.getInstance().tagInfo2String(info);
                        list.add(conStr);
                    }
                }
                resultMap.put("getTags", list);
                resultMap.put("code", 0);
                result.success(resultMap);

            }

            @Override
            public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                Map resultMap = new HashMap();
                resultMap.put("getTags", null);
                resultMap.put("code", coreErrorCode.getValue());
                result.success(resultMap);
            }
        });
    }

    private void getUnreadCountByTag(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String tagId = (String) paramMap.get("tagId");
            boolean containBlocked = (boolean) paramMap.get("containBlocked");
            RongCoreClient.getInstance().getUnreadCountByTag(tagId, containBlocked, new IRongCoreCallback.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", integer);
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", -1);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void setConversationToTopInTag(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            Integer t = (Integer) paramMap.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) paramMap.get("targetId");
            String tagId = (String) paramMap.get("tagId");
            boolean isTop = (boolean) paramMap.get("isTop");
            RongCoreClient.getInstance().setConversationToTopInTag(tagId, new ConversationIdentifier(type, targetId), isTop,
                    new IRongCoreCallback.OperationCallback() {
                        @Override
                        public void onSuccess() {
                            Map resultMap = new HashMap();
                            resultMap.put("result", true);
                            resultMap.put("code", 0);
                            result.success(resultMap);
                        }

                        @Override
                        public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                            Map resultMap = new HashMap();
                            resultMap.put("result", false);
                            resultMap.put("code", coreErrorCode.getValue());
                            result.success(resultMap);
                        }
                    });
        }
    }

    private void addConversationsToTag(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String tagId = (String) paramMap.get("tagId");
            List<Map> identifierList = (List<Map>) paramMap.get("identifiers");
            if (identifierList == null || identifierList.size() == 0) {
                RCLog.e("[deleteRemoteMessages] message list is null ");
                return;
            }
            List<ConversationIdentifier> conversationIdentifierList = new ArrayList<>();
            for (Map identifierMap : identifierList) {
                conversationIdentifierList.add(map2ConversationIdentifier(identifierMap));
            }
            RongCoreClient.getInstance().addConversationsToTag(tagId, conversationIdentifierList, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map resultMap = new HashMap();
                    resultMap.put("result", true);
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", false);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }

    }

    private void removeConversationsFromTag(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String tagId = (String) paramMap.get("tagId");
            List<Map> identifierList = (List<Map>) paramMap.get("identifiers");
            if (identifierList == null || identifierList.size() == 0) {
                RCLog.e("[deleteRemoteMessages] message list is null ");
                return;
            }
            List<ConversationIdentifier> conversationIdentifierList = new ArrayList<>();
            for (Map identifierMap : identifierList) {
                conversationIdentifierList.add(map2ConversationIdentifier(identifierMap));
            }
            RongCoreClient.getInstance().removeConversationsFromTag(tagId, conversationIdentifierList, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map resultMap = new HashMap();
                    resultMap.put("result", true);
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", false);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void removeTagsFromConversation(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            Integer t = (Integer) paramMap.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) paramMap.get("targetId");
            List<String> tagIds = (List<String>) paramMap.get("tagIds");
            RongCoreClient.getInstance().removeTagsFromConversation(new ConversationIdentifier(type, targetId), tagIds, new IRongCoreCallback.OperationCallback() {
                @Override
                public void onSuccess() {
                    Map resultMap = new HashMap();
                    resultMap.put("result", true);
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", false);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });

        }
    }

    private void getTagsFromConversation(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            Integer t = (Integer) paramMap.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) paramMap.get("targetId");
            RongCoreClient.getInstance().getTagsFromConversation(new ConversationIdentifier(type, targetId), new IRongCoreCallback.ResultCallback<List<ConversationTagInfo>>() {
                @Override
                public void onSuccess(List<ConversationTagInfo> conversationTagInfos) {
                    Map resultMap = new HashMap();
                    List list = new ArrayList();
                    if (conversationTagInfos != null) {
                        for (ConversationTagInfo info : conversationTagInfos) {
                            String conStr = MessageFactory.getInstance().conversationTagInfo2String(info);
                            list.add(conStr);
                        }
                    }
                    resultMap.put("ConversationTagInfoList", list);
                    resultMap.put("code", 0);
                    RCLog.i("[getTagsFromConversation] onSuccess:");
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    RCLog.e("[getTagsFromConversation] onError:" + coreErrorCode.getValue());
                    Map resultMap = new HashMap();
                    resultMap.put("ConversationTagInfoList", null);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private void getConversationsFromTagByPage(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            String tagId = (String) paramMap.get("tagId");
            long ts = 0;
            //传 0 的话取最小值，20
            int count = 0;
            if (paramMap.get("ts") != null) {
                ts = (((Number) paramMap.get("ts")).longValue());
            }
            if (paramMap.get("count") != null) {
                count = (int) paramMap.get("count");
            }
            RongCoreClient.getInstance().getConversationsFromTagByPage(tagId, ts, count, new IRongCoreCallback.ResultCallback<List<Conversation>>() {
                @Override
                public void onSuccess(List<Conversation> conversations) {
                    Map resultMap = new HashMap();
                    List l = new ArrayList();
                    if (conversations != null) {
                        for (Conversation con : conversations) {
                            String conStr = MessageFactory.getInstance().conversation2String(con);
                            l.add(conStr);
                        }
                    }
                    resultMap.put("ConversationList", l);
                    resultMap.put("code", 0);
                    RCLog.i("[getConversationsFromTagByPage] onSuccess:");
                    result.success(resultMap);

                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    RCLog.e("[getConversationsFromTagByPage] onError:" + coreErrorCode.getValue());
                    Map resultMap = new HashMap();
                    resultMap.put("ConversationList", null);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });

        }
    }

    private void getConversationTopStatusInTag(Object arg, final Result result) {
        if (arg instanceof Map) {
            Map paramMap = (Map) arg;
            Integer t = (Integer) paramMap.get("conversationType");
            Conversation.ConversationType type = Conversation.ConversationType.setValue(t.intValue());
            String targetId = (String) paramMap.get("targetId");
            String tagId = (String) paramMap.get("tagId");
            RongCoreClient.getInstance().getConversationTopStatusInTag(new ConversationIdentifier(type, targetId), tagId, new IRongCoreCallback.ResultCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean aBoolean) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", aBoolean);
                    resultMap.put("code", 0);
                    result.success(resultMap);
                }

                @Override
                public void onError(IRongCoreEnum.CoreErrorCode coreErrorCode) {
                    Map resultMap = new HashMap();
                    resultMap.put("result", false);
                    resultMap.put("code", coreErrorCode.getValue());
                    result.success(resultMap);
                }
            });
        }
    }

    private ConversationIdentifier map2ConversationIdentifier(Map identifierMap) {
        ConversationIdentifier identifier = new ConversationIdentifier();
        if (identifierMap != null) {
            if (identifierMap.get("targetId") != null) {
                identifier.setTargetId((String) identifierMap.get("targetId"));
            }
            if (identifierMap.get("conversationType") != null) {
                identifier.setType(Conversation.ConversationType.setValue((Integer) identifierMap.get("conversationType")));
            }
        }
        return identifier;
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
                message.setSentTime(((Number) messageMap.get("sentTime")).longValue());
            }
            if (messageMap.get("objectName") != null) {
                message.setObjectName((String) messageMap.get("objectName"));
            }
            if (messageMap.get("messageUId") != null) {
                message.setUId((String) messageMap.get("messageUId"));
            }
            setExtraValue(messageMap, message);
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
        if (!TextUtils.isEmpty(objectName)) {
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
                }
            } else if (objectName != null && objectName.equalsIgnoreCase("RC:ReferenceMsg")) {
                makeReferenceMessage(content, contentStr);
            }
        }
        message.setContent(content);
        return message;
    }

    private void setExtraValue(Map messageMap, Message message) {
        if (messageMap.get("disableNotification") != null && (boolean) messageMap.get("disableNotification")) {
            message.setMessageConfig(new MessageConfig.Builder().setDisableNotification(true).build());
        } else {
            Map messageConfigMap = (Map) messageMap.get("messageConfig");
            if (messageConfigMap != null && messageConfigMap.get("disableNotification") != null) {
                message.setMessageConfig(new MessageConfig.Builder().setDisableNotification((boolean) messageConfigMap.get("disableNotification")).build());
            }
        }
        if (messageMap.get("messagePushConfig") != null) {
            Map messagePushConfigMap = (Map) messageMap.get("messagePushConfig");
            MessagePushConfig.Builder builder = new MessagePushConfig.Builder();
            if (messagePushConfigMap.get("pushTitle") != null) {
                builder.setPushTitle((String) messagePushConfigMap.get("pushTitle"));
            }
            if (messagePushConfigMap.get("pushContent") != null) {
                builder.setPushContent((String) messagePushConfigMap.get("pushContent"));
            }
            if (messagePushConfigMap.get("pushData") != null) {
                builder.setPushData((String) messagePushConfigMap.get("pushData"));
            }
            if (messagePushConfigMap.get("forceShowDetailContent") != null) {
                builder.setForceShowDetailContent((boolean) messagePushConfigMap.get("forceShowDetailContent"));
            }
            if (messagePushConfigMap.get("androidConfig") != null) {
                AndroidConfig.Builder androidBuilder = new AndroidConfig.Builder();
                Map androidConfig = (Map) messagePushConfigMap.get("androidConfig");
                if (androidConfig.get("notificationId") != null) {
                    androidBuilder.setNotificationId((String) androidConfig.get("notificationId"));
                }
                if (androidConfig.get("channelIdMi") != null) {
                    androidBuilder.setChannelIdMi((String) androidConfig.get("channelIdMi"));
                }
                if (androidConfig.get("channelIdHW") != null) {
                    androidBuilder.setChannelIdHW((String) androidConfig.get("channelIdHW"));
                }
                if (androidConfig.get("channelIdOPPO") != null) {
                    androidBuilder.setChannelIdOPPO((String) androidConfig.get("channelIdOPPO"));
                }
                if (androidConfig.get("typeVivo") != null) {
                    androidBuilder.setTypeVivo((String) androidConfig.get("typeVivo"));
                }
                builder.setAndroidConfig(androidBuilder.build());
            }
            if (messagePushConfigMap.get("iOSConfig") != null) {
                IOSConfig iosBuilder = new IOSConfig();
                Map iOSConfig = (Map) messagePushConfigMap.get("iOSConfig");
                if (iOSConfig.get("thread_id") != null) {
                    iosBuilder.setThread_id((String) iOSConfig.get("thread_id"));
                }
                if (iOSConfig.get("apns_collapse_id") != null) {
                    iosBuilder.setApns_collapse_id((String) iOSConfig.get("apns_collapse_id"));
                }
                builder.setIOSConfig(iosBuilder);
            }
            message.setMessagePushConfig(builder.build());
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
            if (objectName != null) {
                FwLog.write(FwLog.F, FwLog.IM, "L-decode_msg-E", "msg_type|stacks", objectName, FwLog.stackToString(e));
            }
        }
        setCommonInfo(contentStr, result);
//        }
        return result;
    }

    public static String getVersion() {
        return sdkVersion;
    }

    private void filterSendMessage(Message message) {
        if (message == null) {
            FwLog.write(FwLog.I, FwLog.IM, "Flutter_Error", "method|reason", "filterSendMessage", "message can't be null!");
        } else if (message.getConversationType() == null) {
            FwLog.write(FwLog.I, FwLog.IM, "Flutter_Error", "method|reason|message", "filterSendMessage", "conversation type can't be null!", message.toString());
        } else if (message.getConversationType() == Conversation.ConversationType.SYSTEM) {
            FwLog.write(FwLog.I, FwLog.IM, "Flutter_Error", "method|reason|message", "filterSendMessage", "conversation type can't be system!", message.toString());
        } else if (TextUtils.isEmpty(message.getTargetId())) {
            FwLog.write(FwLog.I, FwLog.IM, "Flutter_Error", "method|reason|message", "filterSendMessage", "targetId can't be null!", message.toString());
        } else if (message.getContent() == null) {
            FwLog.write(FwLog.I, FwLog.IM, "Flutter_Error", "method|reason|message", "filterSendMessage", "content can't be null!", message.toString());
        } else {
            Map<String, String> expansion = message.getExpansion();
            if (ExpansionUtils.judgeKVIllegality(expansion)) {
                FwLog.write(FwLog.I, FwLog.IM, "Flutter_Error", "method|reason|message", "filterSendMessage", ExpansionUtils.filterSendMessage(message).getMessage(), message.toString());
            }
        }
    }
}
