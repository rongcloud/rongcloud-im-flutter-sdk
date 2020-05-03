//
//  RCFlutterUtil.h
//  rongcloud_im_plugin
//
//  Created by Sin on 2019/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterUtil : NSObject
+ (UIImage*) getVideoPreViewImage:(NSString *)path;
+ (UIImage *)getThumbnailImage:(NSString *)thumbnailBase64String;
@end

NS_ASSUME_NONNULL_END
