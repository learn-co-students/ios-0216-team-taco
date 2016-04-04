//
//  UserPactCellView.m
//  Stakes
//
//  Created by Dylan Straughan on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "UserPactCellView.h"
#import "JDDDataSource.h"


@interface UserPactCellView () 

@property (strong, nonatomic) IBOutlet UILabel *name1;
@property (strong, nonatomic) IBOutlet UILabel *name2;
@property (strong, nonatomic) IBOutlet UILabel *name3;
@property (strong, nonatomic) IBOutlet UILabel *pactTitle;
@property (strong, nonatomic) IBOutlet UILabel *pactDetail;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesDetail;
@property (strong, nonatomic) IBOutlet UIImageView *name1Image;
@property (strong, nonatomic) IBOutlet UIImageView *name2Image;
@property (strong, nonatomic) IBOutlet UIImageView *name3Image;
@property (strong, nonatomic) IBOutlet UILabel *name1checkIns;
@property (strong, nonatomic) IBOutlet UILabel *name2checkIns;
@property (strong, nonatomic) IBOutlet UILabel *name3checkIns;
@property (strong, nonatomic) IBOutlet UIButton *checkInButton;



@end


@implementation UserPactCellView


- (IBAction)checkInButtonPressed:(id)sender {
    
   
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
    
    NSLog(@"checkin Button Pressed");
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
        //        [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Error", @"Error")];
    }
}




-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"location info object=%@", [locations lastObject]);
    NSString *latitude = [[NSString alloc]init];
    NSString *longitude = [[NSString alloc]init];
    CLLocation *crnLoc = [locations lastObject];
    latitude= [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
    
    NSLog(@"The cordinates are %@ and %@",latitude,longitude);
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setPact:(JDDPact *)pact{
    _pact = pact;
    [self setShitUp];
}


-(void)setShitUp {
    
    
    // here we are going to have to create new views programatically and add in users in the pact. (probably with a custom xib) This is a sloppy way of doing it for the MVP to get something on screen
    
//    self.pact = [[JDDPact alloc]init];
    
    for (JDDUser *user in self.pact.users) {
        
        if ([user isEqual:self.pact.users[0]]) {
            
            self.name1.text = user.firstName;
            self.name1Image.image = user.userImage;
            
            for (JDDCheckIn * checkIn in user.checkins) {
                
                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
                
                if ([checkIn.pact isEqual:self.pact]) {
                    
                    [goodCount addObject:checkIn];

                }
                self.name1checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];

            }
        } else if ([user isEqual:self.pact.users[1]]) {
            
            self.name2.text = user.firstName;
            self.name2Image.image = user.userImage;
            
            for (JDDCheckIn * checkIn in user.checkins) {
                
                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
                
                if ([checkIn.pact isEqual:self.pact]) {
                    
                    [goodCount addObject:checkIn];
                    
                }
                self.name2checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];
                
            }
        } else if ([user isEqual:self.pact.users[2]]) {
            
            self.name3.text = user.firstName;
            self.name3Image.image = user.userImage;
            
            for (JDDCheckIn * checkIn in user.checkins) {
                
                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
                
                if ([checkIn.pact isEqual:self.pact]) {
                    
                    [goodCount addObject:checkIn];
                    
                }
                self.name3checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];
                
            }
        }
        
        self.pactTitle.text = @"Pact";
        self.pactDetail.text = self.pact.pactDescription;
        self.stakesTitle.text = @"Stakes";
        self.stakesDetail.text = self.pact.stakes;
        
    }


    
    
}

@end
