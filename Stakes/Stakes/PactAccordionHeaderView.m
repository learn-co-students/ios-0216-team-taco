
//
//  PactAccordionHeaderView.m
//  Stakes
//
//  Created by Jeremy Feld on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "PactAccordionHeaderView.h"
#import "Constants.h"
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
    self.sharedData = [JDDDataSource sharedDataSource];
    
    
}

-(void)setPact:(JDDPact *)pact
{
    _pact = pact;
    [self updateUI];
}

-(void)updateUI
{
    if ([self.pact.title isEqualToString:@"Tap On Me :)"]) {  // this is for the Demo pact
        self.pendingLabel.text = @"Demo";
        self.pendingLabel.hidden = NO;
        self.title.text = self.pact.title;
        self.acceptPactButton.hidden  = YES;
        
    } else {                                                            //This is for the rest of the pacts

        self.title.text = self.pact.title;
        NSLog(@"updatingUI self.pact.isactive %d", self.pact.isActive);
        if (!self.pact.isActive) {
            self.pendingLabel.text = @"Pending";

            self.pendingLabel.hidden = NO;
        } else {
            self.pendingLabel.hidden = YES;
        }
        
        NSLog(@"self.pact.users: %@", self.pact.users);
        NSLog(@"userid %@", self.sharedData.currentUser.userID);
        //if self.pact.users value for key current user = 1 then hide the accept pact button
        if ([[self.pact.users valueForKey:self.sharedData.currentUser.userID] isEqualToNumber:@0]) {
            self.acceptPactButton.hidden = NO;
        } else {
            self.acceptPactButton.hidden = YES;
        }
        
    }
}
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserAcceptedPactNotificationName object:self.pact];
    
}

@end
