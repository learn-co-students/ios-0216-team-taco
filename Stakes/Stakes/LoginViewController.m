//
//  LoginViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//
#import <Foundation/Foundation.h>

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <STTwitter/STTwitter.h>

#import "Constants.h"
#import "JDDDataSource.h"
#import "LoginViewController.h"
#import "Secrets.h"
#import "TwitterAuthHelper.h"

@interface LoginViewController ()

@property (nonatomic, strong) STTwitterAPI *twitterClient;
@property (nonatomic, strong) JDDDataSource *sharedData;
@property (nonatomic, strong) Firebase *firebaseReference;
@property (nonatomic, strong) TwitterAuthHelper *twitterAuthHelper;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSString *userQuery;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *loginContainer;
@property (nonatomic, strong) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNumberTextFieldWidth;
@property (nonatomic) BOOL userDidRegister;
@property (nonatomic) BOOL userFoundInFirebase;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sharedData = [JDDDataSource sharedDataSource];
    self.accountStore = [[ACAccountStore alloc] init];
    self.firebaseReference = self.sharedData.firebaseRef;
    self.userDidRegister = [[NSUserDefaults standardUserDefaults] boolForKey:UserDidRegisterKey];
    
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.loginButton.enabled = NO;
    self.userFoundInFirebase = NO;
    self.loginButton.alpha = 0.5;
    self.loginContainer.alpha = 0.1;
    
    if (self.userDidRegister) {
        self.phoneNumberTextField.hidden = YES;
        self.phoneNumberLabel.hidden = YES;
        [self enableLoginButton];
    }
}

#pragma mark - Login and Authentication

- (IBAction)loginTapped:(id)sender
{
    if (self.userDidRegister) {
        self.userQuery = [[NSUserDefaults standardUserDefaults] objectForKey:UserIDKey];
        [self startAuthProcess];
    } else {
        self.userQuery = self.phoneNumberTextField.text;
        [self checkForUserInFirebase];
    }
}

-(void)startAuthProcess
{
    self.twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.firebaseReference apiKey:TWITTER_KEY];
    
    [self.twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        NSString *message;
        
        if (error) {
            message = [NSString stringWithFormat:@"There was an error logging into Twitter: %@", error.localizedDescription]; // That's cute
            [self showAlertWithMessage:message];
            
        } else if (accounts.count == 0) {
            message = @"No Twitter accounts found. Please add an account in your phone's settings.";
            [self showAlertWithMessage:message];
            
        } else {
            [self selectTwitterAccount:accounts];
        }
    }];
}

- (void)selectTwitterAccount:(NSArray *)accounts
{
    UIAlertController *selectAccount = [UIAlertController alertControllerWithTitle:@"Please sign-in with a Twitter account:"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    for (ACAccount *account in accounts) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"@%@", account.username]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self authenticateInFirebaseWithTwitterAccount:account];
                                                       }];
        [selectAccount addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [selectAccount addAction:cancel];
    
    [self presentViewController:selectAccount animated:YES completion:nil];
}

- (void)authenticateInFirebaseWithTwitterAccount:(ACAccount *)account
{
    [self.twitterAuthHelper authenticateAccount:account withCallback:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"There was an error authenticating your account: %@", error.localizedDescription];
            [self showAlertWithMessage:message];
        } else {
            if (self.userDidRegister) { // this person has registered the app at some point in time
                
                [self loginWithiOSAccount:account];
                
                self.sharedData.currentUser = [self createUserFromData:authData];
                
            } else if (self.userFoundInFirebase){ // this person exists in firebase
                
                NSDictionary *userDictionary = [self createUserDictionary:authData];
                JDDUser *user = [self createUserFromData:authData];
                
                self.sharedData.currentUser = user; // this is setting the current user
                
                [[NSUserDefaults standardUserDefaults] setObject:user.userID forKey:UserIDKey];
                NSLog(@"user exists...setting user default key for user ID: %@", user.userID);
                
                [[[self.firebaseReference childByAppendingPath:@"users"] childByAppendingPath:user.userID] updateChildValues:userDictionary];
                
                [self loginWithiOSAccount:account];
                
            } else { // this is a totally new user
                
                NSDictionary *userDictionary = [self createUserDictionary:authData];
                JDDUser *user = [self createUserFromData:authData];
                
                self.sharedData.currentUser = user; // this is setting the current user
                
                [[NSUserDefaults standardUserDefaults] setObject:user.userID forKey:UserIDKey];
                NSLog(@"non-existent user... setting user default key for user ID: %@", user.userID);
                
                [[[self.firebaseReference childByAppendingPath:@"users"] childByAppendingPath:user.userID] setValue:userDictionary];
                
                [self loginWithiOSAccount:account];
            }
        }
    }];
}

- (void)loginWithiOSAccount:(ACAccount *)account
{
    self.twitterClient = nil;
    self.twitterClient = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [self.twitterClient verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        self.sharedData.twitter = self.twitterClient;
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LoggedInUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UserDidRegisterKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogInNotificationName object:nil];
        
        [self saveAccount:account];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        NSString *message = [NSString stringWithFormat:@"There was an error signing in to Twitter: %@", error.localizedDescription];
        [self showAlertWithMessage:message];
    }];
}

-(void)saveAccount:(ACAccount *)account
{
    [self.accountStore saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"account saved - identifier: %@", account.identifier);
        [[NSUserDefaults standardUserDefaults] setObject:account.identifier forKey:AccountIdentifierKey];
        //        self.accountStore = self.sharedData.accountStore;
        //dont think i need this ^^
        
    }];
}

#pragma mark - Firebase Methods

-(void)checkForUserInFirebase
{
    [[self.firebaseReference childByAppendingPath:@"users"]
     observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
         
         self.userFoundInFirebase = [snapshot hasChild:self.userQuery];
         NSLog(@"in snapshot thing %@", snapshot.key);
         NSLog(@"test bool ----- %d", self.userFoundInFirebase);
         
         [self startAuthProcess];
     }];
    
}

-(JDDUser *)createUserFromData:(FAuthData *)data
{
    JDDUser *newUser = [[JDDUser alloc] init];
    newUser.userID = self.phoneNumberTextField.text;
    newUser.twitterHandle = data.providerData[@"username"];
    newUser.userImageURL = data.providerData[@"profileImageURL"];
    newUser.displayName = data.providerData[@"displayName"];
    newUser.phoneNumber = self.phoneNumberTextField.text;
    
    return newUser;
}

-(NSDictionary *)createUserDictionary:(FAuthData *)data
{
    return  @{ @"userID" : self.phoneNumberTextField.text,
               @"profileImageURL" : data.providerData[@"profileImageURL"],
               @"twitterHandle" : data.providerData[@"username"],
               @"displayName" : data.providerData[@"displayName"],
               @"phoneNumber" : self.phoneNumberTextField.text
               };
}

#pragma mark - Alerts & Button Enabling

- (void)showAlertWithMessage:(NSString *)errorMessage
{
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Uh-oh!"
                                                                        message:errorMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   
                                                   [errorAlert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [errorAlert addAction:ok];
    
    [self presentViewController:errorAlert animated:YES completion:nil];
}

-(void)enableLoginButton
{
    self.loginButton.enabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.loginContainer.alpha = 0.4;
        self.loginButton.alpha = 1;
    }];
}

-(BOOL)phoneNumberIsValid
{
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    NSMutableCharacterSet *input = [[NSMutableCharacterSet alloc] init];
    [input addCharactersInString:self.phoneNumberTextField.text];
    if (self.phoneNumberTextField.text.length == 10 &&
        [numbers isSupersetOfSet:input]) {
        return YES;
    }
    return NO;
}

- (IBAction)phoneNumberEditingChanged:(id)sender
{
    if (self.phoneNumberTextField.text.length == 10 &&
        ![self phoneNumberIsValid]) {
        [UIView animateWithDuration:0.33 animations:^{
            self.phoneNumberTextFieldWidth.constant += 100;
            self.phoneNumberTextField.backgroundColor = [UIColor redColor];
        } completion:^(BOOL finished) {
            self.phoneNumberTextFieldWidth.constant -= 100;
            self.phoneNumberTextField.backgroundColor = [UIColor whiteColor];
        }];
    }
    if ([self phoneNumberIsValid]) {
        [self enableLoginButton];
    }
    if (self.phoneNumberTextField.text.length >10 ||
        self.phoneNumberTextField.text.length < 10) {
        self.loginButton.enabled = NO;
        self.userFoundInFirebase = NO;
        self.loginContainer.alpha = 0.1;
        self.loginButton.alpha = 0.5;
    }
}

- (IBAction)phoneNumberEditingDidEnd:(id)sender
{
    if (![self phoneNumberIsValid]) {
        [UIView animateWithDuration:0.4 animations:^{
            self.phoneNumberTextFieldWidth.constant += 75;
            self.phoneNumberTextField.backgroundColor = [UIColor redColor];
        } completion:^(BOOL finished) {
            self.phoneNumberTextFieldWidth.constant -= 75;
            self.phoneNumberTextField.backgroundColor = [UIColor whiteColor];
        }];
    }
}

- (IBAction)screenTapped:(id)sender
{
    [self.phoneNumberTextField resignFirstResponder];
}

@end
