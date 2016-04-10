//
//  UserPactsViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//
#import <Accounts/Accounts.h>
#import "UserPactsViewController.h"
#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDPact.h"
#import <FZAccordionTableView/FZAccordionTableView.h>
#import "PactAccordionHeaderView.h"
#import "JDDDataSource.h"
#import "UserPactCellView.h"
#import "PactDetailViewController.h"
#import "LoginViewController.h"
#import "smackTackViewController.h"
#import "Constants.h"

@interface UserPactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) JDDPact * currentOpenPact;
@property (nonatomic, strong) NSMutableArray *pacts;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UITextField *tweetTextField;
@property (nonatomic,strong)NSString *currentUserID;
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) NSMutableArray *allUserPactIDs;

@end

@implementation UserPactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did load in user pacts");
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccount *account =  [self.accountStore accountWithIdentifier:AccountIdentifierKey];
    [self.accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
        NSLog(@"error renewing account credentials: %@", error.localizedDescription);
    }];
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    self.dataSource = [JDDDataSource sharedDataSource];
    self.ref = self.dataSource.firebaseRef;
    self.pacts = [[NSMutableArray alloc]init];
    self.allUserPactIDs = [[NSMutableArray alloc]init];
    self.dataSource.currentUser.userID = [[NSUserDefaults standardUserDefaults] objectForKey: UserIDKey];
    self.currentUserID = self.dataSource.currentUser.userID;
    NSLog(@"currentUserIs %@",self.currentUserID);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowMultipleSectionsOpen = NO;
    self.tableView.keepOneSectionOpen = NO;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), nil];
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserPactCellView" bundle:nil] forCellReuseIdentifier:@"basicCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PactAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:accordionHeaderReuseIdentifier];
    
    [self setupSwipeGestureRecognizer];
    
    [self updateCurrentUserDetailsWithCompletionBlock:^(BOOL completion) {
        if (completion == YES) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.tableView reloadData];
                
                [self observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                    
                    if (completionBlock == YES) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [self.tableView reloadData];
                            
                            JDDPact *thingToShow = self.pacts[2];
                            JDDUser *user = thingToShow.usersToShowInApp[0];
                            NSLog(@"%@",thingToShow.usersToShowInApp);

                        }];
                    }
                }];
                
            }];
        }
    }];
    [self observeEventFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
        
        if (completionBlock == YES) {
            
            
            [self updateAllUsersWithCompletionBlock:^(BOOL completionBlock) {
                if (completionBlock == YES) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        [self.tableView reloadData];
                        
                        // fire off user thing.
                    }];
                }
            }];
            

        }
    }];
    
    
}

#pragma - observe events for user, user pacts, pacts/users

-(void)updateCurrentUserDetailsWithCompletionBlock:(void(^)(BOOL))completionBlock
{
    [[self.dataSource.firebaseRef childByAppendingPath:self.currentUserID] observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"SNAPSHOT FOR THE CURRENT USER: %@", snapshot.value);
        completionBlock(YES);
    }];
}

-(void)updateAllUsersWithCompletionBlock:(void(^)(BOOL))completionBlock
{
    for (NSString *pactID in self.allUserPactIDs) {
        
        
        [[[[self.dataSource.firebaseRef childByAppendingPath:@"pacts"]
           childByAppendingPath:pactID]
          childByAppendingPath:@"users"]
         observeEventType:FEventTypeValue
         withBlock:^(FDataSnapshot *snapshot) {
             //get the users from a snapshot
             //make an observe event for those users
             
             NSLog(@"getting other users: snapshot.value allKeys: %@", [snapshot.value allKeys]);
             
             for (NSString *userToMonitor in [snapshot.value allKeys]) {
                 [[[self.dataSource.firebaseRef childByAppendingPath:@"users"] childByAppendingPath:userToMonitor] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForOtherUsers) {
                     
      //we can monitor any changes to other users here if we pull them from firebase
                     NSLog(@"OTHER USERS snapshot: %@", snapshotForOtherUsers.value);
                     
                     
                     completionBlock(YES);
                     
                     
                 }];
             }
         }];
    }

}

#pragma method that populates the view from Firebase

-(void)observeEventFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    
    // this observe event will give back snapshot value of @{pactID: BOOL-isActive}
    [[self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@/pacts",self.currentUserID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForUser) {
        
        if (snapshotForUser.value != [NSNull null]) {
//            NSLog(@"GETTING USERS PACTS: HERE ARE ALLKEYS FOR SNAPSHOTFORUSER: %@", [snapshotForUser.value allKeys]);
            for (NSString *pactID in [snapshotForUser.value allKeys]) {
                [[self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@",pactID]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForPacts) {
//                    NSLog(@"WE ARE IN 2nd OBSERVE EVENT, HERE IS SNAPSHOT FOR EACH PACT: %@", snapshotForPacts.value);
                    
                    //making array of all pacts to set up observe events for the users in those pacts
                    [self.allUserPactIDs addObject:pactID];
                    NSLog(@"alluserpactids: %@", self.allUserPactIDs);
                    
                    
                    [self.pacts addObject:[self.dataSource useSnapShotAndCreatePact:snapshotForPacts]];
//                    NSLog(@"THIS IS THE LOCAL ARRAY OF PACTS: %@", self.pacts);
                    completionBlock(YES);
                    
                    
                }];
            }
            
            
        }
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"this shit didnt happen: %@", error.description );
    }];
    
//    NSLog(@"self.pacts %@",self.pacts);
    


}

// this method is populating the users in the pact so we can use Twitter info etc. in the UserPactVC. Everything is saved in
-(void)observeEventForUsersFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {

    for (JDDPact *pact in self.pacts) {
        pact.usersToShowInApp = [[NSMutableArray alloc] init];

        // getting the userID information
        for (NSString *user in pact.users) { // Q to ask Teachers = why is this returning a string not a dictionary?? This is weird.
            
            NSLog(@"The pact is %@ and the UserID is %@",pact.title, user);
//            NSArray *things = [user allKeys];
//            NSLog(@"\n\n\n\n\n\n\n%@\n\n\n\n\n\n", things);
//            NSDictionary *stuff = @{ @"hello":@"stuff",
//                                     @"mere":@"cat"};
//            NSArray *stuffArray = [stuff allKeys];
//            NSLog(@"\n\n\n\n\n\n\n%@\n\n\n\n\n\n", stuffArray);

            // querying firebase and creating user
            Firebase *ref = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",user]];
            NSLog(@"%@",ref.description);
            [ref observeEventType:FEventTypeValue  withBlock:^(FDataSnapshot *snapshot) {
                
                // create the user and then add to array that will power the userView
                JDDUser *pactUser = [self.dataSource useSnapShotAndCreateUser:snapshot];
                [pact.usersToShowInApp addObject:pactUser];
                
                NSLog(@"%@",pactUser.displayName);
                
                completionBlock(YES);
            }];
        
        }
        
    }

}


#pragma gestureRecognizers for segues

-(void)setupSwipeGestureRecognizer {
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightGestureHappened:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipe];
}

-(void)swipeRightGestureHappened:(UISwipeGestureRecognizer *)swipeGestureRight{
    
    NSLog(@"Right Gesture Recognizer is happening!");
    
    [self performSegueWithIdentifier:@"segueToSmackTalkVC" sender:self];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < -(self.view.frame.size.height/6)) {
        
        [self performSegueWithIdentifier:@"segueToCreatePact" sender:self];
    }
}

#pragma stuff for tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 550;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserPactCellView * cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.pact = self.pacts[indexPath.section];
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pacts.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PactAccordionHeaderView *viewThing = [tableView dequeueReusableHeaderFooterViewWithIdentifier:accordionHeaderReuseIdentifier];
    
    JDDPact *currentPact = self.pacts[section];
    
    viewThing.pact = currentPact;
    
    return viewThing;
    
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
    self.currentOpenPact = self.pacts[section];
    
    NSLog(@"did open section %@",self.currentOpenPact.title);
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueToSmackTalkVC"]) {
        
        UINavigationController *destinationVC = segue.destinationViewController;
        
        smackTackViewController *thing = destinationVC.viewControllers[0];
        
        thing.currentPact = self.currentOpenPact;
        
    } else if ([segue.identifier isEqualToString:@"segueToCreatePact"]) {
        
        // don't do anything
        
    } else if ([segue.identifier isEqualToString:@"segueToUserDetail"]) {
        
        // don't do anything
    }
}


- (IBAction)loginTapped:(id)sender {
    [self performSegueWithIdentifier:@"login" sender:self];
    
    //this is temporary, will eventually have a different login flow using container view
}

- (IBAction)logoutTapped:(id)sender
{
    
    [self.ref unauth];
    NSLog(@"logged out of Firebase");
    self.dataSource.twitter = nil;
    NSLog(@"logged out of STTwitter");
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogOutNotificationName object:nil];

}

- (IBAction)tweetTapped:(id)sender
{
    
    NSLog(@"trying to send a tweet");
    NSString *tweet = self.tweetTextField.text;
    [self.twitter postStatusUpdate:tweet
                            inReplyToStatusID:nil
                                     latitude:nil
                                    longitude:nil
                                      placeID:nil
                           displayCoordinates:nil
                                     trimUser:nil
                                 successBlock:^(NSDictionary *status) {
                                     NSLog(@"SUCCESSFUL TWEET");
                                 } errorBlock:^(NSError *error) {
                                     NSLog(@"THERE WAS AN ERROR TWEETING");
                                     NSString *message = [NSString stringWithFormat:@"You didn't really want to send that, did you? There was an error sending your Tweet: %@", error.localizedDescription];
                                     NSLog(@"ERROR TWEETING: %@", error.localizedDescription);
                                 }];
}

@end
