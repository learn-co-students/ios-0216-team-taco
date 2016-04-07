//
//  JDDDataSource.h
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"
#import "JDDUser.h"git
#import "JDDPact.h"
#import <STTwitter/STTwitter.h>
#import <Accounts/Accounts.h>
#import <AFNetworking/AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>


@interface JDDDataSource : NSObject

@property (nonatomic, strong) Firebase *firebaseRef;
@property (nonatomic, strong) JDDUser *currentUser;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSMutableArray * currentUserPacts;

+ (instancetype)sharedDataSource;

-(void)setUpFireBaseRef;

-(JDDPact*)createDemoPact;

@end

