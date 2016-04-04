//
//  UserPactCellView.h
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




@interface UserPactCellView : UITableViewCell <CLLocationManagerDelegate>
@property (nonatomic) JDDPact *pact;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) JDDDataSource *sharedData;
@property (nonatomic, strong) JDDCheckIn *CheckIn;

@end
