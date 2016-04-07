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


@interface smackTackViewController ()

@property (nonatomic, strong)JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (nonatomic, strong)JSQMessagesBubbleImage *incomingBubbleImageView;
@property (nonatomic, strong)Firebase * messageRef;

@end

@implementation smackTackViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    self.title = @"SmackTalk";
    
    self.dataSource = [JDDDataSource sharedDataSource];
    
    self.senderId = self.dataSource.currentUser.userID;
    self.senderDisplayName = self.dataSource.currentUser.displayName;
    
    self.messageRef = [self.dataSource.firebaseRef childByAppendingPath:@"messages"];
    
    [self setupBubbles];
    
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.messages[indexPath.item];
    
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message =  self.messages[indexPath.item];

    if (message.senderId == self.dataSource.currentUser.userID) {
        
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
    
    return self.currentPact.messages.count;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage * message = self.currentPact.messages[indexPath.row];
    
    for (JDDUser * user in self.currentPact.users) {
        
        if ([message.senderId isEqualToString:user.userID]) {
            
            return [JSQMessagesAvatarImage avatarWithImage:user.userImage];
            
        }
        
    }
    
    return nil; 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)addMessage:(NSString*)stringFromTextField{
    
    JSQMessage *message = [[JSQMessage alloc]initWithSenderId:self.dataSource.currentUser.userID senderDisplayName:self.dataSource.currentUser.displayName
                                                         date:[NSDate date] text:stringFromTextField];
    
    [self.currentPact.messages addObject:message];
    
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    Firebase *itemRef = [self.messageRef childByAutoId];
    
    NSDictionary * message = @{ @"text": text,
                                @"userID":self.dataSource.currentUser.userID,
                                @"twitterHandle": self.dataSource.currentUser.twitterHandle,
//                                @"pactID":self.currentPact.pactID
                                };
    
    [itemRef setValue:message];
    
    [self finishSendingMessage];
    
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
        
        [self.currentPact.messages addObject:message];
        
        [self finishSendingMessage];
        
        return NO;
    }
    return YES;
}

@end
