//
//  JDDPact.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "JDDPact.h"

@interface JDDPact ()
@property (nonatomic, strong) Firebase *ref;
@end

@implementation JDDPact

//-(BOOL)isPact:(NSString *)pactID activeForUser:(NSString *)userID usingSnapshot:(FDataSnapshot *)snapshot
//{
//    self.ref = [[Firebase alloc]initWithUrl:@"https://jddstakes.firebaseio.com/"];
//    [[self.ref childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/users", pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        
//        if ([snapshot.value[userID] isEqualToString:@"1"]) {
//            
//            return YES;
//        }
//        else {
//            return NO;
//        }
//    }];
//}

@end
