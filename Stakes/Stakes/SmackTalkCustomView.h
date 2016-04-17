//
//  SmackTalkCustomView.h
//  Stakes
//
//  Created by Dylan Straughan on 4/14/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQMessagesCollectionView.h"
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesKeyboardController.h"

@interface SmackTalkCustomView : UIView <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate, JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, UITextViewDelegate>


@end
