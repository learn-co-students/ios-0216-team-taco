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
#import "JDDMessage.h"
#import "Firebase.h"


@class smackTackViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(smackTackViewController *)vc;

@end

@interface smackTackViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (weak, nonatomic) id <JSQDemoViewControllerDelegate> delegateModal;

//@property (strong, nonatomic) DemoModelData *demoData; // need message data? take from datastore;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

@end
