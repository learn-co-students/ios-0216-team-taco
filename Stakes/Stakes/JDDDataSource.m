//
//  JDDDataSource.m
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "JDDDataSource.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
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

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self setUpFireBaseRef];
        self.currentUser = [[JDDUser alloc]init];
        self.User = [[JDDUser alloc]init];
        self.twitter = [[STTwitterAPI alloc]init];

    }
    
    return self;
}

-(JDDPact*)createDemoPact{
    
    JDDPact *pact = [[JDDPact alloc]init];
    
    pact.title = @"Gym with Boys";
    pact.pactDescription = @"Need to go to gym 3x a week";
    pact.stakes = @"Loser has to buy beer";
    pact.users = [[NSMutableArray alloc]init];
    
    pact.checkInsPerTimeInterval = 3;
    pact.timeInterval = @"week";
    pact.repeating = YES;
    
    pact.allowsShaming = YES;
    pact.twitterPost = @"man, all these donuts are incredible";
    
    pact.users = [[NSMutableArray alloc]init];
    
    pact.chatRoomID = [[NSString alloc]init];
 
    return pact;
}

-(void)setUpFireBaseRef {
    
    self.firebaseRef = [[Firebase alloc]initWithUrl:@"https://jddstakes.firebaseio.com/"];
    
    //testing something to be deleted after
//    [self.firebaseRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSString *currentUserIdString =[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey];
//        NSDictionary *pactID =[[NSDictionary alloc]init];
//        pactID = snapshot.value[@"users"][currentUserIdString][@"pacts"];
//        NSArray *pactIDString = [[NSArray alloc]init];
//        pactIDString =  [pactID allKeys];
//        NSLog(@"id is %@",snapshot.value[pactID]);
//        //                NSLog(@"users %@",snapshot.value[currentUserIdString]);
//        //                NSLog(@"pacts %@",snapshot.value[@"pacts"]);
//        
//    }];

}

-(JDDUser *)useSnapShotAndCreateUser:(FDataSnapshot *)snapshot {
    
    JDDUser *user = [[JDDUser alloc]init];
    
    user.userID = snapshot.value[@"userID"];
    user.displayName = snapshot.value[@"displayName"];
    user.phoneNumber = snapshot.value[@"phoneNumber"];
    
    if (snapshot.value[@"profileImageURL"]) {
        
        UIImageView * image = [[UIImageView alloc]init];
        [image setImageWithURL:[NSURL URLWithString:snapshot.value[@"profileImageURL"]]];
        user.userImage = image.image;
        
    }
    
    if (snapshot.value[@"twitterHandle"]){
        
        user.twitterHandle = snapshot.value[@"twitterHandle"];
        
    }
    
    if(snapshot.value[@"pacts"]) {
        
        user.pacts = snapshot.value[@"pacts"];
        
        
    }
    
    if(snapshot.value[@"pactHistory"]) {
        
        user.pacts = snapshot.value[@"pactHistory"];
        
    }
    
    if(snapshot.value[@"pendingPacts"]) {
        
        user.pacts = snapshot.value[@"pendingPacts"];
        
    }
    
    return user;
}


-(JDDPact *)useSnapShotAndCreatePact:(FDataSnapshot*)snapshot {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
    
    JDDPact *pact = [[JDDPact alloc]init];
    
    pact.pactID = snapshot.value[@"pactID"];
    pact.pactDescription = snapshot.value[@"pactDescription"];
    pact.title = snapshot.value[@"title"];
    pact.stakes = snapshot.value[@"stakes"];
    pact.repeating = [snapshot.value[@"repeating"] boolValue];
    pact.allowsShaming = [snapshot.value[@"allowsShaming"] boolValue];
    pact.checkInsPerTimeInterval = [snapshot.value[@"allowsShaming"] integerValue];
    pact.twitterPost = snapshot.value[@"twitterPost"];
    pact.dateOfCreation = [dateFormatter dateFromString:snapshot.value[@"dateOfCreation"]];
    pact.users = [[snapshot.value[@"users"]allKeys]mutableCopy];

    return pact;

}

-(JDDCheckIn *)useSnapShotAndCreateCheckIn:(FDataSnapshot*)snapshot {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'-'ss'"];
    
    JDDCheckIn *checkIn = [[JDDCheckIn alloc]init];
    
    checkIn.checkInID = snapshot.value[@"checkInID"];
    checkIn.checkInDate = [dateFormatter dateFromString:snapshot.value[@"checkInDate"]];
    
    checkIn.userID = snapshot.value[@"userID"];
    
    return checkIn;
}




-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDUser:(JDDUser*)user {
    
    NSMutableDictionary *pactDictionary = [[NSMutableDictionary alloc]init];
    
    if (user.pacts.count != 0) {
        
        for (JDDPact*pact in user.pacts) {
            
            [pactDictionary setValue:[NSNumber numberWithBool: pact.isActive] forKey:pact.pactID];
        }
    }
    
    NSMutableDictionary *person = [[NSMutableDictionary alloc] initWithDictionary:@{ @"userID" : user.userID,
                              @"displayName" : user.displayName,
                              @"phoneNumber" : user.phoneNumber,
                               }];
    
    if (user.userImageURL) {
        
        [person setValue:user.userImageURL forKey:@"profileImageURL"];
    }
    if (user.twitterHandle) {
        
        [person setValue:user.twitterHandle forKey:@"twitterHandle"];
    }
    if (pactDictionary) {
        
        [person setValue: pactDictionary forKey:@"pacts"];
    }

    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithDictionary:person];
    
    return dictionary;
    
}

-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDPact:(JDDPact*)pact {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
    
    NSDateFormatter *checkInDateFormatter = [[NSDateFormatter alloc]init];
    [checkInDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
 
    
    NSMutableDictionary *pactDictionary = [[NSMutableDictionary alloc]initWithDictionary:
                                @{
                                      @"title" : pact.title,
                                      @"pactDescription" :pact.pactDescription,
                                      @"stakes" : pact.stakes,
                                      @"repeating" : [NSNumber numberWithBool: pact.repeating],
                                      @"allowsShaming" : [NSNumber numberWithBool: pact.allowsShaming],
                                      @"checkInsPerTimeInterval" :[NSNumber numberWithUnsignedInteger:pact.checkInsPerTimeInterval],
                                      @"dateOfCreation" : [dateFormatter stringFromDate: pact.dateOfCreation],
                                      
                              }];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithDictionary:pactDictionary];
    
    NSMutableDictionary *checkinDictionary = [[NSMutableDictionary alloc]init];
    
    if (pact.pactID) {
        
        [dictionary setValue:pact.pactID forKey:@"pactID"];
        
    }
    
    if (pact.checkIns.count != 0) {
        
        for (JDDCheckIn *checkin in pact.checkIns) {
            
            NSDictionary * checkinItemDict = @{
                                               @"checkInID" :checkin.checkInID,
                                               @"checkInDate" : checkin.checkInDate,
                                               @"userID" : checkin.userID
                                               };
            
            [checkinDictionary setValue:checkinItemDict forKey:checkin.checkInID];
            
        }
        
        [dictionary setValue:checkinDictionary forKey:@"checkIns"];
    }
    
    if (pact.chatRoomID) {
        
        [dictionary setValue:pact.pactID forKey:@"chatRoomID"];

    }
    
    if (pact.twitterPost) {
        
        [dictionary setValue:pact.twitterPost forKey:@"twitterPost"];
        
    }
    
    return dictionary;
    
}






@end
