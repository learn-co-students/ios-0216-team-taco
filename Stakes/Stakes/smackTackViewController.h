//
//  smackTackViewController.h
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import "JSQMessages.h"
#import "JDDDataSource.h"
#import "JDDChatRoom.h"
#import "Firebase.h"
#import "JDDPact.h"


@class smackTackViewController;

@interface smackTackViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (nonatomic, strong)NSMutableArray *messages;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) JDDChatRoom *chatroom;
@property (nonatomic, strong) JDDPact *currentPact;

@end
