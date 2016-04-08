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

-(JDDPact*)createDemoPact;

-(JDDUser *)takeSnapShotAndCreateUser:(FDataSnapshot *)snapshot;
    
-(JDDPact *)takeSnapShotAndCreatePact:(FDataSnapshot*)snapshot;

-(JDDCheckIn *)takeSnapShotAndCreateCheckIn:(FDataSnapshot*)snapshot;

-(NSMutableDictionary*)createDictionaryToSendToFirebasefromJDDUser:(JDDUser*)user;

-(NSMutableDictionary*)createDictionaryToSendToFirebasefromJDDPact:(JDDPact*)pact;


@end

