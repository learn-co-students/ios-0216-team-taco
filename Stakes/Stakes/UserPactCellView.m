//
//  UserPactCellView.m
//  Stakes
//
//  Created by Dylan Straughan on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "UserPactCellView.h"
#import "JDDDataSource.h"
#import "JDDCheckIn.h"
#import "JSQMessage.h"
#import "JSQLocationMediaItem.h"
#import "UserDescriptionView.h"
#import "Firebase.h"
#import "Constants.h"
#import "PactDetailViewController.h"
#import "UserPactsViewController.h"

@interface UserPactCellView () 

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewWidth;
@property (weak, nonatomic) IBOutlet UIView *View1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *pactDetalisHeaderLabel;

@property (weak, nonatomic) IBOutlet UILabel *pactDetailsLabel;

@property (strong, nonatomic) NSArray *pactMembers;
@property (weak, nonatomic) IBOutlet UILabel *MembersCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *stakesLabel;

@property (weak, nonatomic) IBOutlet UILabel *twitterPostLabel;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) CLLocation *location;


@end

@implementation UserPactCellView

//=============================================================================================================================

- (IBAction)checkInButtonPressed:(id)sender {
       
    NSLog(@"checkin Button Pressed");
    
    self.pact.checkIns = [[NSMutableArray alloc]init];

    self.checkIn = [[JDDCheckIn alloc]init];
    NSDate * now = [NSDate date];
    self.checkIn.userID = self.sharedData.currentUser.userID;
    self.checkIn.checkInDate = now;
    
    Firebase *checkinRef = [self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/checkins",self.pact.pactID]];
    
    Firebase *newCheckin = [checkinRef childByAutoId];
    
     self.checkIn.checkInID = [newCheckin.description stringByReplacingOccurrencesOfString:checkinRef.description withString:@""];
    
    NSMutableDictionary *finalCheckinDictionary = [self.sharedData createDictionaryToSendToFirebaseWithJDDCheckIn:self.checkIn];
    
    [newCheckin setValue:finalCheckinDictionary];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector
         (requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
}

//location geo delagates methods.
//=====================================================================================================================
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
        //        [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Error", @"Error")];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location= [locations lastObject];
    self.latitude= self.location.coordinate.latitude;
    self.longitude = self.location.coordinate.longitude;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    NSMutableDictionary *JSQMessageDictionary = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                                 @"senderId" : self.sharedData.currentUser.userID,
                                                                                                 @"senderDisplayName" :self.sharedData.currentUser.displayName,
                                                                                                 @"date" : [dateFormatter stringFromDate:[NSDate date]],
                                                                                                 @"text" : [NSString stringWithFormat:@"%@ just checked in to %f, %f",self.sharedData.currentUser.displayName, self.latitude,self.longitude]
                                                                                                 
                                                                                                 }];
    
    
    [[[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"chatrooms/%@",self.pact.pactID]] childByAutoId] setValue:JSQMessageDictionary];
    
    NSMutableDictionary * locationDictionary = [[NSMutableDictionary alloc]initWithDictionary: @{
                                                                                                 @"senderId" : self.sharedData.currentUser.userID,
                                                                                                 @"senderDisplayName" :self.sharedData.currentUser.displayName,
                                                                                                 @"date" : [dateFormatter stringFromDate:[NSDate date]],
                                                                                                 @"longitude" :[NSNumber numberWithFloat: self.longitude],
                                                                                                 @"latitude" :[NSNumber numberWithFloat: self.latitude]
                                                                                                 }];
    
    [[[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"chatrooms/%@",self.pact.pactID]] childByAutoId] setValue:locationDictionary];

    
    [self.locationManager stopUpdatingLocation];

}
//===================================================================================================================

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.sharedData = [JDDDataSource sharedDataSource];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

}

-(void)setPact:(JDDPact *)pact{
    _pact = pact;
    [self setShitUp];
}

-(void)setShitUp {

    // first empty the stackview
    for (UIView *subview in self.stackView.arrangedSubviews){
        [self.stackView removeArrangedSubview:subview];
        
    }
    
    // then for each user, createa a UserDescriptionView and add it to the stackview
    for (JDDUser *user in self.pact.usersToShowInApp){
       
        UserDescriptionView *view = [[UserDescriptionView alloc]init];
        
        for (JDDCheckIn *checkin in self.pact.checkIns) {
            
            if ([checkin.userID isEqualToString:user.userID]) {
                
                view.checkinsCount ++;
            }
        }
        ;
        NSString *valueIndicator = [NSString stringWithFormat:@"%@",[self.pact.users valueForKey:user.userID]] ;
        NSString *currentPact = [NSString stringWithFormat:@"%@",self.pact.title];
  
        user.isReady = valueIndicator;
        user.currentPactIn = currentPact;
        view.user = user;
        NSLog(@"Is the view's user ready? %@", view.user.isReady);
        // same as [view setUser:user];
        [self.stackView addArrangedSubview:view];
        
        
        if (self.pact.users.count == 2) {
            [view.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.5].active = YES;
        } else {
        [view.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.33].active = YES;
        }
        
        [self.stackView layoutSubviews];//give subviews a size
        view.clipsToBounds = YES;
        
    }
    self.MembersCountLabel.text = [NSString stringWithFormat:@"%li Members",self.pact.users.count];
    self.pactDetalisHeaderLabel.backgroundColor =[UIColor blackColor];
    self.pactDetalisHeaderLabel.textColor = [UIColor whiteColor];
    [self.pactDetalisHeaderLabel setFont: [self.pactDetalisHeaderLabel.font fontWithSize: 14]];

    
    
    self.stakesLabel.backgroundColor =[UIColor blackColor];
    self.stakesLabel.textColor = [UIColor whiteColor];
    self.pactDetailsLabel.text = self.pact.pactDescription;
    [self.stakesLabel setFont: [self.stakesLabel.font fontWithSize: 14]];
    self.stakesLabel.text = @"What are the stakes?";
    
//    NSString *twitterPost =
    self.twitterPostLabel.text = self.pact.stakes;

    

}

- (IBAction)infoButtonTapped:(id)sender
{

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
            PactDetailViewController *pactVC = segue.destinationViewController;
            pactVC.pact = self.pact;
}



@end
