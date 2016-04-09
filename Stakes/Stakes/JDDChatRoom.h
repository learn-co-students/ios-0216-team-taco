//
//  JDDChatRoom.h
//  Stakes
//
//  Created by Dylan Straughan on 4/7/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDDChatRoom : NSObject

@property  (nonatomic, strong)NSString *chatroomID;
@property  (nonatomic, strong)NSMutableArray *messages;

@end
