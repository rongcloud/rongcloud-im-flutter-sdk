//
//  RCFlutterViewFactory.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/19.
//

#import "RCFlutterViewFactory.h"
#import "FlutterChatViewController.h"

@interface RCFlutterViewFactory ()

@end

@implementation RCFlutterViewFactory {
    NSObject<FlutterBinaryMessenger>*_messenger;
}
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    FlutterChatViewController *activity = [[FlutterChatViewController alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return activity;
}
@end
