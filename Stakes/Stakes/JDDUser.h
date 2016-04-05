//
//  JDDUser.h
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface JDDUser : NSObject

//Name
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

//Contact Info
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *twitterHandle;
@property (nonatomic, strong) UIImage * userImage;

//App Info
@property (nonatomic, strong) NSString *userID;

//Pacts
@property (nonatomic, strong) NSMutableArray *pacts;
@property (nonatomic, strong) NSMutableArray *pendingPacts;
@property (nonatomic, strong) NSMutableArray *checkins;

#pragma methods

//-(void)createNewPact;
//-(void)checkInToPact:(JDDPact*)pact;
//-(void)deletePact;
//-(void)acceptPact;

@end
