//
//  LoginViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "LoginViewController.h"
#import <STTwitter/STTwitter.h>
#import <SafariServices/SafariServices.h>
#import "Secrets.h"
#import "JDDDataSource.h"
#import "TwitterAuthHelper.h"

@interface LoginViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (weak, nonatomic) IBOutlet UITextField *tweetField;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) FAuthData *firebaseUser;
@property (nonatomic, strong) TwitterAuthHelper *helper;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource= [JDDDataSource sharedDataSource];
    self.ref = self.dataSource.firebaseRef;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)generateAndPresentAlertWithMessage:(NSString *)errorMessage
{
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Well this is awkward..." message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [errorAlert dismissViewControllerAnimated:YES completion:nil];
    }];
    [errorAlert addAction:ok];
    [self presentViewController:errorAlert animated:YES completion:nil];
    
}

- (IBAction)loginTapped:(id)sender {
    self.helper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.ref apiKey:TWITTER_KEY];
    [self.helper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"Please don't put this in your review, but there was an error logging into Twitter: %@", error.localizedDescription];
            [self generateAndPresentAlertWithMessage:message];
        }
        else if (accounts.count == 0) {
            NSString *message = @"No Twitter accounts found.  Please add an account in your phone's settings.";
            [self generateAndPresentAlertWithMessage:message];
        }
        else if (accounts.count == 1 ) {
            [self authenticateWithTwitterAccount:[accounts firstObject]];
        }
        else {
            [self selectTwitterAccount:accounts];
        }
    }];
}

- (void) authenticateWithTwitterAccount:(ACAccount *)account {
    [self.helper authenticateAccount:account withCallback:^(NSError *error, FAuthData *authData) {
        if (error) {
            // Error authenticating account with Firebase
            NSString *message = [NSString stringWithFormat:@"Please don't put this in your review, but there was an error authenticating your account: %@", error.localizedDescription];
            [self generateAndPresentAlertWithMessage:message];
        } else {
            // User successfully logged in
            NSLog(@"Logged in! AUTH DATA!!! %@", authData.auth);
            
            NSDictionary *newUser = @{ @"userID" : authData.uid,
                                    @"displayName": authData.providerData[@"displayName"],
                                    @"profileImageURL" : authData.providerData[@"profileImageURL"],
                                    @"twitterHandle" : authData.providerData[@"username"],
                                       @"firstName" : @"",
                                       @"lastName" : @"",
                                       @"phoneNumber" : @""
                                    };
            self.dataSource.currentUser.userID = self.phoneNumberTextField
            .text;
            self.dataSource.currentUser.twitterHandle = authData.providerData[@"username"];
            self.dataSource.currentUser.userImage = [UIImage imageNamed:@""];
            self.dataSource.currentUser.firstName = @"";
            self.dataSource.currentUser.lastName = @"";
            self.dataSource.currentUser.phoneNumber = @"";
            NSLog(@"NEW USER DICTIONARY: %@", newUser);
//              this will commit data to Firebase
            [[[self.ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] setValue:newUser];

            [self loginWithiOSAccount:account];
        }
    }];
}
- (void) selectTwitterAccount:(NSArray *)accounts {
    UIAlertController *selectUser = [UIAlertController alertControllerWithTitle:@"Please select a Twitter Account" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (ACAccount *account in accounts) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:account.username style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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


- (IBAction)tweet:(id)sender {
    NSString *tweet = self.tweetField.text;
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
                     [self generateAndPresentAlertWithMessage:message];
                 }];
}

- (IBAction)goToPacts:(id)sender {
    [self performSegueWithIdentifier:@"pacts" sender:self];
}

- (IBAction)logoutTapped:(id)sender {
    [self.ref unauth];
    NSLog(@"logged out of Firebase");
    self.twitter = nil;
    NSLog(@"logged out of STTwitter");
}

-(void)loginWithiOSAccount:(ACAccount *)account {
    //STTwitter
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        NSLog(@"ALSO VERIFIED IN STTWITTER!!!!!");
        
        //here is where we want to launch into the pact screen, once verified in both
        self.dataSource.twitter = self.twitter;
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        NSString *message = [NSString stringWithFormat:@"Please don't put this in your review, but there was an error signing in to Twitter: %@", error.localizedDescription];
        [self generateAndPresentAlertWithMessage:message];
    }];
}




@end
