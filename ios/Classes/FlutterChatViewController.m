//
//  FlutterChatViewController.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/19.
//

#import "FlutterChatViewController.h"
#import "RCFlutterChatViewController.h"

@interface FlutterChatViewController ()
@property (nonatomic, strong) UIViewController *targetVC;
@end

@implementation FlutterChatViewController{
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    UIView * _chatView;
}

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        
        NSDictionary *dic = args;
        RCConversationType type = [dic[@"conversationType"] intValue];
        NSString *targetId = dic[@"targetId"];
        
        RCFlutterChatViewController *chatVC = [[RCFlutterChatViewController alloc] initWithConversationType:type targetId:targetId];
        _chatView = chatVC.view;
        
        CGRect collectionViewFrame = chatVC.conversationMessageCollectionView.frame;
        collectionViewFrame.origin.y += 44;
        collectionViewFrame.size.height -= 44;
        chatVC.conversationMessageCollectionView.frame = collectionViewFrame;
        
        
        _viewId = viewId;
        NSString* channelName = [NSString stringWithFormat:@"rc_chat_view_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
        self.targetVC = chatVC;
        
    }
    
    return self;
}

-(UIView *)view{
    return _chatView;
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
//    if ([[call method] isEqualToString:@"start"]) {
//        [_indicator startAnimating];
//    }else
//        if ([[call method] isEqualToString:@"stop"]){
//            [_indicator stopAnimating];
//        }
//        else {
//            result(FlutterMethodNotImplemented);
//        }
}

@end
