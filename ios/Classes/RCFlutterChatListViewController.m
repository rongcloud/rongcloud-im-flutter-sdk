//
//  RCFlutterChatListViewController.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/5.
//

#import "RCFlutterChatListViewController.h"
#import "RCFlutterChatViewController.h"

@implementation RCFlutterChatListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
    RCFlutterChatViewController *chatVC = [[RCFlutterChatViewController alloc] initWithConversationType:model.conversationType targetId:model.targetId];
    [self.navigationController pushViewController:chatVC animated:YES];
}
@end
