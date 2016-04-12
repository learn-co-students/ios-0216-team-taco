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



@interface smackTackViewController ()

@property (nonatomic, strong)JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (nonatomic, strong)JSQMessagesBubbleImage *incomingBubbleImageView;
@property (nonatomic, strong)Firebase * messageRef;
@property (nonatomic) UISwipeGestureRecognizer *swipeLeft;

@end

@implementation smackTackViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    self.title = @"SmackTalk";
    
    self.dataSource = [JDDDataSource sharedDataSource];
    self.chatroom = [[JDDChatRoom alloc]init];
    [self setUpGestureRecognizer];
    [self setUpNavBar];
    self.chatroom.chatroomID = self.currentPact.pactID;
    self.chatroom.messages = [[NSMutableArray alloc]init];
    NSLog(@"currentPact: %@",self.currentPact.title);
    self.senderId = self.dataSource.currentUser.userID;
    self.senderDisplayName = self.dataSource.currentUser.displayName;

    self.messageRef = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"chatrooms/%@",self.currentPact.pactID]];
        
    [self setupBubbles];
    
    [self.collectionView collectionViewLayout].outgoingAvatarViewSize = CGSizeZero;
    [self.collectionView collectionViewLayout].incomingAvatarViewSize = CGSizeZero;

    
}

-(void)setUpNavBar {
    
    UINavigationBar *navBar = [[UINavigationBar alloc]init];
    [self.view addSubview:navBar];

    navBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navBar.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [navBar.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.1].active = YES;
    [navBar.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [navBar.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    navBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    navBar.topItem.title = self.currentPact.title;
    
    

    
}

-(void)setUpGestureRecognizer {
    
    self.swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftGestureHappened:)];

    [self.swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [self.view addGestureRecognizer:self.swipeLeft];
    
}

-(void)swipeLeftGestureHappened:(UISwipeGestureRecognizer *)swipeGestureLeft{
    
    NSLog(@"Left Gesture Recognizer is happening!");
    
    
    
    [self performSegueWithIdentifier:@"segueBackToUserPactsVC" sender:self];
    
}

-(void)viewDidAppear:(BOOL)animated {

    [self observeMessages];
    
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.chatroom.messages[indexPath.item];
    
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message =  self.chatroom.messages[indexPath.item];

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
    
    NSDictionary * message = @{ @"text": text,
                                @"userID":self.dataSource.currentUser.userID,
                                @"displayName": self.dataSource.currentUser.displayName,
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
