
//  UserPactDetailView.m
//  Stakes
//
//  Created by Dylan Straughan on 4/15/16.
//  Copyright © 2016 JDD. All rights reserved.

#import <BALoadingView/BALoadingView.h>

#import "UserPactDetailView.h"
#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDCheckIn.h"
#import "UserDescriptionView.h"
#import "Constants.h"



@interface UserPactDetailView ()

@property (strong, nonatomic) IBOutlet UserPactDetailView *contentView;

@property (strong, nonatomic) IBOutlet UIView *statusBarView;
@property (strong, nonatomic) IBOutlet UIView *statusBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintafterAnimation;
@property (strong, nonatomic) IBOutlet UILabel *createdTitle;
@property (strong, nonatomic) IBOutlet UILabel *createdLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkInsTitle;
@property (strong, nonatomic) IBOutlet UILabel *checkInsPerWeekLabel;
@property (strong, nonatomic) IBOutlet UIButton *deletePactButton;
@property (strong, nonatomic) IBOutlet UILabel *timeInterval;
@property (strong, nonatomic) IBOutlet UILabel *checkInsNumber;
@property (strong, nonatomic) IBOutlet UILabel *repeatingLabel;
@property (strong, nonatomic) IBOutlet UILabel *activeLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *expirationDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfDaysLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *topCheckinsLabel;
@property (strong, nonatomic) IBOutlet UILabel *topCheckinsNeededLabel;
@property (strong, nonatomic) IBOutlet UILabel *completedLabel;
@property (strong, nonatomic) IBOutlet UILabel *slashLabel;
@property (assign, nonatomic) BOOL hasUserCompletedPact;
@property (nonatomic, assign) NSUInteger userCheckins;

@property (strong, nonatomic) JDDDataSource *sharedData;

@end

@implementation UserPactDetailView

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
    
    NSLog(@"commonInit called in UserPactDetailView.");
    
    [[NSBundle mainBundle] loadNibNamed:@"UserPactDetailView" owner:self options:nil];
    
    [self addSubview:self.contentView];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    

}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
}

-(void)setPact:(JDDPact *)pact{
    
    _pact = pact;
    
    [self setShitUp];
    
    self.sharedData = [JDDDataSource sharedDataSource];
    
    [self hasCompletedPact];
    
    if (self.pact.isActive) {
        
        [self setShitUp];
        
    } else {
        
        [self setupIfInactive];
        
    }
}


-(void)setupIfInactive {
    
    self.statusBar.hidden = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM'-'dd'-'yyyy'"];
    
    //statusBar
    self.completedLabel.hidden = NO;
    self.completedLabel.text = @"Inactive";
    self.topCheckinsLabel.hidden = YES;
    self.topCheckinsNeededLabel.hidden = YES;
    self.slashLabel.hidden = YES;
    // days left label
    self.numberOfDaysLeftLabel.text = @"N/A";
    // pact details
    self.expirationDateLabel.text = @"N/A";
    self.createdDateLabel.text = [dateFormatter stringFromDate:self.pact.dateOfCreation];
    self.activeLabel.text = @"Inactive";
    
    if (self.pact.repeating) {
        
        self.repeatingLabel.text = @"Repeating";
        
    } else {
        
        self.repeatingLabel.text = @"Not Repeating";
    }
    self.checkInsNumber.text = [NSString stringWithFormat:@"%lu",self.pact.checkInsPerTimeInterval];
    self.timeInterval.text = self.pact.timeInterval;
}

-(void)hasCompletedPact {
    
    self.hasUserCompletedPact = NO;
    
    self.userCheckins = 0;
    
    for (JDDCheckIn *checkin in self.pact.checkIns) {
        
        if ([checkin.userID isEqualToString:self.sharedData.currentUser.userID] && [checkin.checkInDate compare:self.pact.dateOfCreation] == NSOrderedDescending) {
            
            self.userCheckins++;
            
        }
        
    }
    
    if (self.pact.checkInsPerTimeInterval <= self.userCheckins) {
        
        self.hasUserCompletedPact = YES;
    }
    
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


-(void)setShitUp
{
    // Do any additional setup after loading the view.

    if ([self.pact.title isEqualToString:@"Tap Here To Start"]) {
//        
//        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
//        self.widthConstraint = [self.statusBar.widthAnchor constraintEqualToAnchor:self.statusBarView.widthAnchor multiplier:0.01];
//        self.widthConstraint.active = YES;
//        
//        self.deletePactButton.hidden = YES;
//        self.createdLabel.text = @"Dark Ages";
//        self.checkInsNumber.text = [NSString stringWithFormat:@"%d",1];
//        self.timeInterval.text = @"week";
//        
    } else {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM'-'dd'-'yyyy'"];
        
        NSDictionary *timeIntervalNSNumbers = @{
                                                @"day":[NSNumber numberWithInteger:1],
                                                @"week":[NSNumber numberWithInteger:7],
                                                @"month":[NSNumber numberWithInteger:30],
                                                @"year":[NSNumber numberWithInteger:365],
                                                };
        
        if (self.hasUserCompletedPact) {
            // user has completed pact
            
            self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            self.widthConstraint = [self.statusBar.widthAnchor constraintEqualToAnchor:self.statusBarView.widthAnchor multiplier:1];
            self.widthConstraint.active = YES;
            
            //statusBar
            self.completedLabel.hidden = NO;
            self.topCheckinsLabel.hidden = YES;
            self.topCheckinsNeededLabel.hidden = YES;
            self.slashLabel.hidden = YES;
        
            // days left label
            NSTimeInterval timeInt = [timeIntervalNSNumbers[self.pact.timeInterval]intValue];
            NSDate *endDate = [NSDate dateWithTimeInterval:60*60*24*timeInt sinceDate:self.pact.dateOfCreation];
            
            
            self.numberOfDaysLeftLabel.text = [NSString stringWithFormat:@"%li",(long)[UserPactDetailView daysBetweenDate:self.pact.dateOfCreation andDate:endDate]];
            // pact details
            self.expirationDateLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:60*60*24* [timeIntervalNSNumbers[self.pact.timeInterval]intValue] sinceDate:self.pact.dateOfCreation]];
            self.createdDateLabel.text = [dateFormatter stringFromDate:self.pact.dateOfCreation];
            
            if (self.pact.isActive) {
                
                self.activeLabel.text = @"Active";
                
            } else {
                
                self.activeLabel.text = @"Inactive";
            }

            if (self.pact.repeating) {
                
                self.repeatingLabel.text = @"Repeating";
                
            } else {
                
                self.repeatingLabel.text = @"Not Repeating";
            }
            self.checkInsNumber.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.pact.checkInsPerTimeInterval];
            self.timeInterval.text = self.pact.timeInterval;
            
        } else {
            
            // user has not completed pact
            
            self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            self.widthConstraint = [self.statusBar.widthAnchor constraintEqualToAnchor:self.statusBarView.widthAnchor multiplier:self.userCheckins*100/self.pact.checkInsPerTimeInterval*100/100];
            self.widthConstraint.active = YES;
            
            //statusBar
            self.completedLabel.hidden = YES;
            self.topCheckinsLabel.hidden = NO;
            self.topCheckinsLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.userCheckins];
            self.topCheckinsNeededLabel.hidden = NO;
            self.topCheckinsNeededLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.pact.checkInsPerTimeInterval];

            // days left label
            
            NSTimeInterval timeInt = [timeIntervalNSNumbers[self.pact.timeInterval]intValue];
            NSDate *endDate = [NSDate dateWithTimeInterval:60*60*24*timeInt sinceDate:self.pact.dateOfCreation];
            
            
            self.numberOfDaysLeftLabel.text = [NSString stringWithFormat:@"%li",(long)[UserPactDetailView daysBetweenDate:self.pact.dateOfCreation andDate:endDate]];
            // pact details
            self.expirationDateLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:60*60*24* [timeIntervalNSNumbers[self.pact.timeInterval]intValue] sinceDate:self.pact.dateOfCreation]];
            self.createdDateLabel.text = [dateFormatter stringFromDate:self.pact.dateOfCreation];
            
            if (self.pact.isActive) {
                
                self.activeLabel.text = @"Active";
                
            } else {
                
                self.activeLabel.text = @"Inactive";
            }
            
            if (self.pact.repeating) {
                
                self.repeatingLabel.text = @"Repeating";
                
            } else {
                
                self.repeatingLabel.text = @"Not Repeating";
            }
            self.checkInsNumber.text = [NSString stringWithFormat:@"%lu",self.pact.checkInsPerTimeInterval];
            self.timeInterval.text = self.pact.timeInterval;
            
            
        }
    }
    
}



-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)deleteButtonTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UserWantsToDeletePactNotificationName object:self.pact];
}

@end
