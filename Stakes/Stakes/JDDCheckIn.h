//
//  JDDCheckIn.h
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDDPact.h"
#import "JDDUser.h"
@import CoreLocation;

@interface JDDCheckIn : NSObject

@property (nonatomic) NSDate *checkInDate;
@property (nonatomic, strong) CLLocation *checkInLocation;
@property (nonatomic, strong) NSString *checkInMessage;
@property (nonatomic, strong) NSString *checkInID;

@property (nonatomic) NSString * userID;
@property (nonatomic) NSString * pactID;


@end
