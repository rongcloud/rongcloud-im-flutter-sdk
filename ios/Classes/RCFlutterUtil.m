//
//  RCFlutterUtil.m
//  rongcloud_im_plugin
//
//  Created by Sin on 2019/10/15.
//

#import "RCFlutterUtil.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import <objc/runtime.h>
#import <RongIMLib/RongIMLib.h>

@implementation RCFlutterUtil

+ (UIImage *)getVideoPreViewImage:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    
    if(![path hasPrefix:@"file://"]) {// 必须加 file:// 前缀才能被 AVFoundation 正常识别
        path = [NSString stringWithFormat:@"file://%@",path];
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:path]];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}

+ (UIImage *)getThumbnailImage:(NSString *)thumbnailBase64String {
    if (!thumbnailBase64String) {
        NSLog(@"getThumbnailImage thumbnailBase64String is nil");
        return nil;;
    }
    NSData *imageData = nil;
    if (class_getInstanceMethod([NSData class], @selector(initWithBase64EncodedString:options:))) {
        imageData = [[NSData alloc] initWithBase64EncodedString:thumbnailBase64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    } else {
        imageData = [RCUtilities dataWithBase64EncodedString:thumbnailBase64String];
    }
    UIImage *thumbnailImage = [UIImage imageWithData:imageData];
    return thumbnailImage;
}
@end
