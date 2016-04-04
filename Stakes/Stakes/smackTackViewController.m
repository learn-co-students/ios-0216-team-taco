//
//  smackTackViewController.m
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "smackTackViewController.h"
#import "Firebase.h"


@interface smackTackViewController ()

@property (nonatomic, strong)JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (nonatomic, strong)JSQMessagesBubbleImage *incomingBubbleImageView;

@end

@implementation smackTackViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.title = @"SmackTalk";
    
    // set up sender i.e. currentUser -- This is going to work anonomously for now. current user will get diff oath every time && therefore be seen as a different user in the chatroom;
    
    self.dataSource = [JDDDataSource sharedDataSource];
    
    self.senderId = self.dataSource.currentUser.userID;
    self.senderDisplayName = self.dataSource.currentUser.firstName;
    
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
    
    return self.messages.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)receiveMessagePressed:(UIBarButtonItem *)sender{
    
}

- (void)closePressed:(UIBarButtonItem *)sender{
    
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
