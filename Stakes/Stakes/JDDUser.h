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
@property (nonatomic, strong) NSString *displayName;

//Contact Info
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *twitterHandle;
@property (nonatomic, strong) UIImage *userImage;
@property (nonatomic, strong) NSString *userImageURL;


//App Info
@property (nonatomic, strong) NSString *userID;

//Pacts
@property (nonatomic, strong) NSMutableArray *pacts;
@property (nonatomic, strong) NSMutableArray *pactsToShowInApp;
@property (nonatomic, strong) NSMutableArray *checkIns;

#pragma methods


@end
