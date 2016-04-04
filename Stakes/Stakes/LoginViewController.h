//
//  LoginViewController.h
//  Stakes
//
//  Created by Jeremy Feld on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (nonatomic, strong) NSString *oauthtoken;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end
