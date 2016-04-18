
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
@property (strong, nonatomic) IBOutlet UIStackView *stackView;
@property (strong, nonatomic) IBOutlet UILabel *createdTitle;
@property (strong, nonatomic) IBOutlet UILabel *createdLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkInsTitle;
@property (strong, nonatomic) IBOutlet UILabel *checkInsPerWeekLabel;
@property (strong, nonatomic) IBOutlet UIButton *deletePactButton;
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
    
//    self.pact = self.sharedData.currentPact;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
//    self.pact = self.sharedData.currentPact;
}

-(void)setPact:(JDDPact *)pact{
    _pact = pact;
    [self setShitUp];
}

-(void)setShitUp
{
    // Do any additional setup after loading the view.
    
    // first empty the stackview
    for (UIView *subview in self.stackView.arrangedSubviews){
        [self.stackView removeArrangedSubview:subview];
    }
    
    // then for each user, createa a UserDescriptionView and add it to the stackview
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM'-'dd'-'yyyy'"];
    
    NSString *createText = [dateFormatter stringFromDate:self.pact.dateOfCreation];
    BOOL worked = createText != nil;
    self.createdLabel.text = worked ? createText : @"Error";
    NSLog(@"checkins %lu and timeinterval %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval);
    self.checkInsPerWeekLabel.text = [NSString stringWithFormat:@"%lu times per %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval];
    
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAction:) name:DeletePactConfirmedNotificationName object:nil];
    
    self.sharedData = [JDDDataSource sharedDataSource];


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
