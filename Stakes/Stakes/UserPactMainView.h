//
//  UserPactMainView.h
//  Stakes
//
//  Created by Dylan Straughan on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDDPact.h"
#import "JDDUser.h"
#import "JDDCheckIn.h"
#import "JDDDataSource.h"
@import CoreLocation;




@interface UserPactMainView : UIView <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UserPactMainView * contentView;

@property (nonatomic) JDDPact *pact;
@property (strong, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet UILabel *checkInLabel;
@property (strong, nonatomic) IBOutlet UIView *textView;
@property (strong, nonatomic) IBOutlet UILabel *twitterText;
@property (strong, nonatomic) IBOutlet UILabel *TwitterTitle;
@property (strong, nonatomic) IBOutlet UILabel *pactText;
@property (strong, nonatomic) IBOutlet UILabel *stakesText;
@property (strong, nonatomic) IBOutlet UILabel *pactTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UIView *CheckInButtonView;
@property (strong, nonatomic) IBOutlet UIView *viewForScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewheightContraint;

-(void)setShitUp;




@end
