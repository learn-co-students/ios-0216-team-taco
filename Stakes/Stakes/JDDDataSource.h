//
//  JDDDataSource.h
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDDDataSource : NSObject

@property NSMutableArray *users;

+ (instancetype)sharedDataSource;

@end
