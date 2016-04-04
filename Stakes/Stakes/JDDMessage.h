//
//  JDDMessage.h
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDDUser.h"
#import "JDDPact.h"
@import CoreLocation;

@interface JDDMessage : NSObject



@property (nonatomic, strong) JDDUser *userSender;
@property (nonatomic, strong) JDDPact *pact;

@property (nonatomic, strong) NSDate * messageSendTime;
@property (nonatomic, strong) NSString *messageContent;

@property (nonatomic, strong) CLLocation *location;

@end
