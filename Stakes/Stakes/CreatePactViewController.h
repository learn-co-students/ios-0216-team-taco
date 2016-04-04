//
//  CreatePactViewController.h
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDDUser.h"
#import "JDDDataSource.h"



@interface CreatePactViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate >



@property (nonatomic, strong) JDDUser *user;

@end
