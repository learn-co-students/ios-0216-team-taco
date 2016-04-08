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
@property (nonatomic,strong) NSString* frequanctString;
@property (nonatomic, strong) NSMutableArray* contacts;
@property (nonatomic, strong) Firebase *pactReference;
@property (nonatomic, strong) JDDPact *createdPact;
@property (nonatomic, strong) NSMutableArray *contactsToShow;

@end

@implementation CreatePactViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
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
    
    NSLog( @" current user is %@",self.dataSource.currentUser);
    
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
        self.createdPact.checkInsPerTimeInterval = [self.frequanctString integerValue];
        self.createdPact.dateOfCreation = currentDate;
        self.createdPact.users = self.contactsToShow;
        
        [self sendMessageToInvites];
        
        [self sendPactToFirebase];
        
        [self dismissViewControllerAnimated:YES completion:nil];
                
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
    [[self.dataSource.firebaseRef childByAppendingPath:@"chatrooms"]setValue:self.createdPact.pactID];
    
    // creating the pact to be sent to Firebase using createDict method
    NSDictionary *finalPactDictionary = [self.dataSource createDictionaryToSendToFirebaseWithJDDPact:self.createdPact];
    
    // adding users
    [finalPactDictionary setValue:usersInPact forKey:@"users"];
    
    [newPact setValue:finalPactDictionary];
    
    [self sendPacttoUsers];
    
}

-(void)sendPacttoUsers{
    
    for (JDDUser *user in self.contactsToShow) {
        
        if (user.userID == self.dataSource.currentUser.userID) {
            
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
    
    self.timeInterval = [@[@"Day",@"Week",@"Month",@"Year"] mutableCopy];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        self.frequanctString = self.FrequencyPickerDataSourceArray[row];
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
        
        CNLabeledValue<CNPhoneNumber*>* oneWeWant = [contact.phoneNumbers firstObject];
        
        contactPhone = oneWeWant.value.stringValue;
        
        contactPhone = [[contactPhone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                        componentsJoinedByString:@""]; // clean iPhone number
        
        
        // query Firebase to see if the contactIphone exists
        Firebase *userRef = [self.dataSource.firebaseRef childByAppendingPath:@"users"];
        
        [userRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            if ([snapshot hasChild:contactPhone]) { // number exists in Firebase
                
                NSLog(@"user is : %@",snapshot.value);
                
                JDDUser *contactToAdd =[self.dataSource useSnapShotAndCreateUser:snapshot];
                
                NSLog(@"user is : %@",contactToAdd.userID);

                [self.contactsToShow addObject:contactToAdd];
                
                JDDUser *contact =[self.contactsToShow lastObject];
                NSLog(@"contactsToShow : %@",contact.phoneNumber);

            } else {
                
                // need to create JDDUser
                
                JDDUser *newUser = [[JDDUser alloc]init];
                newUser.userID = contactPhone;
                newUser.displayName = contact.givenName;
                newUser.phoneNumber = contactPhone;
                
                NSMutableDictionary * dictionary = [self.dataSource createDictionaryToSendToFirebaseWithJDDUser:newUser];
                
                [[userRef childByAppendingPath:contactPhone]setValue:dictionary]; //create user in Firebase
                
                [self.contactsToShow addObject: newUser]; // add user to contacts to show
                
                NSLog(@"contactsToShowNewUser : %@",self.contactsToShow);

            }
            
            [NSNotification notificationWithName:@"contactsReadyForCreatePactView" object:nil];
            
        }];
        
    }
    
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
    if (self.contactsToShow.count > 0){
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

-(void)sendMessageToInvites{
    if (![MFMessageComposeViewController canSendText]) {
        NSLog(@"Message services are not available.");
    }
    
    MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
    composeVC.messageComposeDelegate = self;
    
    // Configure the fields of the interface.
    composeVC.recipients = self.contacts;
    composeVC.body = @"Hey Guys I created a pact to hit the gym download the app to keep tracking our progress";
    
    // Present the view controller modally.
//    [self presentViewController:composeVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:composeVC animated:YES completion:nil];
    });
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultSent) {
        // ...
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
