//
//  CreatePactViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "CreatePactViewController.h"
#import "JDDDataSource.h"
#import "JDDPact.h"
#import "Constants.h"
#import "UserDescriptionView.h"

@import Contacts;
@import ContactsUI;
@import MessageUI;

@interface CreatePactViewController () <CNContactPickerDelegate, MFMessageComposeViewControllerDelegate> ;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *pactDescription;
@property (weak, nonatomic) IBOutlet UIPickerView *frequencyPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *timeIntervalPicker;
@property (weak, nonatomic) IBOutlet UITextField *twitterShamePost;
@property (weak, nonatomic) IBOutlet UITextField *pactTitle;
@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shameSwitch;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *stakesTextView;
@property (nonatomic, assign) NSString * pactID;
@property (nonatomic,strong) NSMutableArray* FrequencyPickerDataSourceArray;
@property (nonatomic,strong) NSMutableArray* timeInterval;
@property (nonatomic,strong) NSString* timeIntervalString;
@property (nonatomic,strong) NSString* frequencyString;
@property (nonatomic, strong) NSMutableArray* contacts;
@property (nonatomic, strong) Firebase *pactReference;
@property (nonatomic, strong) JDDPact *createdPact;
@property (nonatomic, strong) NSMutableArray *contactsToShow;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIButton *RemoveInvitesButton;
@property (weak, nonatomic) IBOutlet UILabel *inviteFriendsLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addFriendsConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CreatePactViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.RemoveInvitesButton.hidden = YES;
    [self.RemoveInvitesButton setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self initializePickers];
    self.repeatSwitch.on = NO;
    self.shameSwitch.on = NO;
    self.twitterShamePost.hidden = YES;
    [self imageStyle];
    [self styleTopView];
    [self stylePactDescriptionView];
    [self styleTwitterPost];
    [self styleStakesView];
    self.profileImage.hidden = YES;
    self.userNameLabel.hidden = YES;
  
    self.dataSource = [JDDDataSource sharedDataSource];
    
    self.contactsToShow = [[NSMutableArray alloc]init];
    
}


- (IBAction)createPactTapped:(id)sender {
    
    if ([self isPactReady]) {
        
        NSDate *currentDate = [NSDate date];
        
        self.createdPact = [[JDDPact alloc]init];
        self.createdPact.title = self.pactTitle.text;
        self.createdPact.pactDescription = self.pactDescription.text;
        self.createdPact.stakes = self.stakesTextView.text;
        self.createdPact.twitterPost = self.twitterShamePost.text;
        self.createdPact.allowsShaming = self.shameSwitch.on;
        self.createdPact.repeating = self.repeatSwitch.on;
        self.createdPact.timeInterval = self.timeIntervalString;
        self.createdPact.checkInsPerTimeInterval = [self.frequencyString integerValue];
        self.createdPact.dateOfCreation = currentDate;
        self.createdPact.isActive = NO;
        
        
        self.createdPact.users = self.contactsToShow;
        
        
        [self sendPactToFirebase];
        
        [self establishCurrentUserWithBlock:^(BOOL completionBlock) {
            
            if (completionBlock) {
                
                [self methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
                    
                    if (completionBlock) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [self observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                                
                                if (block) {
                                    
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        
//                                        [self dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
                                }
                            }];
                            
                        }];
                    }
                }];
                
                
            }
        }];

        

        [self sendMessageToInvites];

        
    } else {
        
        [self alertPactNotReady];
        
    }
    
}

-(void)sendPactToFirebase{
    
    self.pactReference = [self.dataSource.firebaseRef childByAppendingPath:@"pacts"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    // this dictionary is creating with the users that will be added into the pact when it is created in firebase
        // this data is structured as such @{userID : NSNumber as BOOL whether they have accepted the pact or not}
    
    NSMutableDictionary * usersInPact = [[NSMutableDictionary alloc]initWithDictionary:@{}];
    
    NSLog(@"contacts to show are %@",self.contactsToShow);
    
    for (JDDUser *user in self.contactsToShow) {
        
        NSLog(@"contacts to show are %@",user.userID);
        
        if ([user.userID isEqualToString:self.dataSource.currentUser.userID]) {
            
            NSLog(@"%@ should be equal to %@",self.dataSource.currentUser.userID,user.userID);
            
            [usersInPact setValue:[NSNumber numberWithBool:YES] forKey:user.userID];
            
        } else {
            
            [usersInPact setValue:[NSNumber numberWithBool:NO] forKey:user.userID];
            
        }
    }
    
    NSLog(@"%@",usersInPact);
    
    // creation of the pactID
    Firebase *newPact = [self.pactReference childByAutoId];
    
    // parsing pact url to get pactID
    self.createdPact.pactID = [newPact.description stringByReplacingOccurrencesOfString:@"https://jddstakes.firebaseio.com/pacts/" withString:@""];
    
    NSLog(@"%@", self.createdPact.pactID);
    
    // adding chatroom for pact to JDDStakes
   [[self.dataSource.firebaseRef childByAppendingPath:@"chatrooms"]updateChildValues:@{
                                                                              [NSString stringWithFormat:@"%@",self.createdPact.pactID]:[NSNumber numberWithBool:YES]
                                                                              }];

    // creating the pact to be sent to Firebase using createDict method
    NSDictionary *finalPactDictionary = [self.dataSource createDictionaryToSendToFirebaseWithJDDPact:self.createdPact];
    
    // adding users
    [finalPactDictionary setValue:usersInPact forKey:@"users"];
    
    [newPact setValue:finalPactDictionary];
    
    [self sendPacttoUsers];
    
}

-(void)sendPacttoUsers{
    
    for (JDDUser *user in self.contactsToShow) {
        
        if ([user.userID isEqualToString:self.dataSource.currentUser.userID]) {
            
            Firebase *firebase = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@/pacts",user.userID]];
            
            [firebase updateChildValues:@{self.createdPact.pactID:[NSNumber numberWithBool:YES]}];
            
        } else {
            
            Firebase *firebase = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@/pacts",user.userID]];
            
            [firebase updateChildValues:@{self.createdPact.pactID:[NSNumber numberWithBool:NO]}];
            
        }
    }
    
}

//========================================================================================================================================
// Styling of the pact form
//========================================================================================================================================


-(void)styleStakesView
{
    self.stakesTextView.layer.cornerRadius = 5;
    self.stakesTextView.layer.borderWidth = 1.0f;
    self.stakesTextView.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)styleTwitterPost
{
    self.twitterShamePost.layer.cornerRadius = 5;
    self.twitterShamePost.layer.borderWidth = 1.0f;
    self.twitterShamePost.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)stylePactDescriptionView
{
    self.pactDescription.layer.cornerRadius = 5;
    self.pactDescription.layer.borderWidth = 1.0f;
    self.pactDescription.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)styleTopView
{
    self.topView.layer.cornerRadius = 5;
    self.topView.layer.borderWidth = 1.0f;
    self.topView.layer.borderColor = [UIColor blackColor].CGColor;
}
-(void)imageStyle
{
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = [UIColor blackColor].CGColor;
    
}


-(void)initializePickers {
    self.timeInterval = [NSMutableArray new];
    self.FrequencyPickerDataSourceArray = [NSMutableArray new];
    for (NSUInteger i = 1; i<51; i++) {
        NSString *number = [NSString stringWithFormat:@"%lu",i];
        [self.FrequencyPickerDataSourceArray addObject:number];
    }
    
    self.timeInterval = [@[@"day",@"week",@"month",@"year"] mutableCopy];
    self.timeIntervalPicker.delegate =self;
    self.timeIntervalPicker.dataSource = self;
    self.frequencyPicker.delegate = self;
    self.frequencyPicker.dataSource =self;
    
}

//========================================================================================================================================
//buttons, contacts, and alerts
//========================================================================================================================================

-(void)alertPactNotReady
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Please finish filling your pact" preferredStyle:UIAlertControllerStyleAlert];
    
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

-(void)alertMessagingNotAvailable
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Messaging is not available on this device" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:NO completion:nil];
                             [self dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction: ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.frequencyPicker) {
        return self.FrequencyPickerDataSourceArray.count;
    } else {
        return self.timeInterval.count;
    }
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.frequencyPicker) {
        self.frequencyString = self.FrequencyPickerDataSourceArray[row];
        return self.FrequencyPickerDataSourceArray[row];
    } else {
        self.timeIntervalString = self.timeInterval[row];
        return self.timeInterval[row];
    }

    return nil;
}


- (IBAction)addFriendsButton:(id)sender {
    
    CNContactPickerViewController *contacts = [CNContactPickerViewController new];
    contacts.delegate = self;
    [self presentViewController:contacts animated:YES completion:nil];
    
    
}


- (IBAction)repeateToggleTapped:(id)sender {

}

- (IBAction)shameToggleTapped:(id)sender {
    
    if (self.shameSwitch.on) {
        self.twitterShamePost.hidden = NO;
    } else {
        self.twitterShamePost.hidden = YES;

    }
}


// this is the method that gets fired when user hits done in contact picker.
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    
    if (![self.contactsToShow containsObject:self.dataSource.currentUser]) {
        
        [self.contactsToShow addObject:self.dataSource.currentUser];
        
    }
    
    // OBJECTIVE : for contacts in the CNContact array I want to check firebase to see if they exist. If YES, pull down info & create JDDUser. If no create JDDUser
    
    //may need an if statement to make sure this doesn't fire if contacts.count == 0
    for(CNContact *contact in contacts){
        
        NSString *contactPhone = [[NSString alloc]init];
        
        if ([contact.phoneNumbers firstObject]) {
            CNLabeledValue<CNPhoneNumber*>* oneWeWant = [contact.phoneNumbers firstObject];

             contactPhone = oneWeWant.value.stringValue;
        
       
        
        contactPhone = [[contactPhone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                        componentsJoinedByString:@""]; // clean iPhone number
        self.contacts = [[NSMutableArray alloc]init];
            [self.contacts addObject:contactPhone];}
        // query Firebase to see if the contactIphone exists
        Firebase *usersRef = [self.dataSource.firebaseRef childByAppendingPath:@"users"];
        
        [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            if ([snapshot hasChild:contactPhone]) { // number exists in Firebase
                
                [[usersRef childByAppendingPath:[NSString stringWithFormat:@"%@",contactPhone]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    
                    JDDUser *contactToAdd =[self.dataSource useSnapShotAndCreateUser:snapshot];
                    
                    NSLog(@"user is: %@",contactToAdd.userID);
                    
                    [self.contactsToShow addObject:contactToAdd];
                    
                    NSLog(@"contactToShow: %@",self.contactsToShow);
                    
                    [self addUserToInviteScrollView:contactToAdd];


                }];

            } else {
                
                // need to create JDDUser
                
                JDDUser *newUser = [[JDDUser alloc]init];
                newUser.userID = contactPhone;
                newUser.displayName = contact.givenName;
                newUser.phoneNumber = contactPhone;
                
                NSMutableDictionary * dictionary = [self.dataSource createDictionaryToSendToFirebaseWithJDDUser:newUser];
                
                [[usersRef childByAppendingPath:contactPhone]setValue:dictionary]; //create user in Firebase
                
                [self.contactsToShow addObject: newUser]; // add user to contacts to show
                
                [self addUserToInviteScrollView:newUser];

                
                NSLog(@"contactsToShowNewUser : %lu",self.contactsToShow.count);
                NSLog(@"contactsAddressBookInvites : %lu",(unsigned long)contacts.count);

            }
            
            
            [NSNotification notificationWithName:@"contactsReadyForCreatePactView" object:nil];
            

        }];
        
    }
    
}
- (IBAction)removeContactButton:(id)sender {
    UserDescriptionView *user = [[UserDescriptionView alloc]init];
    user = self.stackView.arrangedSubviews.lastObject;
    [self.stackView removeArrangedSubview:user];
    [self.contactsToShow removeLastObject];
    if (self.contactsToShow.count ==1) {
        self.inviteFriendsLabel.hidden = NO;
        self.addFriendsConstraint.constant = 0;
        self.RemoveInvitesButton.hidden = YES;
    }
}

-(void)addUserToInviteScrollView: (JDDUser*)user {
    UserDescriptionView *view = [[UserDescriptionView alloc]init];
    view.indicatorLabel.hidden = YES;
    view.countOfCheckInsLabel.hidden = YES;
    view.user = user;
    
    if (self.stackView.arrangedSubviews.count == 0) {
        [self.stackView addArrangedSubview:view];
        self.RemoveInvitesButton.hidden = NO;
        self.inviteFriendsLabel.hidden = YES;
        self.addFriendsConstraint.constant = 40;
            [view.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.25].active = YES;
        
    } else  {
        NSMutableArray *userIDsInStackView = [[NSMutableArray alloc]init];
        for (UserDescriptionView *viewToCompare in self.stackView.arrangedSubviews) {
            [userIDsInStackView addObject:viewToCompare.user.userID];
        }

        
            if ([userIDsInStackView containsObject:view.user.userID]) {
                NSLog(@"Already have this user in the scrollView");
                [self alertUserAlreadyAdded:view.user.displayName];
                
            } else {
                [self.stackView addArrangedSubview:view];

            }
        
    }
    
    
}

-(void)alertUserAlreadyAdded:(NSString *)name
{
    NSString *message = [NSString stringWithFormat:@"You already added %@", name];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
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


- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//========================================================================================================================================
// methods to check if all text fields are ready in the pact creation
//========================================================================================================================================

-(BOOL)isPactReady
{
    if ([self isGroupTitleSet] && [self didInviteFriends] && [self isPactDecribed] && [self isStakeDecided]) {
        
          NSLog(@"Pact is ready to go!!!");
        return YES;
    }
    
    return NO;

}

-(BOOL)isGroupTitleSet
{
    if (![self.pactTitle.text isEqualToString:@""] && self.pactTitle.text.length > 0 && self.pactTitle.text != nil) {
        NSLog(@"Group name title is set");
        return YES;
    }
    
    return NO;
}

-(BOOL)didInviteFriends
{
    if (self.contactsToShow.count > 1){
          NSLog(@"friends are invited");
    
        return YES;
    }

return  NO;
}

-(BOOL)isPactDecribed
{
    if (self.pactDescription.text.length > 0 && self.pactDescription.text != nil && ![self.pactDescription.text isEqual:@""]) {
          NSLog(@"pact is described");
        return YES;
        
    }
    
    return NO;
}

-(BOOL)isStakeDecided
{
    if (self.stakesTextView.text.length > 0 && self.stakesTextView.text != nil && ![self.stakesTextView.text isEqual:@""]) {
          NSLog(@"Stakes are decided");
        return YES;
    }
    
    
    return  NO;
}

//========================================================================================================================================
// Dismiss keboards
//========================================================================================================================================

- (IBAction)dismissStakeKeyboard:(id)sender {
    self.stakesTextView = (UITextField*) sender;
    [self.stakesTextView resignFirstResponder];
}

- (IBAction)dismissDiscriptionKeyboard:(id)sender {
    self.pactDescription = (UITextField*) sender;
    [self.pactDescription resignFirstResponder];
}

- (IBAction)dismissTitleKeyboard:(id)sender {
    self.pactTitle = (UITextField*) sender;
    [self.pactTitle resignFirstResponder];
}


- (IBAction)dismissShameKeboard:(id)sender {
    self.twitterShamePost = (UITextField*) sender;
    [self.twitterShamePost resignFirstResponder];
}

//========================================================================================================================================
//Messaging stuff
//========================================================================================================================================

-(void)sendMessageToInvites
{
    if (![MFMessageComposeViewController canSendText]) {
        NSLog(@"Message services are not available.");
        [self alertMessagingNotAvailable];
    } else {
    
    MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
    composeVC.messageComposeDelegate = self;
    
    // Configure the fields of the interface.
    composeVC.recipients = self.contacts;
    composeVC.body = @"Hey Guys I created a pact to hit the gym download the app to keep tracking our progress";

    // Present the view controller modally.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:composeVC animated:YES completion:nil];
    });}
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultSent) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];


    } else {
    
    [self dismissViewControllerAnimated:NO completion:nil];

    }
}


-(void)establishCurrentUserWithBlock:(void(^)(BOOL))completionBlock {
    
    Firebase *ref = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey]]];
    
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        self.dataSource.currentUser = [self.dataSource useSnapShotAndCreateUser:snapshot];
        
        completionBlock(YES);
        
    }];
    
}

-(void)methodToPullDownPactsFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    
    NSLog(@"current%@", self.dataSource.currentUser.pacts);
    
    __block NSUInteger numberOfPactsInDataSource = self.dataSource.currentUser.pacts.count;
    
    self.dataSource.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
    
    for (NSString *pactID in self.dataSource.currentUser.pacts) {
        
        [[self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@",pactID]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForPacts) {
            
            JDDPact *currentPact = [self.dataSource useSnapShotAndCreatePact:snapshotForPacts];
            
            BOOL isUniquePact = YES;
            for (JDDPact *pact in self.dataSource.currentUser.pactsToShowInApp) {
                
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
                [self.dataSource.currentUser.pactsToShowInApp addObject:[self.dataSource useSnapShotAndCreatePact:snapshotForPacts]];
                NSLog(@"self.pacts now holds %ld pacts!", self.dataSource.currentUser.pactsToShowInApp.count);
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
        Firebase *ref = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",user]];
        
        [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            JDDUser *person = [self.dataSource useSnapShotAndCreateUser:snapshot];
            
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
    __block NSUInteger remainingPacts = self.dataSource.currentUser.pactsToShowInApp.count;
    
    for (JDDPact *pact in self.dataSource.currentUser.pactsToShowInApp) {
        
        [self getAllUsersInPact:pact completion:^(BOOL success) {
            remainingPacts--;
            
            if(remainingPacts == 0) {
                completionBlock(YES);
            }
        }];
        
    }
    
}

@end
