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
#import "CreatePactViewController.h"
#import "LoginViewController.h"
#import "smackTackViewController.h"
#import "Constants.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UserDescriptionView.h"

@interface UserPactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) JDDPact * currentOpenPact;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic,strong)NSString *currentUserID;
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation UserPactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did load in user pacts");
    self.dataSource = [JDDDataSource sharedDataSource];
    self.ref = self.dataSource.firebaseRef;

    self.currentOpenPact = self.dataSource.currentUser.pactsToShowInApp[0];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowMultipleSectionsOpen = NO;
    self.tableView.keepOneSectionOpen = YES;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), nil];
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserPactCellView" bundle:nil] forCellReuseIdentifier:@"userPact"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PactAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:accordionHeaderReuseIdentifier];
    
    [self setupSwipeGestureRecognizer];

    self.accountStore = [[ACAccountStore alloc] init];
    NSLog(@"accountstore accounts %@", self.accountStore.accounts);
    NSString *accountKey = [[NSUserDefaults standardUserDefaults] objectForKey:AccountIdentifierKey];
    ACAccount *account =  [self.accountStore accountWithIdentifier:accountKey];
    NSLog(@"account %@", account);
    self.dataSource.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    [self.dataSource.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        NSLog(@"Twitter verified");
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        NSString *message = [NSString stringWithFormat:@"There was an error signing in to Twitter: %@", error.localizedDescription];
//        [self showAlertWithMessage:message];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    
//     self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), nil];
    [self.tableView reloadData];
    
}

#pragma - observe events for user, user pacts, pacts/users

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSLog(@"selectedCell:%ld", indexPath.section);
//    UserPactCellView *thisCell = [self.tableView cellForRowAtIndexPath:indexPath];
//
//}

#pragma method that populates the view from Firebase



#pragma gestureRecognizers for segues

-(void)setupSwipeGestureRecognizer {
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightGestureHappened:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swifeLeftGestureHappened:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [self.view addGestureRecognizer:swipeLeft];
}

-(void)swipeRightGestureHappened:(UISwipeGestureRecognizer *)swipeGestureRight{
    

    NSLog(@"Right Gesture Recognizer is happening!");
    
    [self performSegueWithIdentifier:@"segueToSmackTalkVC" sender:self];

    //if swipe gesture left
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < -(self.view.frame.size.height/6)) {
        
        [self performSegueWithIdentifier:@"segueToCreatePact" sender:self];
        
    }
}
                                                                                                                
-(void)swifeLeftGestureHappened:(UISwipeGestureRecognizer *)swifeGestureLeft
{
    NSLog(@"swiped left");
    
    [self performSegueWithIdentifier:@"segueToPactDetail" sender:self];
    
}
                                                                                                                
#pragma stuff for tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 330;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserPactCellView * cell = [tableView dequeueReusableCellWithIdentifier:@"userPact"forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.pact = self.dataSource.currentUser.pactsToShowInApp[indexPath.section];
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.currentUser.pactsToShowInApp.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    JDDPact *currentPact = self.dataSource.currentUser.pactsToShowInApp[section];

    PactAccordionHeaderView *accordianHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:accordionHeaderReuseIdentifier];
    
    [accordianHeaderView setPact:currentPact];
    
    return accordianHeaderView;
    
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
    
    header.containerView.backgroundColor = [UIColor grayColor];
    
    self.currentOpenPact = self.dataSource.currentUser.pactsToShowInApp[section];
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
    
    header.containerView.backgroundColor = [UIColor blackColor];

}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(PactAccordionHeaderView *)header {
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueToSmackTalkVC"]) {
        
        smackTackViewController *thing = segue.destinationViewController;
        
        thing.currentPact = self.currentOpenPact;
        
    } else if ([segue.identifier isEqualToString:@"segueToCreatePact"]) {
        
        // don't do anything
        
    } else if ([segue.identifier isEqualToString:@"segueToUserDetail"]) {
        
        // don't do anything
    } else if ([segue.identifier isEqualToString:@"segueToPactDetail"]) {
        PactDetailViewController *pactVC = segue.destinationViewController;
        pactVC.pact = self.currentOpenPact;
    }
}

- (IBAction)logoutTapped:(id)sender
{
    
    [self.ref unauth];
    NSLog(@"logged out of Firebase");
    self.dataSource.twitter = nil;
    NSLog(@"logged out of STTwitter");
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogOutNotificationName object:nil];

}

//- (IBAction)tweetTapped:(id)sender
//{
//    
//    NSLog(@"trying to send a tweet");
//    NSString *tweet = self.tweetTextField.text;
//    [self.dataSource.twitter postStatusUpdate:tweet
//                            inReplyToStatusID:nil
//                                     latitude:nil
//                                    longitude:nil
//                                      placeID:nil
//                           displayCoordinates:nil
//                                     trimUser:nil
//                                 successBlock:^(NSDictionary *status) {
//                                     NSLog(@"SUCCESSFUL TWEET");
//                                 } errorBlock:^(NSError *error) {
//                                     NSLog(@"THERE WAS AN ERROR TWEETING");
//                                     NSString *message = [NSString stringWithFormat:@"You didn't really want to send that, did you? There was an error sending your Tweet: %@", error.localizedDescription];
//                                     NSLog(@"ERROR TWEETING: %@", error.localizedDescription);
//                                 }];
//}



@end
