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
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UserDescriptionView.h"

@interface UserPactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) JDDPact * currentOpenPact;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UITextField *tweetTextField;
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

//    NSLog(@"%@",self.dataSource.currentUser.displayName);
//    NSLog(@"%@",self.dataSource.currentUser.twitterHandle);
//
//    NSLog(@"%lu",self.dataSource.currentUser.pacts.count);
//    
//    NSLog(@"currentUserIs %@",self.dataSource.currentUser.userID);
    self.currentOpenPact = self.dataSource.currentUser.pactsToShowInApp[0];


    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowMultipleSectionsOpen = NO;
    self.tableView.keepOneSectionOpen = NO;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), nil];
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserPactCellView" bundle:nil] forCellReuseIdentifier:@"userPact"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PactAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:accordionHeaderReuseIdentifier];
    
    [self setupSwipeGestureRecognizer];

    self.accountStore = [[ACAccountStore alloc] init];
    NSLog(@"accountstore accounts %@", self.accountStore.accounts);
    NSString *accountKey = [[NSUserDefaults standardUserDefaults] objectForKey:AccountIdentifierKey];
    ACAccount *account =  [self.accountStore accountWithIdentifier:accountKey];
    NSLog(@"account %@", account);
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
}

#pragma - observe events for user, user pacts, pacts/users

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"selectedCell:%ld", indexPath.section);
    UserPactCellView *thisCell = [self.tableView cellForRowAtIndexPath:indexPath];

}

#pragma method that populates the view from Firebase



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
    return 400;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
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

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
    self.currentOpenPact = self.dataSource.currentUser.pactsToShowInApp[section];
//    
//
//    header.textLabel.text = self.currentOpenPact.title;
    
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
    [self.dataSource.twitter postStatusUpdate:tweet
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
