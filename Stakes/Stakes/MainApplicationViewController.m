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
#import "JDDDataSource.h"
#import "Firebase.h"

@interface MainApplicationViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) JDDDataSource *datasource;

@end

@implementation MainApplicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datasource = [JDDDataSource sharedDataSource];
    
    //BOOL userIsRegistered =
    BOOL userIsLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:LoggedInUserDefaultsKey];
    
    if (userIsLoggedIn) {
        
        [self showUserPactsViewController];
        
    }else {
        
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
    
    [self establishCurrentUserWithBlock:^(BOOL completionBlock) {
        
        if (completionBlock) {
            
            [self methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
                
                if (completionBlock) {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        [self observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                            
                            if (block) {
                                
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                    
                                    [self setEmbeddedViewController:userPactsVC];
                                    
                                }];
                            }
                        }];
                        
                    }];
                }
            }];
            
            
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

-(void)establishCurrentUserWithBlock:(void(^)(BOOL))completionBlock {
    
    Firebase *ref = [self.datasource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey]]];
    
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        self.datasource.currentUser = [self.datasource useSnapShotAndCreateUser:snapshot];
        
        completionBlock(YES);
        
    }];
    
}

-(void)methodToPullDownPactsFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    
    NSLog(@"current%@", self.datasource.currentUser.pacts);
    
    __block NSUInteger numberOfPactsInDataSource = self.datasource.currentUser.pacts.count;
    
    self.datasource.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
    
    for (NSString *pactID in self.datasource.currentUser.pacts) {
        
        [[self.datasource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@",pactID]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForPacts) {
            
            JDDPact *currentPact = [self.datasource useSnapShotAndCreatePact:snapshotForPacts];
            
            NSLog(@"checkinsArray :%@",snapshotForPacts.value[@"checkins"]);
            
            BOOL isUniquePact = YES;
            for (JDDPact *pact in self.datasource.currentUser.pactsToShowInApp) {
                
                NSString *pactID = pact.pactID;
                NSString *currentPactID = currentPact.pactID;
                if (pactID && currentPactID) {
                    if ([pactID isEqualToString:currentPact.pactID]) {
                        isUniquePact = NO;
                    }
                }
                
            }
            
            if (isUniquePact) {
                NSLog(@"is unique Pact: %@", currentPact);
                [self.datasource.currentUser.pactsToShowInApp addObject:[self.datasource useSnapShotAndCreatePact:snapshotForPacts]];
                NSLog(@"self.pacts now holds %ld pacts!", self.datasource.currentUser.pactsToShowInApp.count);
            }
            
            numberOfPactsInDataSource--;
            
            if (numberOfPactsInDataSource == 0) {
            completionBlock(YES);
            }
            
        }];
        
    }
    
}

-(void)getAllUsersInPact:(JDDPact *)pact completion:(void (^)(BOOL success))completionBlock
{
    pact.usersToShowInApp = [[NSMutableArray alloc] init];
    __block NSUInteger remainingUsersToFetch = pact.users.count;
    
    // getting the userID information
    for (NSString *user in pact.users) {
        
        // querying firebase and creating user
        Firebase *ref = [self.datasource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",user]];
        
        [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            JDDUser *person = [self.datasource useSnapShotAndCreateUser:snapshot];
            
            BOOL isUniqueUser = YES;
            
            for (JDDUser * pactUser in pact.usersToShowInApp){
                
                if ([pactUser.userID isEqualToString:person.userID]) {
                    NSLog(@"WE ALREADY HAVE THIS User!!!!!");
                    isUniqueUser = NO;
                }
            }
            
            if (isUniqueUser) {
                NSLog(@"is unique User: %@", person);
                [pact.usersToShowInApp addObject:person];
                NSLog(@"userToShowInAppnow holds %ld pacts!", pact.usersToShowInApp.count);
            }
            
            remainingUsersToFetch--;
            if(remainingUsersToFetch == 0) {
                completionBlock(YES);
            }
        }];
    }
}

// this method is populating the users in the pact so we can use Twitter info etc. in the UserPactVC. Everything is saved in
-(void)observeEventForUsersFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    __block NSUInteger remainingPacts = self.datasource.currentUser.pactsToShowInApp.count;
    
    for (JDDPact *pact in self.datasource.currentUser.pactsToShowInApp) {
        
        [self getAllUsersInPact:pact completion:^(BOOL success) {
            remainingPacts--;
            
            if(remainingPacts == 0) {
                completionBlock(YES);
            }
        }];
        
    }
    
}



@end
