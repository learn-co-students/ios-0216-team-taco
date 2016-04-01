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
    JDDPact *pact1 = [self createPact1];
    pact.users = @[dylan, dimitry, jeremy];
    pact1.users = @[dylan, dimitry, jeremy];
    
    [dylan.pacts addObjectsFromArray:@[pact,pact1]];
    [jeremy.pacts addObjectsFromArray:@[pact,pact1]];
    [dimitry.pacts addObjectsFromArray:@[pact,pact1]];

    
    [dylan.checkins addObject:[self createCheckInWtihPact:pact user:dylan]];
    [jeremy.checkins addObject:[self createCheckInWtihPact:pact user:jeremy]];
    [dimitry.checkins addObject:[self createCheckInWtihPact:pact user:dimitry]];
    
    [dylan.checkins addObject:[self createCheckInWtihPact:pact1 user:dylan]];
    [jeremy.checkins addObject:[self createCheckInWtihPact:pact1 user:jeremy]];
    [dimitry.checkins addObject:[self createCheckInWtihPact:pact1 user:dimitry]];
    
    NSLog(@"checkins: %lu",dylan.checkins.count);
    NSLog(@"checkins: %@",dylan.checkins);
    
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
    dylan.pacts = [[NSMutableArray alloc]init];
    dylan.checkins = [[NSMutableArray alloc]init];
    dylan.twitterHandle= @"@DylanStraughan";
    dylan.userImage = [UIImage imageNamed:@"Dylan"];
    
    return dylan;
    
}

-(JDDUser*)createNewUser2 {
    
    JDDUser *jeremy = [[JDDUser alloc]init];
    
    jeremy.firstName = @"Jeremy";
    jeremy.lastName = @"Feld";
    jeremy.emailAddress= @"Jeremy@gmail.com";
    jeremy.phoneNumber= @"3011111112";
    jeremy.userID= @"1278619234799";
    jeremy.pacts = [[NSMutableArray alloc]init];
    jeremy.checkins = [[NSMutableArray alloc]init];
    jeremy.userImage = [UIImage imageNamed:@"Jeremy"];


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
    dimitry.pacts = [[NSMutableArray alloc]init];
    dimitry.checkins = [[NSMutableArray alloc]init];
    dimitry.userImage = [UIImage imageNamed:@"Dimitry"];

    
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

-(JDDPact*)createPact1{
    
    JDDPact *pact = [[JDDPact alloc]init];
    
    pact.title = @"Jump Like an idiot";
    pact.pactDescription = @"Jump 5 times a day";
    pact.stakes = @"Loser has to buy a pony";
    pact.users = [[NSArray alloc]init];
    
    pact.checkInsPerTimeInterval = 7;
    pact.timeInterval = @"week";
    pact.repeating = YES;
    
    pact.allowsShaming = YES;
    pact.twitterPost = @"Im jumping like a clown";
    
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

//-(void)tweetMessageForUserWhoHasntCompletedPact {



// For Twitter API
// needs BOOL (completed or not completed) - NSDate, User and Pact
// if User has not completed checkins in a specific NSdate (BOOL)
// maybe this takes a NSNotification? that is called when a date hits



//}








@end
