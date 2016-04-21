
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
    
    pact.title = @"Tap Here To Start";
    pact.pactDescription = @"To create a new pact with your friends";
    pact.stakes = @"To see pact's status";

    pact.users = [[NSMutableDictionary alloc]init];
    
    
    pact.checkInsPerTimeInterval = 3;
    pact.timeInterval = @"week";
    pact.repeating = YES;
    
    pact.allowsShaming = YES;
    pact.twitterPost = @"To message with your pact friends";

    
    pact.users = [[NSMutableDictionary alloc] initWithDictionary:@{self.currentUser.userID : @1 }];
    
    NSLog(@"self.currentuser in datasource %@", self.currentUser.displayName);
    pact.chatRoomID = [[NSString alloc]init];
 
    return pact;
}

-(void)setUpFireBaseRef {
    
    self.firebaseRef = [[Firebase alloc]initWithUrl:@"https://jddstakes.firebaseio.com/"];

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
        user.userImageURL = snapshot.value[@"profileImageURL"];

    }
    
    if (snapshot.value[@"twitterHandle"]){
        
        user.twitterHandle = snapshot.value[@"twitterHandle"];
        
    }
    
    if(snapshot.value[@"pacts"]) {
        
        user.pacts = (NSMutableArray *)snapshot.value[@"pacts"];

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
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];

    JDDPact *pact = [[JDDPact alloc]init];
    
    pact.pactID = (NSString *)snapshot.value[@"pactID"];
    NSLog(@"pactID in initialization is: %@", pact.pactID);
    pact.pactDescription = snapshot.value[@"pactDescription"];
    pact.title = snapshot.value[@"title"];
    pact.stakes = snapshot.value[@"stakes"];
    pact.repeating = [snapshot.value[@"repeating"] boolValue];
    pact.allowsShaming = [snapshot.value[@"allowsShaming"] boolValue];
    pact.checkInsPerTimeInterval = [snapshot.value[@"checkInsPerTimeInterval"] integerValue];
    pact.twitterPost = snapshot.value[@"twitterPost"];
    pact.dateOfCreation = [dateFormatter dateFromString:snapshot.value[@"dateOfCreation"]];
    pact.users = snapshot.value[@"users"];
    
    NSArray *allUserValues = [snapshot.value[@"users"] allValues];
    NSLog(@"ALL USER VALUES ARRAY %@", allUserValues);
    BOOL isActive = YES;
    
    for (NSNumber *num in allUserValues) {
        if ([num isEqualToNumber:@0]) {
            isActive = NO;
        }
    }
    
    pact.isActive = isActive;
    
    // if is active, tell firebase it is active
    if (isActive) {
        [[[self.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:pact.pactID]  updateChildValues:@{@"isActive" : [NSNumber numberWithBool:YES] }];
    }

    pact.timeInterval = snapshot.value[@"timeInterval"];

    pact.checkIns = [[NSMutableArray alloc]init];
    
    for (NSString *checkin in snapshot.value[@"checkins"]) {
        
        
        JDDCheckIn *check = [[JDDCheckIn alloc]init];
        
        check.userID = snapshot.value[@"checkins"][checkin][@"userID"];
        check.checkInDate = [dateFormatter dateFromString:snapshot.value[@"checkins"][checkin][@"userID"]];
        check.checkInID = snapshot.value[@"checkins"][checkin][@"checkInID"];
        
        [pact.checkIns addObject:check];
    }

    
    return pact;

}

-(JDDCheckIn *)useSnapShotAndCreateCheckIn:(FDataSnapshot*)snapshot {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
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
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    NSDateFormatter *checkInDateFormatter = [[NSDateFormatter alloc]init];
    [checkInDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
 
    NSLog(@"\n\n\n\n\n\n creating a pact... what is pact.isActive???? %d", pact.isActive);
    NSMutableDictionary *pactDictionary = [[NSMutableDictionary alloc]initWithDictionary:
                                @{
                                      @"title" : pact.title,
                                      @"pactDescription" :pact.pactDescription,
                                      @"stakes" : pact.stakes,
                                      @"repeating" : [NSNumber numberWithBool: pact.repeating],
                                      @"allowsShaming" : [NSNumber numberWithBool: pact.allowsShaming],
                                      @"timeInterval" : pact.timeInterval,
                                      @"checkInsPerTimeInterval" :[NSNumber numberWithUnsignedInteger:pact.checkInsPerTimeInterval],
                                      @"dateOfCreation" : [dateFormatter stringFromDate: pact.dateOfCreation],
                                      @"isActive" : [NSNumber numberWithBool:pact.isActive]
                                      
                              }];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithDictionary:pactDictionary];
    
    NSMutableDictionary *checkinDictionary = [[NSMutableDictionary alloc]init];
    
    if (pact.pactID) {
        
        [dictionary setValue:pact.pactID forKey:@"pactID"];
        
    }
    
    if (pact.checkIns.count > 0) {
        
        for (JDDCheckIn *checkin in pact.checkIns) {
            
            NSDictionary * checkinItemDict = @{
                                               @"checkInID" :checkin.checkInID,
                                               @"checkInDate" : [dateFormatter stringFromDate:checkin.checkInDate],
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

-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDCheckIn:(JDDCheckIn*)checkin {

    NSDateFormatter *checkInDateFormatter = [[NSDateFormatter alloc]init];
    [checkInDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    NSMutableDictionary * dictionaryToSend = [[NSMutableDictionary alloc]initWithDictionary:@{
                                        @"checkInID" :checkin.checkInID,
                                        @"checkInDate" : [checkInDateFormatter stringFromDate:checkin.checkInDate],
                                        @"userID" : checkin.userID
                                        }];
    
    return dictionaryToSend;
    
}


-(void)establishCurrentUserWithBlock:(void(^)(BOOL))completionBlock {
    
    Firebase *ref = [self.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey]]];
    
    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        self.currentUser = [self useSnapShotAndCreateUser:snapshot];
        
        completionBlock(YES);
        
    }];
    
}

-(void)methodToPullDownPactsFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    
    NSLog(@"current%@", self.currentUser.pacts);
    
    __block NSUInteger numberOfPactsInDataSource = self.currentUser.pacts.count;

    self.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
    
    for (NSString *pactID in self.currentUser.pacts) {
        
        [[self.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@",pactID]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForPacts) {
            
            JDDPact *currentPact = [self useSnapShotAndCreatePact:snapshotForPacts];
            
            NSLog(@"checkinsArray :%@",snapshotForPacts.value[@"checkins"]);
            
            BOOL isUniquePact = YES;
            for (JDDPact *pact in self.currentUser.pactsToShowInApp) {
                
                NSString *pactID = pact.pactID;
                NSString *currentPactID = currentPact.pactID;
                if (pactID && currentPactID) {
                    if ([pactID isEqualToString:currentPact.pactID]) {
                        isUniquePact = NO;
                    }
                }
                
            }
            
            if (isUniquePact) {
                NSLog(@"is unique Pact: %@", currentPact);
                [self.currentUser.pactsToShowInApp addObject:[self useSnapShotAndCreatePact:snapshotForPacts]];
                NSLog(@"self.pacts now holds %ld pacts!", self.currentUser.pactsToShowInApp.count);
            }
            
            numberOfPactsInDataSource--;
            
            if (numberOfPactsInDataSource == 0) {
                completionBlock(YES);
            }
            
        }];
        
    }
    
}

-(void)getAllUsersInPact:(JDDPact *)pact completion:(void (^)(BOOL success))completionBlock
{
    pact.usersToShowInApp = [[NSMutableArray alloc] init];
    __block NSUInteger remainingUsersToFetch = pact.users.count;
    
    // getting the userID information
    for (NSString *user in pact.users) {
        
        // querying firebase and creating user
        Firebase *ref = [self.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",user]];
        
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            JDDUser *person = [self useSnapShotAndCreateUser:snapshot];
            
            BOOL isUniqueUser = YES;
            
            for (JDDUser * pactUser in pact.usersToShowInApp){
                
                if ([pactUser.userID isEqualToString:person.userID]) {
                    NSLog(@"WE ALREADY HAVE THIS User!!!!!");
                    isUniqueUser = NO;
                }
            }
            
            if (isUniqueUser) {
                NSLog(@"is unique User: %@", person);
                [pact.usersToShowInApp addObject:person];
                NSLog(@"userToShowInAppnow holds %ld users!", pact.usersToShowInApp.count);
            }
            
            remainingUsersToFetch--;
            if(remainingUsersToFetch == 0) {
                completionBlock(YES);
            }
        }];
    }
}

// this method is populating the users in the pact so we can use Twitter info etc. in the UserPactVC. Everything is saved in
-(void)observeEventForUsersFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    __block NSUInteger remainingPacts = self.currentUser.pactsToShowInApp.count;
    
    for (JDDPact *pact in self.currentUser.pactsToShowInApp) {
        
        [self getAllUsersInPact:pact completion:^(BOOL success) {
            remainingPacts--;
            
            if(remainingPacts == 0) {
                completionBlock(YES);
            }
        }];
        
    }
    
}

@end
