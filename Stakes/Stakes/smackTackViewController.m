//
//  smackTackViewController.m
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "smackTackViewController.h"
#import "Firebase.h"
#import "JSQMessageAvatarImageDataSource.h"
#import "JSQLocationMediaItem.h"



@interface smackTackViewController () <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (nonatomic, strong)JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (nonatomic, strong)JSQMessagesBubbleImage *incomingBubbleImageView;
@property (nonatomic, strong)Firebase * messageRef;
@property (nonatomic) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation smackTackViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    self.title = @"SmackTalk";
    
    self.dataSource = [JDDDataSource sharedDataSource];
    self.chatroom = [[JDDChatRoom alloc]init];
    [self setUpGestureRecognizer];
    
    self.chatroom.chatroomID = self.currentPact.pactID;
    self.chatroom.messages = [[NSMutableArray alloc]init];
    NSLog(@"currentPact: %@",self.currentPact.title);
    self.senderId = self.dataSource.currentUser.userID;
    self.senderDisplayName = self.dataSource.currentUser.displayName;

    self.messageRef = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"chatrooms/%@",self.currentPact.pactID]];
    
    [self setupBubbles];
    
    [self.collectionView collectionViewLayout].outgoingAvatarViewSize = CGSizeZero;
    [self.collectionView collectionViewLayout].incomingAvatarViewSize = CGSizeZero;
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:@"Futura" size:15];
   
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCollectionTapRecognizer:)];
    [self.collectionView addGestureRecognizer:self.tapRecognizer];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}


-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) handleCollectionTapRecognizer:(UITapGestureRecognizer*)recognizer
{
    
    NSLog(@"UITapGesture recognized!");
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if([self.inputToolbar.contentView.textView isFirstResponder])
            [self.inputToolbar.contentView.textView resignFirstResponder];
    }
}

-(void)setUpGestureRecognizer {
    
    self.swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftGestureHappened:)];

    [self.swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [self.view addGestureRecognizer:self.swipeLeft];
    
}

-(void)swipeLeftGestureHappened:(UISwipeGestureRecognizer *)swipeGestureLeft{
    
    NSLog(@"Left Gesture Recognizer is happening!");
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self dismissViewControllerAnimated:YES completion:nil];

    
}

-(void)viewDidAppear:(BOOL)animated {

    [self observeMessages];
    
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.chatroom.messages[indexPath.item];
    
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = self.chatroom.messages[indexPath.item];

    if ([message.senderId isEqualToString: self.dataSource.currentUser.userID]) {
        
        return self.outgoingBubbleImageView;

    } else {
        
        return self.incomingBubbleImageView;

    }
    
}

-(void)setupBubbles {
    
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc]init];
    
    self.outgoingBubbleImageView = [factory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubbleImageView = [factory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.chatroom.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.chatroom.messages.count;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil; 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)addMessage:(NSString*)stringFromTextField withUser: (NSString *)userID andDisplayName:(NSString *)displayName{
    
    JSQMessage *message = [[JSQMessage alloc]initWithSenderId:userID senderDisplayName:displayName
                                                         date:[NSDate date] text:stringFromTextField];
    
    
    [self.chatroom.messages addObject:message];
    
}

-(void)addMessageWithSenderId:(NSString*)senderId displayName:(NSString *)displayName date:(NSString *)dateString longitude:(NSNumber *)longitude andLatitude:(NSNumber*)latitude {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    CLLocation * location = [[CLLocation alloc]initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];

    JSQLocationMediaItem *mediaItem = [[JSQLocationMediaItem alloc]initWithLocation:location];
    
    JSQMessage * message = [[JSQMessage alloc]initWithSenderId:senderId senderDisplayName:displayName date:[dateFormatter dateFromString:dateString] media:mediaItem];
    
    [self.chatroom.messages addObject:message];
    
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    Firebase *itemRef = [self.messageRef childByAutoId];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    NSDictionary * message = @{ @"text": text,
                                @"senderId":self.dataSource.currentUser.userID,
                                @"senderDisplayName": self.dataSource.currentUser.displayName,
                                @"date":[dateFormatter stringFromDate:[NSDate date]]
                                };
    
    [itemRef setValue:message];
    
    [self finishSendingMessage];
    
}

-(void)observeMessages {
    
    NSLog(@"ref : %@",self.messageRef.description);
    
    FQuery *query = [self.messageRef queryLimitedToLast:35];
    
    [query observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        
        if (snapshot.value[@"longitude"] == nil) {
        
        NSString *userID = snapshot.value[@"senderId"];
        NSLog(@"snapshot: %@",snapshot.value);
        NSString *text = snapshot.value[@"text"];
        NSString *displayName = snapshot.value[@"senderDisplayName"];
        
        [self addMessage:text withUser:userID andDisplayName:displayName];

        } else {
            
            NSString *senderId = snapshot.value[@"senderId"];
            NSLog(@"snapshot: %@",snapshot.value);
            NSString *displayName = snapshot.value[@"senderDisplayName"];
            NSString *date = snapshot.value[@"date"];
            NSNumber *latitude = snapshot.value[@"latitude"];
            NSNumber *longitide = snapshot.value[@"longitude"];

            [self addMessageWithSenderId:senderId displayName:displayName date:date longitude:longitide andLatitude:latitude];
            
        }
        
        
        [self finishReceivingMessage];
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"ERROR: %@",error.description);

    }];
    
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatroom.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatroom.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatroom.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.chatroom.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatroom.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        
        
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        
        [self.chatroom.messages addObject:message];
        
        [self finishSendingMessage];
        
        return NO;
    }
    return YES;
}

@end
