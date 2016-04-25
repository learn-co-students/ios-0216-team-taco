//
//  UserPactsViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//
#import <Accounts/Accounts.h>
#import <BALoadingView/BALoadingView.h>
#import "UserPactsViewController.h"
#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDPact.h"
#import <FZAccordionTableView/FZAccordionTableView.h>
#import "PactAccordionHeaderView.h"
#import "JDDDataSource.h"
#import "PactTableViewCell.h"
#import "PactDetailViewController.h"
#import "CreatePactViewController.h"
#import "LoginViewController.h"
#import "smackTackViewController.h"
#import "Constants.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UserDescriptionView.h"

@interface UserPactsViewController () <UITableViewDataSource, UITableViewDelegate,PactTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) JDDDataSource *sharedData;
@property (nonatomic, strong) JDDPact * currentOpenPact;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic,strong)NSString *currentUserID;
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, ) NSInteger openSection;
@property (nonatomic, strong) NSLayoutConstraint *createPactLabelAnchor;
@property (nonatomic, strong) UILabel *createPactLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

@end

@implementation UserPactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.blurView.hidden = YES;
    
    self.sharedData = [JDDDataSource sharedDataSource];
    
    self.sharedData.isSectionOpen = NO; //set to no to make sure app will show the right pactTitle for first time user
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserCheckedIn:) name:UserCheckedInNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserAccepted:) name:UserAcceptedPactNotificationName object:nil];

        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserWantsToDelete:) name:UserWantsToDeletePactNotificationName object:nil];
    
    
    [self.logoutButton setTintColor:[UIColor blackColor]];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInactivePactCheckInNotification:) name:InactivePactCheckinNotificationName object:nil];


    
    self.navigationController.hidesBarsOnSwipe = YES;
    
    self.ref = self.sharedData.firebaseRef;
    
    [self createPactLabelView]; //The label that appears when you pull down
    
    [self initializeAccordionView];
    
    [self initializeAccountStore];
    
    
}


-(void)initializeAccountStore
{
    
    self.accountStore = [[ACAccountStore alloc] init];
    
    
    NSString *accountKey = [[NSUserDefaults standardUserDefaults] objectForKey:AccountIdentifierKey];
    
    ACAccount *account =  [self.accountStore accountWithIdentifier:accountKey];
    
    self.sharedData.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [self.sharedData.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        NSLog(@"Twitter verified");
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"%@", error.localizedDescription);
        
        UIAlertController *inactiveAlert = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"There was an error signing in to Twitter: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //
        }];
        [inactiveAlert addAction:okAction];
        [self presentViewController:inactiveAlert animated:YES completion:nil];
    }];
    
}

-(void)initializeAccordionView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowMultipleSectionsOpen = NO;
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.initialOpenSections = nil;
    self.tableView.keepOneSectionOpen = NO;
    
    UINib *cellNib = [UINib nibWithNibName:@"PactTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"userPact"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PactAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:accordionHeaderReuseIdentifier];
    
    
   //=======================BackgroundImage for the tableView
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey-background-for-site1.jpg"]];
//
//    self.tableView.backgroundView = tempImageView;

}


-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    

        [self.tableView reloadData];
    
}


-(void)createPactLabelView{
    
    self.createPactLabel = [[UILabel alloc]init];
    [self.view addSubview:self.createPactLabel];
    self.createPactLabel.textColor = [UIColor grayColor];
    self.createPactLabel.text = @"pull to create pact";
    [self.createPactLabel setFont:[UIFont fontWithName:@"futura" size:17]];
    self.createPactLabel.alpha =0.0001;
    self.createPactLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.createPactLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    self.createPactLabelAnchor  = [self.createPactLabel.bottomAnchor constraintEqualToAnchor:self.view.topAnchor];
    self.createPactLabelAnchor.active = YES;
    
}


#pragma - observe events for user, user pacts, pacts/users


#pragma method that populates the view from Firebase



#pragma gestureRecognizers for segues


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.createPactLabelAnchor.constant = -(scrollView.contentOffset.y*2) -(self.view.frame.size.height/4);
    
    self.createPactLabel.alpha = -(scrollView.contentOffset.y)/(self.view.frame.size.height/4);
    
    if (scrollView.contentOffset.y < -(self.view.frame.size.height/4)) {
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.75;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        [self.view.window.layer addAnimation:transition forKey:nil];
        
        [self performSegueWithIdentifier:@"segueToCreatePact" sender:self];
        
    }
}

#pragma stuff for tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (self.view.frame.size.height - 140);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 70;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sharedData.currentUser.pactsToShowInApp.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PactTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"userPact"forIndexPath:indexPath];
    
    JDDPact *currentPact = self.sharedData.currentUser.pactsToShowInApp[indexPath.section];
    NSLog (@"current pact checkins is %ld", currentPact.checkIns.count);
    cell.pact = currentPact;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

-(void)pactTableViewCell:(PactTableViewCell *)pactTableViewCell shouldSegueToSmackTalkVC:(BOOL)shouldSegueToSmacktalkVC {
    
    if(shouldSegueToSmacktalkVC) {
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.75;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [self.view.window.layer addAnimation:transition forKey:nil];
        
        [self performSegueWithIdentifier:@"segueToSmackTalkVC" sender:self];
    }
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   
    [self sortPactsArray:self.sharedData.currentUser.pactsToShowInApp]; // method will sorts pacts and will show the most recent one on top of the tableView
   
    JDDPact *currentPact = self.sharedData.currentUser.pactsToShowInApp[section];
    
    PactAccordionHeaderView *accordianHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:accordionHeaderReuseIdentifier];
    
    [accordianHeaderView setPact:currentPact];
    
    return accordianHeaderView;
    
}

-(void)sortPactsArray:(NSMutableArray *)unsortedPacts {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateOfCreation" ascending:false];
    
    [self.sharedData.currentUser.pactsToShowInApp sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
    
    self.sharedData.isSectionOpen = YES;
    self.view.userInteractionEnabled = NO;

    self.sharedData.currentPact = self.sharedData.currentUser.pactsToShowInApp[section];
    
    NSLog(@"willOpenPactGetsCalled with pact %@",self.sharedData.currentPact.title);
    NSLog(@"willOpenPactGetsCalled with pact %@",self.sharedData.currentPact);
    NSLog(@"willOpenPactGetsCalled with pact %@",self.sharedData.currentPact.stakes);
    
    if ([self.sharedData.currentUser.pacts isEqual:nil] || self.sharedData.currentUser.pacts.count == 0) {
        
        [header setPact:self.sharedData.currentPact];
    }
    
    
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
    
    self.openSection = section;
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    self.view.userInteractionEnabled =YES;
    
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueToSmackTalkVC"]) {
        
        
        UINavigationController *navController =segue.destinationViewController;
        
        smackTackViewController *thing = (smackTackViewController *) navController.topViewController;
        
        thing.currentPact = self.sharedData.currentPact;
        
    } else if ([segue.identifier isEqualToString:@"segueToCreatePact"]) {
        
        // don't do anything
        
    } else if ([segue.identifier isEqualToString:@"segueToPactDetail"]) {
        PactDetailViewController *pactVC = segue.destinationViewController;
        pactVC.pact = self.currentOpenPact;
    }
}

- (IBAction)logoutTapped:(id)sender
{
    
    self.blurView.hidden = NO;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure you want to logout?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesLogMeOut = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.ref unauth];
        NSLog(@"logged out of Firebase");
        self.sharedData.twitter = nil;
        NSLog(@"logged out of STTwitter");
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogOutNotificationName object:nil];
        
    }];
    
    UIAlertAction *noDontLogMeOut = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.blurView.hidden = YES;
        
    }];
    
    [alertController addAction:yesLogMeOut];
    [alertController addAction:noDontLogMeOut];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)handleUserCheckedIn:(NSNotification *)notification
{
    
    JDDPact *pact = (JDDPact *)notification.object;

    
    [self updateCheckInsForPact:pact withCompletion:^(BOOL success) {
        
        NSLog(@"Back in block.")    ;
        if (success) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSLog(@"RELOADING DATA:");
                [self.tableView reloadData];

            }];
        }
    }];
    
}


-(void)updateCheckInsForPact:(JDDPact *)updatedPact withCompletion:(void (^)(BOOL success))completionBlock
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    for (NSString *pactID in self.sharedData.currentUser.pacts) {
        if ([pactID isEqualToString:updatedPact.pactID]) {
            [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:pactID]  observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                
                [updatedPact.checkIns removeAllObjects];
                updatedPact.checkIns = [[NSMutableArray alloc]init];
                
                for (NSString *checkin in snapshot.value[@"checkins"]) {
                    
                    JDDCheckIn *check = [[JDDCheckIn alloc]init];
                    
                    check.userID = snapshot.value[@"checkins"][checkin][@"userID"];
                    check.checkInDate = [dateFormatter dateFromString:snapshot.value[@"checkins"][checkin][@"checkInDate"]];
                    check.checkInID = snapshot.value[@"checkins"][checkin][@"checkInID"];
                    
                    if ([check.checkInDate compare:updatedPact.dateOfCreation] == NSOrderedDescending){
                        
                        [updatedPact.checkIns addObject:check];
                    }
                }
                
                NSLog(@"COMPLETION BLOCK");
                completionBlock(YES);
                
                
            }];
        }

    }
}

-(void)handleUserAccepted:(NSNotification *)notification
{
    
    [self updateAcceptedInvitationsForPact:notification.object withCompletion:^(BOOL success) {
        if (success) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.tableView reloadData];
                
            }];
        }
    }];
    
}

-(void)updateAcceptedInvitationsForPact:(JDDPact *)updatedPact withCompletion:(void (^)(BOOL success))completionBlock
{
    
    for (NSString *pactID in self.sharedData.currentUser.pacts) {
        if ([pactID isEqualToString:updatedPact.pactID]) {
            
            [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:updatedPact.pactID]  observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                
                [updatedPact.users removeAllObjects];
                updatedPact.users = snapshot.value[@"users"];
                
                NSArray *allUserValues = [snapshot.value[@"users"] allValues];
                NSLog(@"ALL USER VALUES ARRAY %@", allUserValues);
                BOOL isActive = YES;
                
                for (NSNumber *num in allUserValues) {
                    if ([num isEqualToNumber:@0]) {
                        isActive = NO;
                    }
                }
                
                updatedPact.isActive = isActive;
                
                completionBlock(YES);
                
            }];
        }
    }
}

-(void)updatePactData:(NSNotification *)notification
{
    
    [self.sharedData methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
        
        if (completionBlock) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.sharedData observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                    
                    if (block) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [self.tableView reloadData];
                            
                            //                                    [self]
                            
                        }];
                    }
                }];
                
            }];
        }
    }];
    
}

-(void)updateAfterPactDeleted
{
    [self.sharedData establishCurrentUserWithBlock:^(BOOL completionBlock) {
        
        if (completionBlock) {
            
            if (self.sharedData.currentUser.pacts.count == 0 || self.sharedData.currentUser.pacts == nil) {
                self.sharedData.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
                
                [self.sharedData.currentUser.pactsToShowInApp addObject:[self.sharedData createDemoPact]];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.tableView reloadData];
                }];
                
                
            } else {
                
                [self.sharedData methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
                    
                    if (completionBlock) {
                        
                        
                        [self.sharedData observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                            
                            if (block) {
                                
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                    
                                    [self.tableView reloadData];
                                    //                                        [self.tableView toggleSection:self.openSection];
                                    //                                        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
                                    //                                            //
                                    //                                        } completion:^(BOOL finished) {
                                    //                                            //
                                    //
                                    //                                        }];
                                    self.sharedData.currentPact = nil;
                                    [self.tableView reloadData];
                                    //                                        [[NSNotificationCenter defaultCenter] postNotificationName:PactDeletedNotificationName object:nil];
                                    
                                    //
                                    
                                    
                                }];
                            }
                        }];
                        
                        
                    }
                }];
                
            }
        }
    }];
    
}

-(void)handleUserWantsToDelete:(NSNotification *)notification
{
    [self.tableView toggleSection:self.openSection];
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete this pact?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //        [self.loadingView startAnimation:BACircleAnimationFullCircle];
        
        [self deletePact:notification.object];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [deleteAlert addAction:delete];
    [deleteAlert addAction:cancel];
    
    
    [self presentViewController:deleteAlert animated:YES completion:nil];
}

-(void)deletePact:(JDDPact *)pactToDelete
{
    //    [self performSegueWithIdentifier:@"deleteModal" sender:self];
    [self deleteCurrentUserPact:pactToDelete withCompletion:^(BOOL done) {
        if (done) {
            [self deleteAllUserPactReferences:pactToDelete];
            [self deletePactReference:pactToDelete WithCompletion:^(BOOL doneWithPact) {
                if (doneWithPact) {
                    
                    [self updateAfterPactDeleted];
                    
                }
            }];
        }
        
    }];
}

-(void)deleteCurrentUserPact:(JDDPact *)pactToDelete withCompletion:(void(^)(BOOL))completed {
    
    [[[[[self.sharedData.firebaseRef childByAppendingPath:@"users"] childByAppendingPath:self.sharedData.currentUser.userID] childByAppendingPath:@"pacts"] childByAppendingPath:pactToDelete.pactID]removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        completed(YES);
    }];
}

-(void)deleteAllUserPactReferences:(JDDPact *)pactToDelete
{
    for (NSString *pactID in self.sharedData.currentUser.pacts) {
        if ([pactID isEqualToString:pactToDelete.pactID]) {
            for (NSString *user in pactToDelete.users) {
                NSLog(@"ARE WE IN THE LOO{):");
                [[[[[self.sharedData.firebaseRef childByAppendingPath:@"users"] childByAppendingPath:user] childByAppendingPath:@"pacts"] childByAppendingPath:pactToDelete.pactID] removeValue];
            }
            
            
        }
        
        
    }
    
    
}
-(void)deletePactReference:(JDDPact *)pactToDelete WithCompletion:(void(^)(BOOL))referenceDeleted {
    
    [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:pactToDelete.pactID] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        
        NSLog(@"in remove value completionblock");
        referenceDeleted(YES);
    }];
    
}
-(void)AlertOnboarding: (NSString *)message
{
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Welcome!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction: ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)handleInactivePactCheckInNotification:(NSNotification *)notification
{
    UIAlertController *inactiveAlert = [UIAlertController alertControllerWithTitle:@"C'mon now!" message:@"No head starts. Your friends need to join the pact first." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    [inactiveAlert addAction:okAction];
 
    [self presentViewController:inactiveAlert animated:YES completion:nil];
}

@end
