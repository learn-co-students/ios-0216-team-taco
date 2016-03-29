//
//  JDDCheckIn.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "JDDCheckIn.h"
#import "JDDPact.h"
#import "JDDUser.h"

@interface JDDCheckIn ()
@property (nonatomic, strong) JDDPact *pact;
@property (nonatomic, strong) JDDUser *user;
@property (nonatomic) NSUInteger checkInCount;
@property (nonatomic) NSDate *checkInDate;
@property (nonatomic, strong) NSString *checkInLocation;
@property (nonatomic, strong) NSString *checkInMessage;

@end

@implementation JDDCheckIn

@end
