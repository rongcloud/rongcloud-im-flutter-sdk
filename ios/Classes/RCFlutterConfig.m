//
//  RCFlutterConfig.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/6.
//

#import "RCFlutterConfig.h"

@interface RCFlutterConfig ()
@property (nonatomic, assign) BOOL enablePersistentUserInfoCache;

@property (nonatomic, strong) NSDictionary *originDic;
@end
@implementation RCFlutterConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enablePersistentUserInfoCache = YES;
    }
    return self;
}
- (void)updateConf:(NSDictionary *)dic {
    self.originDic = dic;
    NSDictionary *imDic = dic[@"im"];
    if(imDic) {
        self.enablePersistentUserInfoCache = [imDic[@"enablePersistentUserInfoCache"] boolValue];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@]:%@",NSStringFromClass(self.class),self.originDic];
}
@end
