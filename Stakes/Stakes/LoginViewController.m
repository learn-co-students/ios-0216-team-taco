//
//  LoginViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//
#import <Foundation/Foundation.h>

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <BALoadingView/BALoadingView.h>
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
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UILabel *phoneNumberLabel;
@property (nonatomic, weak) IBOutlet UIView *loginContainer;
@property (nonatomic, strong) IBOutlet UITextField *phoneNumberTextField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *phoneNumberTextFieldWidth;
@property (nonatomic) BOOL userDidRegister;
@property (nonatomic) BOOL userFoundInFirebase;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) IBOutlet BALoadingView *loadingView;
@property(nonatomic, assign) BACircleAnimation animationType;
@property(nonatomic, assign) bool firstLoad;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sharedData = [JDDDataSource sharedDataSource];
    self.accountStore = [[ACAccountStore alloc] init];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    self.firstLoad = YES;
    self.loadingView.hidden = YES;
    
}

-(void)viewDidLayoutSubviews
{
    if (self.firstLoad) {
        
        [self.loadingView initialize];
        self.loadingView.lineCap = kCALineCapRound;
        self.loadingView.clockwise = true;
        self.loadingView.segmentColor = [UIColor whiteColor];
        self.firstLoad = NO;
    }
}
#pragma mark - Login and Authentication

- (IBAction)loginTapped:(id)sender
{
    self.loginContainer.hidden = YES;
    self.phoneNumberTextField.hidden = YES;
    self.phoneNumberLabel.hidden = YES;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimation:BACircleAnimationFullCircle];
    
    
    NSLog(@"login");
    if (self.userDidRegister) {
        
        self.userQuery = [[NSUserDefaults standardUserDefaults] objectForKey:UserIDKey];
        NSLog(@"LOGIN TAPPED< self.userquery: %@", self.userQuery);
        [self startAuthProcess];
        
    } else {
        
        self.userQuery = self.phoneNumberTextField.text;
        [self checkForUserInFirebase];
    }
    
}

-(void)startAuthProcess
{
    NSLog(@"auth");
    self.twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.firebaseReference apiKey:TWITTER_KEY];
    
    [self.twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        NSString *message;
        
        if (error) {
            message = [NSString stringWithFormat:@"There was an error logging into Twitter: %@", error.localizedDescription]; // That's cute
            [self showAlertWithMessage:message];
            [self.loadingView stopAnimation];
            self.loadingView.hidden = YES;
            self.loginContainer.hidden = NO;
            if (!self.userDidRegister) {
                self.phoneNumberTextField.hidden = NO;
                self.phoneNumberLabel.hidden = NO;
            }
            //            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else if (accounts.count == 0) {
            message = @"No Twitter accounts found. Please add an account in your phone's settings.";
            [self showAlertWithMessage:message];
            [self.loadingView stopAnimation];
            self.loadingView.hidden = YES;
            self.loginContainer.hidden = NO;
            if (!self.userDidRegister) {
                self.phoneNumberTextField.hidden = NO;
                self.phoneNumberLabel.hidden = NO;
            }
            //            [self dismissViewControllerAnimated:YES completion:nil];
            
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
        [self.loadingView stopAnimation];
        self.loadingView.hidden = YES;
        self.loginContainer.hidden = NO;
        
        if (!self.userDidRegister) {
            
            self.phoneNumberTextField.hidden = NO;
            self.phoneNumberLabel.hidden = NO;
        }
        
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
            [self.loadingView stopAnimation];
            self.loadingView.hidden = YES;
            self.loginContainer.hidden = NO;
            
            if (!self.userDidRegister) {
                
                self.phoneNumberTextField.hidden = NO;
                self.phoneNumberLabel.hidden = NO;
            }
            
            [self showAlertWithMessage:message];
            
        } else {
            
            if (self.userDidRegister) { // this person has registered the app at some point in time
                
                NSLog(@"IN AUTHENTICATE IN FIREBASE, AUTH DATA %@", authData);
                NSDictionary *userDictionary = [self createUserDictionary:authData];
                JDDUser *user = [self createUserFromData:authData];
                NSLog(@"shared data %@", self.sharedData.currentUser.userID);
                NSLog(@"user id %@", user.userID);
                NSLog(@"now we are setting shared current = to current");
                self.sharedData.currentUser = user; // this is setting the current user
                NSLog(@"shared data %@", self.sharedData.currentUser.userID);
                NSLog(@"user id %@", user.userID);
                //                [[NSUserDefaults standardUserDefaults] setObject:user.userID forKey:UserIDKey];
                NSLog(@"user exists... in did register...setting user default key for user ID: %@", user.userID);
                
                [[[self.firebaseReference childByAppendingPath:@"users"] childByAppendingPath:user.userID] updateChildValues:userDictionary];
                
                [self loginWithiOSAccount:account];
                
            } else if (self.userFoundInFirebase){ // this person exists in firebase
                NSLog(@"IN AUTHENTICATE IN FIREBASE, AUTH DATA %@", authData);
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
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasLaunchedBefore"]) {// this is just to know if someone is a firstTime user
            NSLog(@"First launch");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasLaunchedBefore"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogInNotificationName object:nil];
        
        [self saveAccount:account];
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"%@", error.localizedDescription);
        NSString *message = [NSString stringWithFormat:@"There was an error signing in to Twitter: %@", error.localizedDescription];
        [self.loadingView stopAnimation];
        self.loadingView.hidden = YES;
        self.loginContainer.hidden = NO;
        if (!self.userDidRegister) {
            self.phoneNumberTextField.hidden = NO;
            self.phoneNumberLabel.hidden = NO;
        }
        
        [self showAlertWithMessage:message];
    }];
}

-(void)saveAccount:(ACAccount *)account
{
    [self.accountStore saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"account saved - identifier: %@", account.identifier);
        [[NSUserDefaults standardUserDefaults] setObject:account.identifier forKey:AccountIdentifierKey];
        [self.loadingView stopAnimation];
        self.loadingView.hidden = YES;
        self.loginContainer.hidden = NO;
        
    }];
}

#pragma mark - Firebase Methods

-(void)checkForUserInFirebase
{
    NSLog(@"checkingfor user in firebase");
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
    newUser.userID = self.userQuery;
    newUser.twitterHandle = data.providerData[@"username"];
    newUser.userImageURL = data.providerData[@"profileImageURL"];
    newUser.displayName = data.providerData[@"displayName"];
    newUser.phoneNumber = self.userQuery;
    
    return newUser;
}

-(NSDictionary *)createUserDictionary:(FAuthData *)data
{
    return  @{ @"userID" : self.userQuery,
               @"profileImageURL" : data.providerData[@"profileImageURL"],
               @"twitterHandle" : data.providerData[@"username"],
               @"displayName" : data.providerData[@"displayName"],
               @"phoneNumber" : self.userQuery
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
        self.loginContainer.alpha = 1
        ;
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
