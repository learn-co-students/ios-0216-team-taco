//
//  JDDDataSource.m
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDPact.h"
#import "JDDCheckIn.h"
#import "JDDMessage.h"

@implementation JDDDataSource


+ (instancetype)sharedDataSource {
    
    static JDDDataSource *_sharedPiratesDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPiratesDataStore = [[JDDDataSource alloc] init];
    });
    
    return _sharedPiratesDataStore;
}

-(void)generateFakeData{
    
    [self createNewUser1];
    
}

-(JDDUser*)createNewUser1 {
    
    JDDUser *dylan = [[JDDUser alloc]init];
    
    dylan.firstName = @"Dylan";
    dylan.lastName = @"Straughan";
    dylan.emailAddress= @"Dylanvs19@gmail.com";
    dylan.phoneNumber= @"3015128925";
    dylan.userID= @"1278619234798";
    dylan.checkins = [[NSArray alloc]init];
    dylan.pacts = [[NSArray alloc]init];
    dylan.twitterHandle= @"@DylanStraughan";
    
    return dylan;
}

-(JDDUser*)createNewUser2 {
    
    JDDUser *jeremy = [[JDDUser alloc]init];
    
    jeremy.firstName = @"Jeremy";
    jeremy.lastName = @"Feld";
    jeremy.emailAddress= @"Jeremy@gmail.com";
    jeremy.phoneNumber= @"3011111112";
    jeremy.userID= @"1278619234799";
    jeremy.checkins = [[NSArray alloc]init];
    jeremy.pacts = [[NSArray alloc]init];
    jeremy.twitterHandle= @"@jfeld";
    
    return jeremy;
}

-(void)createPact{
    
    JDDPact *pact = [[JDDPact alloc]init];
    
    pact.title = @"Gym with Boys";
    pact.pactDescription = @"Need to go to gym 3x a week";
    pact.stakes = @"Loser has to buy beer";
    pact.users = [[NSArray alloc]init];
    
    pact.checkInsPerTimeInterval = 3;
    pact.timeInterval = @"week";
    pact.repeating = YES;
    
    pact.allowsShaming = YES;
    pact.twitterPost = @"I didn't go to the gym so I suck";
    
    pact.messages = nil;
    
}

-(void)createCheckInWtihPact:(JDDPact *)pact user:(JDDUser *)user {
    
    JDDCheckIn *checkIn = [[JDDCheckIn alloc]init];
    
    checkIn.checkInDate = [NSDate date];
    checkIn.checkInLocation = @"thePlaceWithTheThing";
    checkIn.checkInMessage = @"I'm here mothafluppa";
    
    checkIn.user = user;
    checkIn.pact = pact;
    
}

@end
