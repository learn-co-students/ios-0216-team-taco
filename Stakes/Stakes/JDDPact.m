//
//  JDDPact.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "JDDPact.h"

@interface JDDPact ()

@end

@implementation JDDPact

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _title = @"";
        _pactDescription = @"";
        _stakes = @"";
        _users = [NSMutableArray new];
        _usersToShowInApp = [NSMutableArray new];
        _pactID = @"";
        _dateOfCreation = [NSDate date];
        _timeInterval = @"";
        _checkIns = [NSMutableArray new];
        _twitterPost = @"";
        _chatRoomID = @"";
    
    }
    
    return self;
}

@end
