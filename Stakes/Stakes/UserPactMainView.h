//
//  UserPactMainView.h
//  Stakes
//
//  Created by Dylan Straughan on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDDPact.h"
#import "JDDUser.h"
#import "JDDCheckIn.h"
#import "JDDDataSource.h"
@import CoreLocation;




@interface UserPactMainView : UIView <CLLocationManagerDelegate>

@property (nonatomic) JDDPact *pact;

-(void)setShitUp;




@end
