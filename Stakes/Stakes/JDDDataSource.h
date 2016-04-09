//
//  JDDDataSource.h
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//


#import "JDDUser.h"
#import "JDDPact.h"
#import "JDDCheckIn.h"
#import "JSQMessage.h"
#import <STTwitter/STTwitter.h>
#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <Accounts/Accounts.h>
#import "AFNetworking.h"


@interface JDDDataSource : NSObject

@property (nonatomic, strong) Firebase *firebaseRef;
@property (nonatomic, strong) JDDUser *currentUser;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;

+ (instancetype)sharedDataSource;

-(void)setUpFireBaseRef;

-(JDDPact*)createPactForFirstTimeUser;

-(JDDPact*)createDemoPact;

-(JDDUser *)useSnapShotAndCreateUser:(FDataSnapshot *)snapshot;
    
-(JDDPact *)useSnapShotAndCreatePact:(FDataSnapshot*)snapshot;

-(JDDCheckIn *)useSnapShotAndCreateCheckIn:(FDataSnapshot*)snapshot;

-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDUser:(JDDUser*)user;

-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDPact:(JDDPact*)pact;

>>>>>>> master

@end

