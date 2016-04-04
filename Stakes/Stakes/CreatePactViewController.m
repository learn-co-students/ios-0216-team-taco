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




@interface CreatePactViewController () <CNContactPickerDelegate> ;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *pactDescription;
@property (weak, nonatomic) IBOutlet UIPickerView *frequencyPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *timeIntervalPicker;
@property (weak, nonatomic) IBOutlet UITextField *twitterShamePost;
@property (weak, nonatomic) IBOutlet UITextField *pactTitle;
@property (strong, nonatomic)NSArray *FrequencyPickerDataSourceArray;
@property (strong, nonatomic)NSArray *timeIntervalPickerDataSourceArray;
@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shameSwitch;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *stakesTextView;
@property (nonatomic, strong) NSMutableArray *pactParticipants;
@property (nonatomic, assign) NSUInteger pactID;



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


}



    
-(void)styleStakesView
{
    self.stakesTextView.layer.cornerRadius = 5;
    self.stakesTextView.layer.borderWidth = 1.0f;
    self.stakesTextView.layer.borderColor = [UIColor blackColor].CGColor;
}
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [errorAlert show];
//    NSLog(@"Error: %@",error.description);
//}


- (IBAction)createPactTapped:(id)sender {
    
    if ([self isPactReady]) {
        
        
        JDDPact *newPact = [[JDDPact alloc]init];
        newPact.title = self.pactTitle.text;
        newPact.pactDescription = self.pactDescription.text;
        newPact.stakes = self.stakesTextView.text;
        newPact.users = self.pactParticipants;
        newPact.pactID = self.pactID;
        newPact.twitterPost = self.twitterShamePost.text;
        
        [self.dataSource.currentUser.pacts addObject:newPact];
        
    
        NSLog(@"dataStore user is %@",self.dataSource.currentUser.pacts[1]);
        [self dismissViewControllerAnimated:YES completion:nil];

        
    } else {
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
    

    
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"we are here!");
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
    NSMutableArray *frequencyPicker = [NSMutableArray new];
    for (NSUInteger i = 1; i<51; i++) {
        NSString *number = [NSString stringWithFormat:@"%lu",i];
        [frequencyPicker addObject:number];
    }
    self.FrequencyPickerDataSourceArray = frequencyPicker;
    self.timeIntervalPickerDataSourceArray = @[@"Day",@"Week",@"Month",@"Year"];
    self.timeIntervalPicker.delegate =self;
    self.timeIntervalPicker.dataSource = self;
    self.frequencyPicker.delegate = self;
    self.frequencyPicker.dataSource =self;
    
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
        return self.timeIntervalPickerDataSourceArray.count;
    }
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.frequencyPicker) {
        return self.FrequencyPickerDataSourceArray[row];
    } else {
        return self.timeIntervalPickerDataSourceArray[row];
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


- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact*> *)contacts// delgate to pick more than one user
{
    for(CNContact *contact in contacts){
        // create a JDDUser
        JDDUser *newUser = [[JDDUser alloc]init];
        
        newUser.firstName = contact.givenName;
        NSLog(@"given name %@", newUser.firstName);
        
        newUser.lastName = contact.familyName;
        NSLog(@"familyName  %@", newUser.lastName);

        
        NSArray <CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = contact.phoneNumbers;
        CNLabeledValue<CNPhoneNumber *> *firstPhone = [phoneNumbers firstObject];
        CNPhoneNumber *phoneNumber = firstPhone.value;

        newUser.phoneNumber = phoneNumber.stringValue;
        NSLog(@"phone: %@", newUser.phoneNumber);

        
        
        NSInteger randomID =arc4random() % 9000 + 1000;

        newUser.userID = [NSString stringWithFormat:@"%li",randomID];
        NSLog(@"ID: %@", newUser.userID);

        newUser.pacts = nil;
        newUser.checkins = nil;
        self.pactParticipants = [[NSMutableArray alloc]init];
        [self.pactParticipants addObject:newUser];
        [self.dataSource.users addObject:newUser];
        NSLog(@"contacts are: %@", self.dataSource.users);

    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



-(BOOL)isPactReady
{
    if ([self isGroupTitleSet] && [self didInviteFriends] && [self isPactDecribed] && [self isStakeDecided] && [self generatePactID]) {
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
    if (self.pactParticipants.count >0){
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

-(BOOL)generatePactID
{
     self.pactID = arc4random() % 9000 + 1000;
//    if ([idArray containObject:self.pactID]) {
//        [self generatePactID];
//    }
//    
    return YES;
}
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

@end
