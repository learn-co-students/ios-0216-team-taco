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
//    [self setUpCell];
}


//-(void)setUpCell {
//    
//    // here we are going to have to create new views programatically and add in users in the pact. (probably with a custom xib) This is a sloppy way of doing it for the MVP to get something on screen
//
//        self.pactTitle.text = @"Pact";
//        self.stakesTitle.text = @"Stakes";
//    
//    
//    [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/users", self.pact.pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"snapshot value for current user %@", snapshot.value[self.sharedData.currentUser.userID]);
//        if ([snapshot.value[self.sharedData.currentUser.userID] isEqualToNumber:@1]) {
//            self.pendingButton.hidden = YES;
//        }
//    }];
//    
//    
//    
//    NSLog(@"self.pact.users in userpactcellview %@", self.pact.users);
//    //this is a dictionary and we only have phone numbers
//
//    self.name1.text = @"";
//    //    cell.name1Image.image = image;
//    self.name1checkIns.text = @"x";
//    self.pactDetail.text = self.pact.pactDescription;
//    self.stakesDetail.text = self.pact.stakes;
//    
//    self.name2.text = @"";
//    //    cell.name2Image.image = cell.pact.users[1].userImage;
//    self.name2checkIns.text = @"x";
//    
//    self.name3.text = @"";
//    //    cell.name3Image.image = @"";
//    self.name3checkIns.text = @"";
//    
//}

- (IBAction)pendingButtonTapped:(id)sender
{
    
    NSLog(@"pending tappeD");
    [[[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] childByAppendingPath:@"users"] updateChildValues:@{self.sharedData.currentUser.userID : [NSNumber numberWithBool:YES] }];
    //update child value for //

}


-(void)setShitUp {

    
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
    
}

@end
