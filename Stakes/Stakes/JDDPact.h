//
//  JDDPact.h
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDDPact : NSObject

//Pact Information
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString * pactDescription;
@property (nonatomic, strong) NSString *stakes;
@property (nonatomic, strong) NSArray *users;

//CheckIn Information
@property (nonatomic) NSUInteger checkInsPerTimeInterval;
@property (nonatomic, strong) NSString *timeInterval;
@property (nonatomic) BOOL repeating;

//Twitter Stuff
@property (nonatomic) BOOL allowsShaming;
@property (nonatomic, strong) NSString *twitterPost;

//Message Stuff
@property (nonatomic, strong) NSArray *messages;

#pragma methods



@end

