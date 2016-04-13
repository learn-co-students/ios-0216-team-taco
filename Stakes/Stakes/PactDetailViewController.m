//
//  PactDetailViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "PactDetailViewController.h"
#import "UserDescriptionView.h"
#import "JDDCheckIn.h"
#import "JDDDataSource.h"
#import "Constants.h"

@interface PactDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pactTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pactDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *stakesLabel;
@property (weak, nonatomic) IBOutlet UILabel *shamingLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UIView *scrollview;
@property (weak, nonatomic) IBOutlet UIStackView *stackview;
@property (strong, nonatomic) JDDDataSource *sharedData;


@end

@implementation PactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (UIView *subview in self.stackview.arrangedSubviews){
        [self.stackview removeArrangedSubview:subview];
    }
    NSLog(@"users to show count, %@", self.pact.usersToShowInApp);
    NSLog(@"users count, %@", self.pact.users);

    // then for each user, createa a UserDescriptionView and add it to the stackview
    for (JDDUser *user in self.pact.usersToShowInApp){
        
        UserDescriptionView *view = [[UserDescriptionView alloc]init];
        
        for (JDDCheckIn *checkin in self.pact.checkIns) {
            
            if ([checkin.userID isEqualToString:user.userID]) {
                
                view.checkinsCount ++;
            }
        }
        
        view.user = user;
        
        // same as [view setUser:user];
        [self.stackview addArrangedSubview:view];
        
        [view.widthAnchor constraintEqualToAnchor:self.scrollview.widthAnchor multiplier:0.5].active = YES;
        [self.stackview layoutSubviews];//give subviews a size
        view.clipsToBounds = YES;
        
    }
    self.pactTitleLabel.text = self.pact.title;
    self.pactDescriptionLabel.text = self.pact.pactDescription;
    self.checkinFrequencyLabel.text = [NSString stringWithFormat:@"%lu", self.pact.checkInsPerTimeInterval];
    self.checkinStringLabel.text = self.pact.timeInterval;
    self.stakesLabel.text = self.pact.stakes;
//    self.shamingLabel.text = self.pact.allowsShaming;
}


- (IBAction)deleteButtonTapped:(id)sender
{
    [self deleteUserPactReferencesWithCompletion:^(BOOL doneWithUsers) {
        if (doneWithUsers) {
            [self deletePactReferenceWithCompletion:^(BOOL doneWithPact) {
                if (doneWithPact) {
                [self dismissViewControllerAnimated:YES completion:^{
                    //
                }];
                }
            }];
        }
    }];
}

-(void)deleteUserPactReferencesWithCompletion:(void(^)(BOOL))completionBlock {
    self.sharedData = [JDDDataSource sharedDataSource];
    
    for (JDDUser *user in self.pact.usersToShowInApp) {
        NSLog(@"ARE WE IN THE LOO{):");
        NSString *userID = user.userID;
        [[[[[self.sharedData.firebaseRef childByAppendingPath:@"users"] childByAppendingPath:userID] childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            completionBlock(YES);
        }];
    }
}
-(void)deletePactReferenceWithCompletion:(void(^)(BOOL))completionBlock {

    [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        
        NSLog(@"in remove value completionblock");
        
        [self establishCurrentUserWithBlock:^(BOOL completion) {
            NSLog(@"establish current user completion block");
            if (completion) {
                
                if (self.sharedData.currentUser.pacts.count == 0) {
                    self.sharedData.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
                    
                    [self.sharedData.currentUser.pactsToShowInApp addObject:[self.sharedData createDemoPact]];
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        //
                    }];
                    
                } else {
                    
                    [self methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completion2) {
                        
                        if (completion2) {
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                
                                [self observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                                    
                                    if (block) {
                                        
                                        completionBlock(YES);
                                    }
                                }];
                                
                            }];
                        }
                    }];
                    
                }
            }
        }];
    }];

}

-(void)establishCurrentUserWithBlock:(void(^)(BOOL))completionBlock {
    NSLog(@"in establish c urrent user method)");
    Firebase *ref = [self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey]]];
    
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        self.sharedData.currentUser = [self.sharedData useSnapShotAndCreateUser:snapshot];
        
        completionBlock(YES);
        
    }];
    
}

-(void)methodToPullDownPactsFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    
    NSLog(@"current%@", self.sharedData.currentUser.pacts);
    
    __block NSUInteger numberOfPactsInDataSource = self.sharedData.currentUser.pacts.count;
    
    self.sharedData.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
    
    for (NSString *pactID in self.sharedData.currentUser.pacts) {
        
        [[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@",pactID]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForPacts) {
            
            JDDPact *currentPact = [self.sharedData useSnapShotAndCreatePact:snapshotForPacts];
            
            NSLog(@"checkinsArray :%@",snapshotForPacts.value[@"checkins"]);
            
            BOOL isUniquePact = YES;
            for (JDDPact *pact in self.sharedData.currentUser.pactsToShowInApp) {
                
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
                [self.sharedData.currentUser.pactsToShowInApp addObject:[self.sharedData useSnapShotAndCreatePact:snapshotForPacts]];
                NSLog(@"self.pacts now holds %ld pacts!", self.sharedData.currentUser.pactsToShowInApp.count);
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
        Firebase *ref = [self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",user]];
        
        [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            JDDUser *person = [self.sharedData useSnapShotAndCreateUser:snapshot];
            
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
    __block NSUInteger remainingPacts = self.sharedData.currentUser.pactsToShowInApp.count;
    
    for (JDDPact *pact in self.sharedData.currentUser.pactsToShowInApp) {
        
        [self getAllUsersInPact:pact completion:^(BOOL success) {
            remainingPacts--;
            
            if(remainingPacts == 0) {
                completionBlock(YES);
            }
        }];
        
    }
    
}



@end
