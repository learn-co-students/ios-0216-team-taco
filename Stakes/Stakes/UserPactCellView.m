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

@interface UserPactCellView () 

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewHeight;

@property (strong, nonatomic) NSArray *pactMembers;
@property (weak, nonatomic) IBOutlet UILabel *pactTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pactDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *stakesLabel;
@property (weak, nonatomic) IBOutlet UILabel *stakesDetailLabel;


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
    
//    
//    self.locationManager = [[CLLocationManager alloc]init];
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.delegate = self;
//    [self.locationManager requestWhenInUseAuthorization];
//    if ([self.locationManager respondsToSelector:@selector
//         (requestWhenInUseAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    
//    [self.locationManager startUpdatingLocation];
//
//    Firebase *itemRef = [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"chatrooms/%@",self.pact.pactID]] childByAutoId];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
//    
//    NSDictionary *LocationToSendToFirebase = @{
//                                               @"senderID" : self.sharedData.currentUser.userID,
//                                               @"date" : [dateFormatter stringFromDate:[NSDate date]],
//                                               @"longitude" : self.locationManager
//                                               };
//    
//    
//    
//    [itemRef setValue:LocationToSendToFirebase];
    

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
    NSString *latitude = @"";
    NSString *longitude = @"";
    CLLocation *crnLoc = [locations lastObject];
    latitude= [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
     
    
    NSLog(@"The cordinates are %@ and %@",latitude,longitude);
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
        
        view.user = user;
        
        // same as [view setUser:user];
        [self.stackView addArrangedSubview:view];
        
        [view.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.5].active = YES;
        [self.stackView layoutSubviews];//give subviews a size
        view.clipsToBounds = YES;
        
    }
    
    
    self.pactTitle.text = self.pact.title;
    self.pactDetail.text = self.pact.pactDescription;
    self.stakesLabel.text = self.pact.stakes;
    [self.stakesDetail sizeToFit];
    self.stakesDetail.text = [NSString stringWithFormat:@"%lu per %@ \n to keep the pact",self.pact.checkInsPerTimeInterval,self.pact.timeInterval];
    

}

@end
