//
//  RCFlutterConfig.h
//  Pods-Runner
//
//  Created by Sin on 2019/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterConfig : NSObject
@property (nonatomic, readonly, assign) BOOL enablePersistentUserInfoCache;

- (void)updateConf:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
