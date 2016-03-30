//
//  JDDDataSource.h
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDDDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *users;

+ (instancetype)sharedDataSource;

-(void)generateFakeData;


@end
