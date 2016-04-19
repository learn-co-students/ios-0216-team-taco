//
//  JDDPact.h
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "JDDUser.h"

@interface JDDPact : NSObject

//Pact Information
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString * pactDescription;
@property (nonatomic, strong) NSString *stakes;
@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSMutableArray *usersToShowInApp;
@property (nonatomic, strong) NSString *pactID; // this should be the unique identifier for a pact throughout the application - and what gets writted to firebase.
@property (nonatomic, assign) NSDate *dateOfCreation;
@property (nonatomic) BOOL isActive;
@property (nonatomic, assign) NSDate * currentExpirationDate;

//CheckIn Information
@property (nonatomic) NSUInteger checkInsPerTimeInterval;
@property (nonatomic, strong) NSString *timeInterval;
@property (nonatomic) BOOL repeating;
@property (nonatomic, strong)NSMutableArray *checkIns;

//Twitter Stuff
@property (nonatomic) BOOL allowsShaming;
@property (nonatomic, strong) NSString *twitterPost;

//Message Stuff
@property (nonatomic,strong) NSString *chatRoomID;

#pragma methods

//- (instancetype)init;

@end

