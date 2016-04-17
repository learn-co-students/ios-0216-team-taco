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
@property (nonatomic, strong) JDDUser *User;
@property (strong, nonatomic) NSArray *pactMembers;
@property (strong, nonatomic) JDDPact *currentPact;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;

+ (instancetype)sharedDataSource;

-(void)setUpFireBaseRef;

-(JDDPact*)createDemoPact;

-(JDDUser *)useSnapShotAndCreateUser:(FDataSnapshot *)snapshot;
    
-(JDDPact *)useSnapShotAndCreatePact:(FDataSnapshot*)snapshot;

-(JDDCheckIn *)useSnapShotAndCreateCheckIn:(FDataSnapshot*)snapshot;

-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDUser:(JDDUser*)user;

-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDPact:(JDDPact*)pact;

-(NSMutableDictionary*)createDictionaryToSendToFirebaseWithJDDCheckIn:(JDDCheckIn*)checkin;

-(void)observeEventForUsersFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock;
    
-(void)getAllUsersInPact:(JDDPact *)pact completion:(void (^)(BOOL success))completionBlock;

-(void)methodToPullDownPactsFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock;

-(void)establishCurrentUserWithBlock:(void(^)(BOOL))completionBlock;


@end

