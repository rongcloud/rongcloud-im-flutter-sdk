//
//  RCEDownloadItem.h
//  RongEnterpriseApp
//
//  Created by zhaobingdong on 2018/5/15.
//  Copyright © 2018 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 下载状态枚举

 - RCDownloadItemStateWaiting: 等待
 - RCDownloadItemStateChecking: 正在检测是否支持 Range
 - RCDownloadItemStateRunning: 正在下载
 - RCDownloadItemStateSuspended: 暂停
 - RCDownloadItemStateCanceled: 已取消
 - RCDownloadItemStateCompleted: 完成
 - RCDownloadItemStateFailed: 失败
 
 *  \~english
 Download status enumeration.

 - RCDownloadItemStateWaiting: Wait for
 - RCDownloadItemStateChecking: Testing to see if Range is supported.
 - RCDownloadItemStateRunning: Downloading.
 - RCDownloadItemStateSuspended: Suspend
 - RCDownloadItemStateCanceled: Canceled
 - RCDownloadItemStateCompleted: Complete
 - RCDownloadItemStateFailed: Failure
 */
typedef NS_ENUM(NSInteger, RCDownloadItemState) {
    RCDownloadItemStateWaiting = 0,
    RCDownloadItemStateChecking,
    RCDownloadItemStateRunning,
    RCDownloadItemStateSuspended,
    RCDownloadItemStateCanceled,
    RCDownloadItemStateCompleted,
    RCDownloadItemStateFailed
};

NS_ASSUME_NONNULL_BEGIN
@class RCDownloadItem;
@protocol RCDownloadItemDelegate <NSObject>

/**
 *  \~chinese
 下载任务状态变化时调用

 @param item 下载任务对象
 @param state 状态
 
 *  \~english
 Called when the status of the download task changes.

 @param item Download task object.
 @param state Status.
 */
- (void)downloadItem:(RCDownloadItem *)item state:(RCDownloadItemState)state;

/**
 *  \~chinese
 下载进度上报时调用

 @param item 下载任务
 @param progress 下载进度
 
 *  \~english
 Called when the download progress is reported.

 @param item Download task.
 @param progress Download progress.
 */
- (void)downloadItem:(RCDownloadItem *)item progress:(float)progress;

/**
 *  \~chinese
 任务结束时调用

 @param item 下载任务
 @param error 错误信息对象，成功时为 nil
 @param path 下载完成后文件的路径，此路径为相对路径，相对于沙盒根目录 NSHomeDirectory
 
 *  \~english
 Called at the end of the task.

 @param item Download task.
 @param error Error message object, nil on success.
 @param path The path to the file after the download is completed. This path is relative to sandboxie's root directory NSHomeDirectory.
 */
- (void)downloadItem:(RCDownloadItem *)item didCompleteWithError:(NSError *)error filePath:(nullable NSString *)path;
@end

@interface RCDownloadItem : NSObject

/**
 *  \~chinese
 下载状态
 
 *  \~english
 Download status.
 */
@property (nonatomic, assign, readonly) RCDownloadItemState state;

/**
 *  \~chinese
 文件总大小 单位字节
 
 *  \~english
 Total file size in bytes.
 */
@property (nonatomic, assign, readonly) long long totalLength;

/**
 *  \~chinese
 文件当前的大小
 
 *  \~english
 The current size of the file.
 */
@property (nonatomic, assign, readonly) long long currentLength;

/**
 *  \~chinese
 文件对应的网络 URL
 
 *  \~english
 Network URL corresponding to the file.
 */
@property (nonatomic, strong, readonly) NSURL *URL;

/**
 *  \~chinese
 标识是否可恢复下载。 YES 表示可恢复，支持 Range。 NO 表示不支持 Range。
 
 *  \~english
 Identify whether the download can be resumed. YES indicates recoverable and supports Range. NO indicates that Range is not supported.
 */
@property (nonatomic, assign, readonly) BOOL resumable;

/**
 *  \~chinese
 下载任务的标识符
 
 *  \~english
 Identifier of the download task.
 */
@property (nonatomic, copy, readonly) NSString *identify;

/**
 *  \~chinese
 下载任务的代理对象
 
 *  \~english
 Download the proxy object for the task.
 */
@property (nonatomic, weak) id<RCDownloadItemDelegate> delegate;

+ (instancetype) new NS_UNAVAILABLE;

/**
 *  \~chinese
 开始下载
 
 *  \~english
 Start downloading
 */
- (void)downLoad;

/**
 *  \~chinese
 暂停下载
 
 *  \~english
 Suspend download
 */
- (void)suspend;

/**
 *  \~chinese
 恢复下载
 
 *  \~english
 Resume download
 */
- (void)resume;

/**
 *  \~chinese
 取消下载
 
 *  \~english
 Cancel download
 */
- (void)cancel;

@end
NS_ASSUME_NONNULL_END
