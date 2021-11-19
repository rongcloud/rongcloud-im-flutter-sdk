//
//  RCUploadImageStatusListener.h
//  RongIMLib
//
//  Created by litao on 15/8/28.
//  Copyright (c) 2015 RongCloud. All rights reserved.
//

#import "RCMessage.h"
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 图片上传进度更新的IMKit监听

 @discussion 此监听用于 IMKit 发送图片消息（上传到指定服务器）。
 App 在上传图片时，需要在监听中调用 updateBlock、successBlock 与 errorBlock，通知 IMKit
 SDK 当前上传图片的进度和状态，SDK 会更新 UI。
 
 *  \~english
 IMKit listening of image upload progress update.

 @ discussion This listening is used for IMKit to send image messages (uploaded to the specified server).
  When uploading images, App shall call updateBlock, successBlock and errorBlock to notify IMKit SDK  to upload the progress and status of the image during listening and SDK will update the UI.
 */
@interface RCUploadImageStatusListener : NSObject

/*!
 *  \~chinese
 上传的图片消息的消息实体
 
 *  \~english
 The message entity of the uploaded image message 
 */
@property (nonatomic, strong) RCMessage *currentMessage;

/*!
 *  \~chinese
 更新上传进度需要调用的 block [progress:当前上传的进度，0 <= progress < 100]
 
 *  \~english
 The block that shall be called to update the upload progress [progress: current upload progress, 0 < = progress < 100].
 */
@property (nonatomic, strong) void (^updateBlock)(int progress);

/*!
 *  \~chinese
 上传成功需要调用的 block [imageUrl:图片的网络 URL]
 
 *  \~english
 Block to be called for successful upload [imageUrl:network URL of  image]
 */
@property (nonatomic, strong) void (^successBlock)(NSString *imageUrl);

/*!
 *  \~chinese
 上传成功需要调用的 block [errorCode:上传失败的错误码，非 0 整数]
 
 *  \~english
 Block to be called for successful upload [errorCode: error code for failed upload, non-0 integer].
 */
@property (nonatomic, strong) void (^errorBlock)(RCErrorCode errorCode);

/*!
 *  \~chinese
 初始化图片上传进度更新的IMKit监听

 @param message             图片消息的消息实体
 @param progressBlock       更新上传进度需要调用的 block
 @param successBlock        上传成功需要调用的 block
 @param errorBlock          上传失败需要调用的 block

 @return                    图片上传进度更新的 IMKit 监听对象
 
 *  \~english
 Initialize IMKit listening for image upload progress updates.

 @param message The message entity of the image message.
 @param message The block that shall be called to update the upload progress.
 @param message The block to be called for successful upload.
 @param message The block that shall be called for upload failure.

 @ return IMKit listener object for update of image upload progress.
 */
- (instancetype)initWithMessage:(RCMessage *)message
                 uploadProgress:(void (^)(int progress))progressBlock
                  uploadSuccess:(void (^)(NSString *imageUrl))successBlock
                    uploadError:(void (^)(RCErrorCode errorCode))errorBlock;

@end
