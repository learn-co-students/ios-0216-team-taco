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

@interface JDDCheckIn : NSObject

@property (nonatomic) NSDate *checkInDate;
@property (nonatomic, strong) NSString *checkInLocation;
@property (nonatomic, strong) NSString *checkInMessage;

@property (nonatomic) JDDUser * user;
@property (nonatomic) JDDPact * pact;


@end
