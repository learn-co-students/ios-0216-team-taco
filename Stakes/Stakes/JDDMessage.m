//
//  JDDMessage.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "JDDMessage.h"
#import "JDDUser.h"
#import "JDDPact.h"

@interface JDDMessage ()

@property (nonatomic, strong) NSDate * messageSendTime;
@property (nonatomic, strong) NSString *messageContent;
@property (nonatomic, strong) JDDUser *userSender;
@property (nonatomic, strong) JDDPact *pact;

@end

@implementation JDDMessage

@end
