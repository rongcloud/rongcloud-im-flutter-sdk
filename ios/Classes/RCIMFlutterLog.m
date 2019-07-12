//
//  RCIMFlutterLog.m
//  Pods-Runner
//
//  Created by Sin on 2019/7/12.
//

#import "RCIMFlutterLog.h"

@implementation RCIMFlutterLog
+ (void)i:(NSString *)content {
    NSLog(@"[RC-Flutter-IM] iOS %@",content);
}
+ (void)e:(NSString *)content {
    NSLog(@"[RC-Flutter-IM] iOS error %@",content);
}
@end
