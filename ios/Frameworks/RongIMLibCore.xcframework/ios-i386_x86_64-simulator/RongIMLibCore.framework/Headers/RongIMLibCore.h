/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RongIMLibCore.h
//  Created by xugang on 14/12/11.

#import <UIKit/UIKit.h>

//! Project version number for RongIMLibCore.
FOUNDATION_EXPORT double RongIMLibCoreVersionNumber;

//! Project version string for RongIMLibCore.
FOUNDATION_EXPORT const unsigned char RongIMLibCoreVersionString[];

/// IMLib
#import <RongIMLibCore/RCCoreClient.h>
#import <RongIMLibCore/RCChannelClient.h>
#import <RongIMLibCore/RCConversationChannelProtocol.h>
#import <RongIMLibCore/RCStatusDefine.h>
/// Conversation
#import <RongIMLibCore/RCConversation.h>
#import <RongIMLibCore/RCGroup.h>
#import <RongIMLibCore/RCUserTypingStatus.h>
/// Message
#import <RongIMLibCore/RCCommandMessage.h>
#import <RongIMLibCore/RCCommandNotificationMessage.h>
#import <RongIMLibCore/RCContactNotificationMessage.h>
#import <RongIMLibCore/RCGroupNotificationMessage.h>
#import <RongIMLibCore/RCImageMessage.h>
#import <RongIMLibCore/RCGIFMessage.h>
#import <RongIMLibCore/RCInformationNotificationMessage.h>
#import <RongIMLibCore/RCMessage.h>
#import <RongIMLibCore/RCMessageContent.h>
#import <RongIMLibCore/RCMediaMessageContent.h>
#import <RongIMLibCore/RCProfileNotificationMessage.h>
#import <RongIMLibCore/RCRecallNotificationMessage.h>
#import <RongIMLibCore/RCRichContentMessage.h>
#import <RongIMLibCore/RCTextMessage.h>
#import <RongIMLibCore/RCUnknownMessage.h>
#import <RongIMLibCore/RCVoiceMessage.h>
#import <RongIMLibCore/RCHQVoiceMessage.h>
#import <RongIMLibCore/RCSightMessage.h>
#import <RongIMLibCore/RCReferenceMessage.h>
#import <RongIMLibCore/RCMessageConfig.h>
#import <RongIMLibCore/RCMessagePushConfig.h>
#import <RongIMLibCore/RCiOSConfig.h>
#import <RongIMLibCore/RCAndroidConfig.h>
#import <RongIMLibCore/RCTagInfo.h>
#import <RongIMLibCore/RCConversationIdentifier.h>
#import <RongIMLibCore/RCConversationTagInfo.h>
#import <RongIMLibCore/RCTagProtocol.h>

/// Util
#import <RongIMLibCore/RCAMRDataConverter.h>
#import <RongIMLibCore/RCTSMutableDictionary.h>
#import <RongIMLibCore/RCUtilities.h>
#import <RongIMLibCore/interf_dec.h>
#import <RongIMLibCore/interf_enc.h>

/// Other
#import <RongIMLibCore/RCStatusMessage.h>
#import <RongIMLibCore/RCUploadImageStatusListener.h>
#import <RongIMLibCore/RCUploadMediaStatusListener.h>
#import <RongIMLibCore/RCUserInfo.h>
#import <RongIMLibCore/RCWatchKitStatusDelegate.h>
#import <RongIMLibCore/RCRemoteHistoryMsgOption.h>
#import <RongIMLibCore/RCHistoryMessageOption.h>

#import <RongIMLibCore/RCFileMessage.h>
#import <RongIMLibCore/RCFileUtility.h>
#import <RongIMLibCore/RCReadReceiptInfo.h>
#import <RongIMLibCore/RCUserOnlineStatusInfo.h>
#import <RongIMLibCore/RCConversationStatusInfo.h>
#import <RongIMLibCore/RCGroupMessageReaderV2.h>
#import <RongIMLibCore/RCGroupReadReceiptV2Manager.h>
#import <RongIMLibCore/RCGroupReadReceiptV2Protocol.h>
#import <RongIMLibCore/RCGroupReadReceiptInfoV2.h>

// log
#import <RongIMLibCore/RCFwLog.h>

// Downlad
#import <RongIMLibCore/RCDownloadItem.h>
#import <RongIMLibCore/RCResumeableDownloader.h>
