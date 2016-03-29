//
//  JDDPact.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "JDDPact.h"
#import "JDDCheckIn.h"

@interface JDDPact ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *stakes;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic) NSUInteger stakesCount;
@property (nonatomic, strong) NSString *twitterPost;
@property (nonatomic) NSUInteger frequency;
@property (nonatomic, strong) NSString *frequencyString;
@property (nonatomic) NSTimeInterval *lengthOfPact;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic) BOOL stakesArePerCheckIn;
@property (nonatomic) BOOL allowsShaming;
@property (nonatomic, strong) JDDCheckIn *checkins;

@end

@implementation JDDPact

@end
