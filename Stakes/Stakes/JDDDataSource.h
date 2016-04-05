//
//  JDDDataSource.h
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"
#import "JDDUser.h"
#import <STTwitter/STTwitter.h>

@interface JDDDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) Firebase * firebaseRef;
@property (nonatomic, strong) JDDUser * currentUser;
@property (nonatomic, strong) STTwitterAPI *twitter;

+ (instancetype)sharedDataSource;

-(void)generateFakeData;

-(void)setUpFireBaseRef;



@end

