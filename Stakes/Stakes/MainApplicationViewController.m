//
//  MainApplicationViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 4/6/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "MainApplicationViewController.h"
#import "Constants.h"
#import "LoginViewController.h"
#import "UserPactsViewController.h"

@interface MainApplicationViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation MainApplicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //BOOL userIsRegistered =
     BOOL userIsLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:LoggedInUserDefaultsKey];
    
    if(userIsLoggedIn) {
        [self showUserPactsViewController];
    }
    else {
        [self showLoginViewController];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedInNotification:) name:UserDidLogInNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedOutNotification:) name:UserDidLogOutNotificationName object:nil];
}

- (void)handleUserLoggedInNotification:(NSNotification *)notification
{
    [self showUserPactsViewController];
}

- (void)handleUserLoggedOutNotification:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LoggedInUserDefaultsKey];
    
    [self showLoginViewController];
}

- (void)showLoginViewController
{
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:LoginViewControllerStoryboardID];
    
    [self setEmbeddedViewController:loginVC];
}

- (void)showUserPactsViewController
{
    UserPactsViewController *userPactsVC = [self.storyboard instantiateViewControllerWithIdentifier:UserPactsViewControllerStoryboardID];
    
    [self setEmbeddedViewController:userPactsVC];
}

-(void)setEmbeddedViewController:(UIViewController *)viewController
{
    if([self.childViewControllers containsObject:viewController]) {
        return;
    }
    
    for(UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        
        if(vc.isViewLoaded) {
            [vc.view removeFromSuperview];
        }
        
        [vc removeFromParentViewController];
    }
    
    if(!viewController) {
        return;
    }
    
    [self addChildViewController:viewController];
    [self.containerView addSubview:viewController.view];
    
    [viewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [viewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [viewController.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [viewController.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    [viewController didMoveToParentViewController:self];
}

@end