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
@import UIKit;


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
   
    JDDUser * dylan = [self createNewUser1];
    JDDUser * jeremy = [self createNewUser2];
    JDDUser * dimitry = [self createNewUser3];
    
    JDDPact *pact = [self createPact];
    pact.users = @[dylan, dimitry, jeremy];
    
    [dylan.checkins arrayByAddingObject:[self createCheckInWtihPact:pact user:dylan]];
    [jeremy.checkins arrayByAddingObject:[self createCheckInWtihPact:pact user:jeremy]];
    [dimitry.checkins arrayByAddingObject:[self createCheckInWtihPact:pact user:dimitry]];
    
    self.users = [[NSMutableArray alloc]init];
    
    [self.users addObjectsFromArray: @[dylan, dimitry, jeremy]];
    
}

-(JDDUser*)createNewUser1 {
    
    JDDUser *dylan = [[JDDUser alloc]init];
    
    dylan.firstName = @"Dylan";
    dylan.lastName = @"Straughan";
    dylan.emailAddress= @"Dylanvs19@gmail.com";
    dylan.phoneNumber= @"3015128925";
    dylan.userID= @"1278619234798";
    dylan.pacts = [[NSArray alloc]init];
    dylan.checkins = [[NSArray alloc]init];
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
    jeremy.pacts = [[NSArray alloc]init];
    jeremy.checkins = [[NSArray alloc]init];

    jeremy.twitterHandle= @"@jfeld";
    
    return jeremy;
}

-(JDDUser*)createNewUser3 {
    
    JDDUser *dimitry = [[JDDUser alloc]init];
    
    dimitry.firstName = @"Dimitry";
    dimitry.lastName = @"Kruyakla;fnkdmal;fd";
    dimitry.emailAddress= @"Dimitry@gmail.com";
    dimitry.phoneNumber= @"3011111113";
    dimitry.userID= @"1278619234799";
    dimitry.pacts = [[NSArray alloc]init];
    dimitry.checkins = [[NSArray alloc]init];
    
    dimitry.twitterHandle= @"@dKaoiruek";
    
    return dimitry;
}


-(JDDPact*)createPact{
    
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
 
    return pact;
}

-(JDDCheckIn*)createCheckInWtihPact:(JDDPact *)pact user:(JDDUser *)user {
    
    JDDCheckIn *checkIn = [[JDDCheckIn alloc]init];
    
    checkIn.checkInDate = [NSDate date];
    checkIn.checkInLocation = @"thePlaceWithTheThing";
    checkIn.checkInMessage = @"I'm here mothafluppa";
    
    checkIn.user = user;
    checkIn.pact = pact;
    
    return checkIn;
    
}

@end
