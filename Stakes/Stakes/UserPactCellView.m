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


@interface UserPactCellView () 

@end

@implementation UserPactCellView


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

//    self.CheckIn.checkInDate = now;
//    self.CheckIn.checkInMessage = @"";
//    self.CheckIn.checkInLocation = [[CLLocation alloc]init];;
//    self.CheckIn.userID = self.sharedData.currentUser.userID;
//    self.CheckIn.pactID = self.pact.pactID;
//    
//    [self.sharedData.currentUser.checkins addObject:self.CheckIn];
    
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

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.sharedData = [JDDDataSource sharedDataSource];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

}

-(void)setPact:(JDDPact *)pact{
    _pact = pact;
    
    [self setUpCell];
}


-(void)setUpCell {
    
    // here we are going to have to create new views programatically and add in users in the pact. (probably with a custom xib) This is a sloppy way of doing it for the MVP to get something on screen

        self.pactTitle.text = @"Pact";
        self.stakesTitle.text = @"Stakes";
    
    
    [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/users", self.pact.pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"snapshot value for current user %@", snapshot.value[self.sharedData.currentUser.userID]);
        if ([snapshot.value[self.sharedData.currentUser.userID] isEqualToNumber:@1]) {
            self.pendingButton.hidden = YES;
        }
    }];
    
    
    
    NSLog(@"self.pact.users in userpactcellview %@", self.pact.users);
    //this is a dictionary and we only have phone numbers

    self.name1.text = @"";
    //    cell.name1Image.image = image;
    self.name1checkIns.text = @"x";
    self.pactDetail.text = self.pact.pactDescription;
    self.stakesDetail.text = self.pact.stakes;
    
    self.name2.text = @"";
    //    cell.name2Image.image = cell.pact.users[1].userImage;
    self.name2checkIns.text = @"x";
    
    self.name3.text = @"";
    //    cell.name3Image.image = @"";
    self.name3checkIns.text = @"";
    
}

- (IBAction)pendingButtonTapped:(id)sender
{
    
    NSLog(@"pending tappeD");
    [[[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] childByAppendingPath:@"users"] updateChildValues:@{self.sharedData.currentUser.userID : [NSNumber numberWithBool:YES] }];
    //update child value for //
    
}

@end
