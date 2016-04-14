
//
//  PactAccordionHeaderView.m
//  Stakes
//
//  Created by Jeremy Feld on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "PactAccordionHeaderView.h"
@interface PactAccordionHeaderView ()
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

}

-(void)setPact:(JDDPact *)pact
{
    _pact = pact;
    [self updateUI];
}

-(void)updateUI
{
    self.title.text = self.pact.title;
    NSLog(@"updatingUI self.pact.isactive %d", self.pact.isActive);
    if (!self.pact.isActive) {
        self.pendingLabel.hidden = NO;
    } else {
        self.pendingLabel.hidden = YES;
    }
    
    //if self.pact.users value for key current user = 1 then hide the accept pact button
    if ([[self.pact.users valueForKey:self.sharedData.currentUser.userID] isEqualToNumber:@0]) {
        self.acceptPactButton.hidden = NO;
    } else {
        self.acceptPactButton.hidden = YES;
    }
    
    
// [self updateAcceptPactWithBlock:^(BOOL completion) {
//        if (!completion) {
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                self.acceptPactButton.hidden = NO;
//            }];
//        }
//    }];
//    
//    [self updatePendingWithBlock:^(BOOL hasPendingInvites) {
//        if (hasPendingInvites) {
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                self.pendingLabel.hidden = NO;
//            }];
//        }
//        if (!hasPendingInvites) {
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                self.pendingLabel.hidden = YES;
//            }];
//        }
//    }];
}

//-(void)updateAcceptPactWithBlock:(void(^)(BOOL))completionBlock
//{
//    self.sharedData = [JDDDataSource sharedDataSource];
//    
//    NSLog(@"self.sharedData.currentuser.userid: %@", self.sharedData.currentUser.userID);
//    [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/users", self.pact.pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        if (snapshot.value == [NSNull null]) {
//            completionBlock(YES);
//            return;
//        }
//        if ([snapshot.value[self.sharedData.currentUser.userID] isEqualToNumber:@1]) {
//            completionBlock(YES);
//        } else {
//            completionBlock(NO);
//        }
//
//    }];
//    
//}
//
//-(void)updatePendingWithBlock:(void(^)(BOOL))hasPendingInvites
//{
//    [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/users", self.pact.pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"snapshot value for current PACT \n\n\n\n\n\n\n %@", snapshot.value);
//        
//        if (snapshot.value == [NSNull null] ) {
//            hasPendingInvites(NO);
//            return;
//        }
//        
//        self.pact.users = snapshot.value;
//        
//        NSArray *allUserValues = [snapshot.value allValues];
//        NSLog(@"ALL USER VALUES ARRAY %@", allUserValues);
//        BOOL hasPending = NO;
//        
//        for (NSNumber *num in allUserValues) {
//            if ([num isEqualToNumber:@0]) {
//                hasPending = YES;
//            }
//        }
//        
//        if (!hasPending) {
//            [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID]  updateChildValues:@{@"isActive" : [NSNumber numberWithBool:YES] }];
//            hasPendingInvites(NO);
//        } else {
//            hasPendingInvites(YES);
//        }
//    }];
//}

- (IBAction)acceptPactTapped:(id)sender
{
    
    NSLog(@"accept tappeD");
    [[[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] childByAppendingPath:@"users"] updateChildValues:@{self.sharedData.currentUser.userID : [NSNumber numberWithBool:YES] }];

    //updating the dateofCreation every time someone accepts a pact
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    NSString *dateString = [dateFormatter stringFromDate: currentDate];
    [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] updateChildValues:@{ @"dateOfCreation" : dateString }];
    
//    [self updateAcceptPactWithBlock:^(BOOL completion) {
//        if (completion) {
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                self.acceptPactButton.hidden = YES;
//            }];
//            
//            [self updatePendingWithBlock:^(BOOL hasPendingInvites) {
//                if (hasPendingInvites) {
//                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                        self.pendingLabel.hidden = NO;
//                    }];
//                }
//            }];
//            
//        }
//    }];
    

    
}


@end
