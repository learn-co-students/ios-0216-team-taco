//
//  PactAccordionHeaderView.m
//  Stakes
//
//  Created by Jeremy Feld on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "PactAccordionHeaderView.h"
@interface PactAccordionHeaderView ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *acceptPactButton;
@property (strong, nonatomic) JDDDataSource *sharedData;
@property (weak, nonatomic) IBOutlet UILabel *pendingLabel;


@end


@implementation PactAccordionHeaderView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.acceptPactButton.hidden = YES;
    self.pendingLabel.hidden = YES;
//    [self updateUI];
}

-(void)setPact:(JDDPact *)pact
{
    _pact = pact;
    [self updateAcceptPactWithBlock:^(BOOL completion) {
        if (!completion) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.acceptPactButton.hidden = NO;
            }];
        }
    }];
    
    [self updatePendingWithBlock:^(BOOL hasPendingInvites) {
        if (hasPendingInvites) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.pendingLabel.hidden = NO;
            }];
        }
    }];
}

-(void)updateAcceptPactWithBlock:(void(^)(BOOL))completionBlock
{
    self.sharedData = [JDDDataSource sharedDataSource];
    self.title.text = self.pact.title;
    
    NSLog(@"self.sharedData.currentuser.userid: %@", self.sharedData.currentUser.userID);
    [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/users", self.pact.pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
       
           if ([snapshot.value[self.sharedData.currentUser.userID] isEqualToNumber:@1]) {
               completionBlock(YES);
           } else {
               completionBlock(NO);
           }

    }];
    
}

-(void)updatePendingWithBlock:(void(^)(BOOL))hasPendingInvites
{
    [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/users", self.pact.pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"snapshot value for current PACT \n\n\n\n\n\n\n %@", snapshot.value);
        NSArray *allUserValues = [snapshot.value allValues];
        NSLog(@"ALL USER VALUES ARRAY %@", allUserValues);
        for (NSNumber *num in allUserValues) {
            if ([num isEqualToNumber:@0]) {
                hasPendingInvites(YES);
                return;
            } else {
                [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID]  updateChildValues:@{@"isActive" : [NSNumber numberWithBool:YES] }];
                hasPendingInvites(NO);
            }
        }

        
    }];
    
}

- (IBAction)acceptPactTapped:(id)sender
{
        
        NSLog(@"accept tappeD");
        [[[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] childByAppendingPath:@"users"] updateChildValues:@{self.sharedData.currentUser.userID : [NSNumber numberWithBool:YES] }];
        //update child value for //
    [self updateAcceptPactWithBlock:^(BOOL completion) {
        if (completion) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.acceptPactButton.hidden = YES;
            }];
        }
    }];
    
    [self updatePendingWithBlock:^(BOOL hasPendingInvites) {
        if (hasPendingInvites) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.pendingLabel.hidden = NO;
            }];
        }
    }];
    
}


@end
