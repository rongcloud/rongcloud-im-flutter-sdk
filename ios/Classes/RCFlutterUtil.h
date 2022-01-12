//
//  RCFlutterUtil.h
//  rongcloud_im_plugin
//
//  Created by Sin on 2019/10/15.
//

#import <UIKit/UIKit.h>
#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterUtil : NSObject
+ (UIImage*) getVideoPreViewImage:(NSString *)path;
+ (UIImage *)getThumbnailImage:(NSString *)thumbnailBase64String;
+ (RCMessageContent *)getVoiceMessage:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
