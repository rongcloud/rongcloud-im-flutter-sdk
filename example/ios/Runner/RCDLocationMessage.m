//
//  RCDLocationMessage.m
//  Runner
//
//  Created by 孙浩 on 2021/9/6.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//


#import "RCDLocationMessage.h"

@interface RCDLocationMessage ()

@property (nonatomic, copy) NSString *imageLocalPath;

@end

@implementation RCDLocationMessage
//这个尺寸在生成缩略图的地方有定义，还有发送位置消息时对尺寸有裁剪。如果修改尺寸，需要把对应的地方同时修改
#define TARGET_LOCATION_THUMB_WIDTH 408
#define TARGET_LOCATION_THUMB_HEIGHT 240
#define KEY_LOCATION_EXTRA @"extra"
#define KEY_LOCATION_THUMBNAIL_IMAGE @"thumbnailImage"
#define KEY_LOCATION_LOCATION_NAME @"locationName"
#define KEY_LOCATION_LATITUDE @"latitude"
#define KEY_LOCATION_LONGITUDE @"longitude"
#define KEY_LOCATION_DESTRUCTDURATION @"burnDuration"

#pragma mark - RCMessageCoding delegate methods
+ (instancetype)messageWithLocationImage:(UIImage *)image
                                location:(CLLocationCoordinate2D)location
                            locationName:(NSString *)locationName {
    RCDLocationMessage *message = [[RCDLocationMessage alloc] init];
    if (!message) {
        return message;
    }
    float configImageWidth = 408;
    float configImageHeight = 240;
    float configImageQuality = 0.7;
    NSData *imageData = [RCUtilities compressedImageAndScalingSize:image targetSize:CGSizeMake(configImageWidth, configImageHeight) percent:configImageQuality];
    message.thumbnailImage = [UIImage imageWithData:imageData];
    message.location = location;
    if (locationName) {
        message.locationName = locationName;
    } else {
        message.locationName =
            [NSString stringWithFormat:@"%lf %lf", message.location.longitude, message.location.latitude];
    }
    return message;
}

- (NSData *)encode {
    NSData *imageData = UIImageJPEGRepresentation(self.thumbnailImage, 0.7);
    NSString *thumbnailBase64String = nil;
    if ([imageData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        thumbnailBase64String = [imageData base64EncodedStringWithOptions:kNilOptions];
    } else {
        thumbnailBase64String = [RCUtilities base64EncodedStringFrom:imageData];
    }

    NSMutableDictionary *dict = nil;
    @try {
        dict = [NSMutableDictionary
            dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:self.location.longitude], @"longitude",
                                         [NSNumber numberWithDouble:self.location.latitude], @"latitude",
                                         self.locationName, @"poi", thumbnailBase64String, @"content", nil];
        if (self.extra) {
            [dict setObject:self.extra forKey:@"extra"];
        }

        if (self.destructDuration > 0) {
            [dict setObject:@(self.destructDuration) forKey:KEY_LOCATION_DESTRUCTDURATION];
        }

        if (self.senderUserInfo) {
            [dict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
        }

        if (self.mentionedInfo) {
            [dict setObject:[self encodeMentionedInfo:self.mentionedInfo] forKey:@"mentionedInfo"];
        }
        
        if (self.imageLocalPath) {
            [dict setObject:self.imageLocalPath forKey:@"mImgUri"];
        }

    } @catch (NSException *exception) {
        RCLogE(@"%@", exception);
        dict = [NSMutableDictionary dictionary];
    } @finally {
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (!data) {
        return;
    }
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!dictionary || error) {
        RCLogE(@"decode error %@", error.localizedDescription);
        return;
    }
    self.extra = [dictionary objectForKey:@"extra"];
    self.destructDuration = [[dictionary objectForKey:KEY_LOCATION_DESTRUCTDURATION] integerValue];
    NSDictionary *mentionedInfoDic = [dictionary objectForKey:@"mentionedInfo"];
    [self decodeMentionedInfo:mentionedInfoDic];
    NSDictionary *userinfoDic = [dictionary objectForKey:@"user"];
    [super decodeUserInfo:userinfoDic];

    NSString *thumbnailBase64String = [dictionary objectForKey:@"content"];
    if (thumbnailBase64String) {
        NSData *data = [RCUtilities dataWithBase64EncodedString:thumbnailBase64String];
        self.thumbnailImage = [UIImage imageWithData:data];
    } else {
        self.imageLocalPath = [dictionary valueForKey:@"mImgUri"];
        UIImage *image = [UIImage imageWithContentsOfFile:self.imageLocalPath];
        self.thumbnailImage = image;
    }
    NSNumber *latitude = [dictionary objectForKey:@"latitude"];
    NSNumber *longitude = [dictionary objectForKey:@"longitude"];

    if ([latitude isKindOfClass:[NSNumber class]] && [longitude isKindOfClass:[NSNumber class]]) {
        self.location = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    }

    self.locationName = [dictionary objectForKey:@"poi"];
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED;
}

- (NSString *)description {
    NSString *desc =
        [NSString stringWithFormat:@"location info (%f, %f)", self.location.longitude, self.location.latitude, nil];
    return desc;
}

+ (NSString *)getObjectName {
    return RCDLocationMessageTypeIdentifier;
}

#pragma mark - NSCoding protocol methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.extra = [aDecoder decodeObjectForKey:KEY_LOCATION_EXTRA];
        self.thumbnailImage = [aDecoder decodeObjectForKey:KEY_LOCATION_THUMBNAIL_IMAGE];
        self.locationName = [aDecoder decodeObjectForKey:KEY_LOCATION_LOCATION_NAME];
        CLLocationDegrees latitude = [aDecoder decodeDoubleForKey:KEY_LOCATION_LATITUDE];
        CLLocationDegrees longitude = [aDecoder decodeDoubleForKey:KEY_LOCATION_LONGITUDE];
        self.location = CLLocationCoordinate2DMake(latitude, longitude);
        self.destructDuration = [aDecoder decodeIntegerForKey:KEY_LOCATION_DESTRUCTDURATION];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.extra forKey:KEY_LOCATION_EXTRA];
    [aCoder encodeObject:self.thumbnailImage forKey:KEY_LOCATION_THUMBNAIL_IMAGE];
    [aCoder encodeObject:self.locationName forKey:KEY_LOCATION_LOCATION_NAME];
    [aCoder encodeDouble:self.location.latitude forKey:KEY_LOCATION_LATITUDE];
    [aCoder encodeDouble:self.location.longitude forKey:KEY_LOCATION_LONGITUDE];
    [aCoder encodeInteger:self.destructDuration forKey:KEY_LOCATION_DESTRUCTDURATION];
}

- (NSString *)conversationDigest {
    NSString *digest = @"[位置]";
    return digest;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    [super dealloc];
}
#endif //__has_feature(objc_arc)
@end

