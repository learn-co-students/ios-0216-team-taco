//
//  LoginViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//
#import <STTwitter/STTwitter.h>
#import "Constants.h"
#import "JDDDataSource.h"
#import "LoginViewController.h"
#import "Secrets.h"
#import "TwitterAuthHelper.h"
#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface LoginViewController ()

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) TwitterAuthHelper *helper;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UITextField *tweetField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [JDDDataSource sharedDataSource];
    self.ref = self.dataSource.firebaseRef;
    
    NSLog(@"current user is: %@", self.dataSource.currentUser.userID);
    self.accountStore = [[ACAccountStore alloc] init];
    NSLog(@"view did load account: %@", [self.accountStore.accounts firstObject]);
}


- (void)generateAndPresentAlertWithMessage:(NSString *)errorMessage
{
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Well this is awkward..."
                                                                        message:errorMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   
                                                   [errorAlert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [errorAlert addAction:ok];
    
    [self presentViewController:errorAlert animated:YES completion:nil];
}

- (IBAction)loginTapped:(id)sender
{
    NSLog(@"login tappeD");
    self.helper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.ref apiKey:TWITTER_KEY];
    
    [self.helper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        NSLog(@"in helper");
        NSString *message;
        
        if (error) {
            message = [NSString stringWithFormat:@"Please don't put this in your review, but there was an error logging into Twitter: %@", error.localizedDescription];
            [self generateAndPresentAlertWithMessage:message];
            
        } else if (accounts.count == 0) {
            message = @"No Twitter accounts found.  Please add an account in your phone's settings.";
            [self generateAndPresentAlertWithMessage:message];
            
        }
        else {
            [self selectTwitterAccount:accounts];
        }
    }];
}


- (void)authenticateWithTwitterAccount:(ACAccount *)account
{
    NSLog(@"in authenticate account method)");
    [self.helper authenticateAccount:account withCallback:^(NSError *error, FAuthData *authData) {
        if (error) {
            // Error authenticating account with Firebase
            NSString *message = [NSString stringWithFormat:@"Please don't put this in your review, but there was an error authenticating your account: %@", error.localizedDescription];
            [self generateAndPresentAlertWithMessage:message];
        } else {
            // User successfully logged in
            NSLog(@"Logged in! AUTH DATA!!! %@", authData.auth);
            
            NSDictionary *newUser = @{ @"userID" : self.phoneNumberTextField.text,
                                       @"profileImageURL" : authData.providerData[@"profileImageURL"],
                                       @"twitterHandle" : authData.providerData[@"username"],
                                       @"displayName" : authData.providerData[@"displayName"],
                                       @"phoneNumber" : self.phoneNumberTextField.text
                                       };
            
            JDDUser *new = [[JDDUser alloc] init];
            new.userID = self.phoneNumberTextField.text;

            new.twitterHandle = authData.providerData[@"username"];
//            new.userImage = [UIImage imageNamed:@""];
            new.displayName = authData.providerData[@"displayName"];
            new.phoneNumber = self.phoneNumberTextField.text;
            NSLog(@"new user created %@", new);
            self.dataSource.currentUser = new;
            
            NSLog(@"current user is now: %@", self.dataSource.currentUser.userID);

            NSLog(@"NEW USER DICTIONARY: %@", newUser);
            
//              this will commit data to Firebase
    //if we have a registered user, then just update
            
            //if its not a registered user, then setvalue
            [[[self.ref childByAppendingPath:@"users"] childByAppendingPath:self.phoneNumberTextField.text] setValue:newUser];

            [self loginWithiOSAccount:account];
            
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.phoneNumberTextField.text forKey:@"stakesUserID"];
            NSLog(@"userDefaults for stakesID is %@",[userDefaults stringForKey:@"stakesUserID"]);
            
        }
    }];
}


- (void)selectTwitterAccount:(NSArray *)accounts
{
    UIAlertController *selectUser = [UIAlertController alertControllerWithTitle:@"Please select a Twitter Account"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (ACAccount *account in accounts) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:account.username
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSLog(@"NOW IS WHEN WE SHOULD GO TO AUTHENITCATE ACOUNT");
                                                           [self authenticateWithTwitterAccount:account];
                                                       }];
        [selectUser addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [selectUser addAction:cancel];
    [self presentViewController:selectUser animated:YES completion:^{
        //
    }];
}

- (void)loginWithiOSAccount:(ACAccount *)account
{
    //STTwitter
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        NSLog(@"ALSO VERIFIED IN STTWITTER!!!!!");
        self.dataSource.twitter = self.twitter;
        //here is where we want to launch into the pact screen, once verified in both
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LoggedInUserDefaultsKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogInNotificationName object:nil];
        
        [self.accountStore saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
            NSLog(@"account saved");
            NSLog(@"account identifier: %@", account.identifier);
            [[NSUserDefaults standardUserDefaults] setObject:account.identifier forKey:AccountIdentifierKey];
            self.accountStore = self.dataSource.accountStore;
            
        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        NSString *message = [NSString stringWithFormat:@"Please don't put this in your review, but there was an error signing in to Twitter: %@", error.localizedDescription];
        [self generateAndPresentAlertWithMessage:message];
    }];
}




@end
