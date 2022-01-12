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
#import <RongIMLibCore/RongIMLibCore.h>

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

+ (RCMessageContent *)getVoiceMessage:(NSData *)data {
    NSString *LOG_TAG = @"getVoiceMessage";
    NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    RCUserInfo *sendUserInfo = nil;
    RCMentionedInfo *mentionedInfo = nil;
    if ([contentDic valueForKey:@"user"]) {
        NSDictionary *userDict = [contentDic valueForKey:@"user"];
        NSString *userId = [userDict valueForKey:@"id"] ?: @"";
        NSString *name = [userDict valueForKey:@"name"] ?: @"";
        NSString *portraitUri = [userDict valueForKey:@"portrait"] ?: @"";
        NSString *extra = [userDict valueForKey:@"extra"] ?: @"";
        sendUserInfo = [[RCUserInfo alloc] initWithUserId:userId name:name portrait:portraitUri];
        sendUserInfo.extra = extra;
    }
    
    if ([contentDic valueForKey:@"mentionedInfo"]) {
        NSDictionary *mentionedInfoDict = [contentDic valueForKey:@"mentionedInfo"];
        RCMentionedType type = [[mentionedInfoDict valueForKey:@"type"] intValue] ?: 1;
        NSArray *userIdList = [mentionedInfoDict valueForKey:@"userIdList"] ?: @[];
        NSString *mentionedContent = [mentionedInfoDict valueForKey:@"mentionedContent"] ?: @"";
        mentionedInfo = [[RCMentionedInfo alloc] initWithMentionedType:type userIdList:userIdList mentionedContent:mentionedContent];
    }
    NSString *localPath = contentDic[@"localPath"];
    int duration = [contentDic[@"duration"] intValue];
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [RCLog e:[NSString stringWithFormat:@"%@,创建语音消息失败,语音文件路径不存在%@",LOG_TAG,localPath]];
        return nil;
    }
    NSData *voiceData= [NSData dataWithContentsOfFile:localPath];
    RCVoiceMessage *msg = [RCVoiceMessage messageWithAudio:voiceData duration:duration];
    msg.senderUserInfo = sendUserInfo;
    msg.mentionedInfo = mentionedInfo;
    return msg;
}
@end
