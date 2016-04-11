//
//  UserPactCellView.h
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




@interface UserPactCellView : UITableViewCell <CLLocationManagerDelegate>
@property (nonatomic) JDDPact *pact;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) JDDDataSource *sharedData;
@property (nonatomic, strong) JDDCheckIn *CheckIn;


-(void)setShitUp;

@property (weak, nonatomic) IBOutlet UIButton *pendingButton;
@property (strong, nonatomic) IBOutlet UILabel *name1;
@property (strong, nonatomic) IBOutlet UILabel *name2;
@property (strong, nonatomic) IBOutlet UILabel *name3;
@property (strong, nonatomic) IBOutlet UILabel *pactTitle;
@property (strong, nonatomic) IBOutlet UILabel *pactDetail;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesDetail;
@property (strong, nonatomic) IBOutlet UIImageView *name1Image;
@property (strong, nonatomic) IBOutlet UIImageView *name2Image;
@property (strong, nonatomic) IBOutlet UIImageView *name3Image;
@property (strong, nonatomic) IBOutlet UILabel *name1checkIns;
@property (strong, nonatomic) IBOutlet UILabel *name2checkIns;
@property (strong, nonatomic) IBOutlet UILabel *name3checkIns;
@property (strong, nonatomic) IBOutlet UIButton *checkInButton;

@end
