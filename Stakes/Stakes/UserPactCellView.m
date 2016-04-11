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

//@property (strong, nonatomic) IBOutlet UILabel *name1;
//@property (strong, nonatomic) IBOutlet UILabel *name2;
//@property (strong, nonatomic) IBOutlet UILabel *name3;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewHeight;

@property (strong, nonatomic) IBOutlet UILabel *pactDetail;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesDetail;
@property (strong, nonatomic) NSArray *pactMembers;
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

    
//    self.locationManager = [[CLLocationManager alloc]init];
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    
//    [self.locationManager startUpdatingLocation]; // after creating JSQMEssageLocationData, call method below
//    
//    _locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//  
//    [self.locationManager requestWhenInUseAuthorization];
//    
//    if ([self.locationManager respondsToSelector:@selector
//         (requestWhenInUseAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    [self.locationManager startUpdatingLocation];

    self.CheckIn = [[JDDCheckIn alloc]init];
    NSDate *now = [NSDate date];

//    self.CheckIn.checkInDate = now;
//    self.CheckIn.checkInMessage = @"";
//    self.CheckIn.checkInLocation = [[CLLocation alloc]init];;
//    self.CheckIn.userID = self.sharedData.currentUser.userID;
//    self.CheckIn.pactID = self.pact.pactID;
//    
//    [self.sharedData.currentUser.checkins addObject:self.CheckIn];
    
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
    
    [self setShitUp];
}


-(void)setShitUp {
    
    

    
//        if (self.stackViewWidth.constant == 0) {
//            CGFloat userViewWidth = 100;//self.scrollView.bounds.size.width / 2;
//           CGFloat userViewHeight = self.scrollView.bounds.size.height;
//            
//            NSUInteger count = 5;
//            CGFloat stackViewWidth = userViewWidth * count;
//            self.stackViewWidth.constant = stackViewWidth;
//            [self.sharedData.firebaseRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//                NSString *currentUserIdString =[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey];
//                NSDictionary *pactID =[[NSDictionary alloc]init];
//                pactID = snapshot.value[@"users"][currentUserIdString][@"pacts"];
//                NSArray *pactIDString = [[NSArray alloc]init];
//                pactIDString =  [pactID allKeys];
//                NSLog(@"id is %@",snapshot.value[pactID]);
//                //                NSLog(@"users %@",snapshot.value[currentUserIdString]);
//                //                NSLog(@"pacts %@",snapshot.value[@"pacts"]);
//                
//            }];
//            
//            for (NSUInteger i = 0; i < count; i++) {
//                UserDescriptionView *view = [[UserDescriptionView alloc] initWithFrame:CGRectMake(0, 0, userViewWidth, userViewHeight)];
//                
//                [self.stackView addArrangedSubview:view];
//            }
//        }
//    } else {
    
    if (self.stackViewWidth.constant == 0) {
        
        
        
        
        CGFloat userViewWidth = 90;
        CGFloat userViewHeight = self.scrollView.bounds.size.height;
        NSUInteger count = self.pact.users.count;
        if (!self.sharedData.pactMembers || !self.sharedData.pactMembers.count) { //just to make sure the array is not nil
            count = 1;
        }
        
        
        CGFloat stackViewWidth = userViewWidth * count;
        self.stackViewWidth.constant = stackViewWidth;
        

        
        for (NSUInteger i = 0; i < count; i++) {
            
            
            UserDescriptionView *view = [[UserDescriptionView alloc] initWithFrame:CGRectMake(0, 0, userViewWidth, userViewHeight)];
            JDDUser *user = [[JDDUser alloc]init];
            
            
            
            [self.sharedData.firebaseRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                
                /*
                 
                 1) Get current information
                 2) Send the current user to the user description nib
                 3) Get the ID of the currentUser pact
                 4) Get the other Users id's associated with that pact
                 5) Send each user info to user description nib
                 
                */
                
                
                
                NSString *currentUserIdString =[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey];  // Gets current user Phone number
                
                NSLog(@"in userPactCellView, currentUserIDString is:%@",currentUserIdString);
                NSDictionary *pactIDDict =[[NSDictionary alloc]init];
                
                pactIDDict = snapshot.value[@"users"][currentUserIdString][@"pacts"]; // a dictionary of all the associated pacts with the current user and their BOOL status
                NSLog(@"in userPactCellView, pactIDDict is: %@",pactIDDict);
                NSArray *pactIDArray = [[NSArray alloc]init];
                
                pactIDArray =  [pactIDDict allKeys]; //  an array of all the pacts ID's of the current User
                NSLog(@"in userPactCellView,  pactIDArray is: %@",pactIDArray);
                
                NSString *pactID = pactIDArray[i];
                NSLog(@"in userPactCellView,  PactID is: %@",pactID);

                NSDictionary *currentUserFireBaseInfo =[[NSDictionary alloc]init];
                
                currentUserFireBaseInfo  = snapshot.value[@"users"][currentUserIdString]; // return current user information
                NSLog(@"in userPactCellView,  currentUserFireBaseInfo is: %@",currentUserFireBaseInfo);

                
                if (i==0) {
                   
                    user.displayName = currentUserFireBaseInfo[@"displayName"];
            
                    user.userImageURL = currentUserFireBaseInfo[@"profileImageURL"];
                    
                    [view setUser:user];
                    [self.stackView addArrangedSubview:view];

                } else {
                
                NSDictionary *otherUserFireBaseID =[[NSDictionary alloc]init];
                self.pactMembers = [[NSArray alloc]init];
                 otherUserFireBaseID = snapshot.value[@"pacts"][pactID][@"users"];
                    self.pactMembers = self.pact.users;
                    NSLog(@"in userPactCellView,  PactID is: %@",pactID);

                 // returns all the other users part of the same pact
                    NSString * otherUserID = self.pactMembers[i];// retruns phoneNumber of other users
                    NSLog(@"other user ID is:%@",otherUserID);
                    
                    
                    NSDictionary *usersInfo =[[NSDictionary alloc]init];
                    
                    usersInfo = snapshot.value[@"users"][otherUserID];
                    
                    user.displayName = usersInfo[@"displayName"];
                    user.userImageURL = usersInfo[@"profileImageURL"];
                    
                    [view setUser:user];
                    [self.stackView addArrangedSubview:view];
                
                
                
                }

                
                
                

                
            }];

            
            
            
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
    
    
}

@end
