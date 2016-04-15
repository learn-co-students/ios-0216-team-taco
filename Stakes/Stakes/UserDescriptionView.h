//
//  UserDescriptionView.h
//  Stakes
//
//  Created by Dimitry Knyajanski on 4/6/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDDUser.h"

@interface UserDescriptionView : UIView


@property (nonatomic, strong) JDDUser *user;
@property (nonatomic) NSUInteger checkinsCount;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *countOfCheckInsLabel;
@property (weak, nonatomic) IBOutlet UILabel *intialsLabel;
@property (weak, nonatomic) IBOutlet UIView *borderView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
