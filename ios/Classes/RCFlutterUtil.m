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
@end
