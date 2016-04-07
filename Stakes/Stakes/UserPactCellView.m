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


@interface UserPactCellView () 

//@property (strong, nonatomic) IBOutlet UILabel *name1;
//@property (strong, nonatomic) IBOutlet UILabel *name2;
//@property (strong, nonatomic) IBOutlet UILabel *name3;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewHeight;
@property (strong, nonatomic) IBOutlet UILabel *pactTitle;
@property (strong, nonatomic) IBOutlet UILabel *pactDetail;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesDetail;
//@property (strong, nonatomic) IBOutlet UIImageView *name1Image;
//@property (strong, nonatomic) IBOutlet UIImageView *name2Image;
//@property (strong, nonatomic) IBOutlet UIImageView *name3Image;
//@property (strong, nonatomic) IBOutlet UILabel *name1checkIns;
//@property (strong, nonatomic) IBOutlet UILabel *name2checkIns;
//@property (strong, nonatomic) IBOutlet UILabel *name3checkIns;
//@property (strong, nonatomic) IBOutlet UIButton *checkInButton;



@end

@implementation UserPactCellView

//=============================================================================================================================





- (IBAction)checkInButtonPressed:(id)sender {
       
    NSLog(@"checkin Button Pressed");

    
    self.locationManager = [[CLLocationManager alloc]init];
//    self.locationManager.delegate = self; // need to figure out if we bring this up to userPactVC with NSNotificationCenter
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation]; // after creating JSQMEssageLocationData, call method below
    
    //need to create checkin - then add it to currentuser w/ pact info

//    JDDCheckIn *checkin = [[JDDCheckIn alloc]init];
    
//    JSQLocationMediaItem *location = [[JSQLocationMediaItem alloc]initWithLocation:self.locationManager.location];
//
//    JSQMessage *locationMessage = [[JSQMessage alloc] initWithSenderId:self.dataSource.currentUser.userID senderDisplayName:self.dataSource.currentUser.firstName date:[NSDate date] media:location];
//    
//    [self.pact.messages addObject:locationMessage];
//    
//    [self.locationManager stopUpdatingLocation];
//    
//    JSQMessage * textMessage = [[JSQMessage alloc]initWithSenderId:self.dataSource.currentUser.userID senderDisplayName:self.dataSource.currentUser.firstName date:[NSDate date] text:[NSString stringWithFormat:@"%@ just checked in!",self.dataSource.currentUser.firstName]];
//    
//    [self.pact.messages addObject:textMessage];
    
//     identify user w oath? phone number?
//     take location - add to messages.
//    JDDCheckIn *checkin = [[JDDCheckIn alloc]init];
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
  
    [self.locationManager requestWhenInUseAuthorization];
    
    if ([self.locationManager respondsToSelector:@selector
         (requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    self.CheckIn = [[JDDCheckIn alloc]init];
    NSDate *now = [NSDate date];

    self.CheckIn.checkInDate = now;
    self.CheckIn.checkInMessage = @"";
    self.CheckIn.checkInLocation = [[CLLocation alloc]init];;
    self.CheckIn.userID = self.sharedData.currentUser.userID;
    self.CheckIn.pactID = self.pact.pactID;
    
    [self.sharedData.currentUser.checkins addObject:self.CheckIn];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
        //        [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Error", @"Error")];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    NSLog(@"location info object=%@", [locations lastObject]);
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
    
//    [self setShitUp];
}


-(void)setShitUp {
    if (self.sharedData.users == nil) {
        if (self.stackViewWidth.constant == 0) {
            CGFloat userViewWidth = 100;//self.scrollView.bounds.size.width / 2;
            CGFloat userViewHeight = self.scrollView.bounds.size.height;
            NSUInteger count = 5;
            CGFloat stackViewWidth = userViewWidth * count;
            self.stackViewWidth.constant = stackViewWidth;
            
            for (NSUInteger i = 0; i < count; i++) {
                UserDescriptionView *view = [[UserDescriptionView alloc] initWithFrame:CGRectMake(0, 0, userViewWidth, userViewHeight)];
                
                [self.stackView addArrangedSubview:view];
            }
        }
    } else {
    
    if (self.stackViewWidth.constant == 0) {
        CGFloat userViewWidth = 100;//self.scrollView.bounds.size.width / 2;
        CGFloat userViewHeight = self.scrollView.bounds.size.height;
        NSUInteger count = self.sharedData.users.count;
        CGFloat stackViewWidth = userViewWidth * count;
        self.stackViewWidth.constant = stackViewWidth;
        
        for (NSUInteger i = 0; i < count; i++) {
            UserDescriptionView *view = [[UserDescriptionView alloc] initWithFrame:CGRectMake(0, 0, userViewWidth, userViewHeight)];
            JDDUser *user = [[JDDUser alloc]init];
            user = self.sharedData.users[i];
            [view setUser:user];
            
            [self.stackView addArrangedSubview:view];
            NSLog(@"view name is %@", view.userNameLabel.text);
        }
    }
    
        
    }
}


    // here we are going to have to create new views programatically and add in users in the pact. (probably with a custom xib) This is a sloppy way of doing it for the MVP to get something on screen
    
//    for (JDDUser *user in self.pact.users) {
//        
//        if ([user isEqual:self.pact.users[0]]) {
//            
//            self.name1.text = user.firstName;
//            self.name1Image.image = user.userImage;
//            
//            for (JDDCheckIn * checkIn in user.checkins) {
//                
//                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
//                
//                if ([checkIn.pact isEqual:self.pact]) {
//                    
//                    [goodCount addObject:checkIn];
//
//                }
//                self.name1checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];
//
//            }
//            
//        } else if ([user isEqual:self.pact.users[1]]) {
//            
//            self.name2.text = user.firstName;
//            self.name2Image.image = user.userImage;
//            
//            for (JDDCheckIn * checkIn in user.checkins) {
//                
//                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
//                
//                if ([checkIn.pact isEqual:self.pact]) {
//                    
//                    [goodCount addObject:checkIn];
//                    
//                }
//                self.name2checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];
//                
//            }
//            
//        } else if ([user isEqual:self.pact.users[2]]) {
//            
//            self.name3.text = user.firstName;
//            self.name3Image.image = user.userImage;
//            
//            for (JDDCheckIn * checkIn in user.checkins) {
//                
//                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
//                
//                if ([checkIn.pact isEqual:self.pact]) {
//                    
//                    [goodCount addObject:checkIn];
//                    
//                }
//                self.name3checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];
//                
//            }
//        }
//
//    
//    for (NSUInteger i = 0; i<self.sharedData.users.count; i++) {
//        UserDescriptionView *userView = [[UserDescriptionView alloc] init];
//        
//        [self.stackView addArrangedSubview:userView];
//    }
//        self.pactTitle.text = @"Pact";
//        self.pactDetail.text = self.pact.pactDescription;
//        self.stakesTitle.text = @"Stakes";
//        self.stakesDetail.text = @"";
    
    


@end
