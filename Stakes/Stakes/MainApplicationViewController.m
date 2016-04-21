//
//  MainApplicationViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 4/6/16.
//  Copyright © 2016 JDD. All rights reserved.
//
#import <BALoadingView/BALoadingView.h>

#import "Constants.h"
#import "Firebase.h"
#import "JDDDataSource.h"
#import "LoginViewController.h"
#import "MainApplicationViewController.h"
#import "UserPactMainView.h"
#import "UserPactsViewController.h"

@interface MainApplicationViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) JDDDataSource *datasource;
@property (nonatomic, weak) IBOutlet BALoadingView *loadingView;
@property(nonatomic, assign) BACircleAnimation animationType;
@property(nonatomic, assign) bool firstLoad;

@end

@implementation MainApplicationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.datasource = [JDDDataSource sharedDataSource];
    self.firstLoad = YES;
    
    BOOL userIsLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:LoggedInUserDefaultsKey];
    
    if (userIsLoggedIn) {
        
        [self showUserPactsViewController];
        
    } else {
        
        [self showLoginViewController];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedInNotification:) name:UserDidLogInNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedOutNotification:) name:UserDidLogOutNotificationName object:nil];
    
}

-(void)viewDidLayoutSubviews
{
    if (self.firstLoad) {
        
        [self.loadingView initialize];
        self.loadingView.lineCap = kCALineCapRound;
        self.loadingView.clockwise = true;
        self.loadingView.segmentColor = [UIColor whiteColor];
        self.firstLoad = NO;
        
    }
    
    [self.loadingView startAnimation:BACircleAnimationFullCircle];
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
    [self.loadingView stopAnimation];
    [self setEmbeddedViewController:loginVC];
}

- (void)showUserPactsViewController
{
    
    UINavigationController *navBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"navBarVC"];
    
    [self.datasource establishCurrentUserWithBlock:^(BOOL completionBlock) {
        
        if (completionBlock) {
            
            if (self.datasource.currentUser.pacts.count == 0) {
                self.datasource.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
                
                [self.datasource.currentUser.pactsToShowInApp addObject:[self.datasource createDemoPact]];
                
                [self.loadingView stopAnimation];
                [self setEmbeddedViewController:navBarController];
                
            } else {
                
                [self.datasource methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
                    
                    if (completionBlock) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [self.datasource observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                                
                                if (block) {
                                    
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        
                                        [self.loadingView stopAnimation];
                                        [self setEmbeddedViewController:navBarController];
                                        
                                    }];
                                }
                            }];
                            
                        }];
                    }
                }];
                
            }
        }
    }];
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
