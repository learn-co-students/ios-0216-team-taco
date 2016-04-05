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

- (IBAction)loginTapped:(id)sender {
    self.helper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.ref apiKey:TWITTER_KEY];
    [self.helper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"There was an error logging into Twitter: %@", [error localizedDescription]];
            //show alert with message
        }
        else if ([accounts count] == 0) {
            // No Twitter accounts found on device
        }
        else {
            [self handleMultipleTwitterAccounts:accounts];
        }
    }];
}

- (void) handleMultipleTwitterAccounts:(NSArray *)accounts {
    switch ([accounts count]) {
        case 0:
            // No account on device.
            break;
        case 1:
            // Single user system, go straight to login
            [self authenticateWithTwitterAccount:[accounts firstObject]];
            [self loginWithiOSAccount:[accounts firstObject]];
            break;
        default:
            // Handle multiple users
            [self selectTwitterAccount:accounts];
            break;
    }
}

- (void) authenticateWithTwitterAccount:(ACAccount *)account {
    [self.helper authenticateAccount:account withCallback:^(NSError *error, FAuthData *authData) {
        if (error) {
            // Error authenticating account with Firebase
        } else {
            // User successfully logged in
            NSLog(@"Logged in! AUTH DATA!!! %@", authData.auth);
            NSDictionary *newUser = @{ @"uid" : authData.uid,
                                    @"displayName": authData.providerData[@"displayName"],
                                    @"profileImageURL" : authData.providerData[@"profileImageURL"],
                                    @"twitterHandle" : authData.providerData[@"username"],
                                    };
                                      
            NSLog(@"NEW USER DICTIONARY: %@", newUser);
              //this will commit data to Firebase
            [[[self.ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] setValue:newUser];

            [self loginWithiOSAccount:account];
        }
    }];
}
- (void) selectTwitterAccount:(NSArray *)accounts {
    UIAlertController *selectUser = [UIAlertController alertControllerWithTitle:@"Select Twitter Account" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
                 }];
}

- (IBAction)goToPacts:(id)sender {
    [self performSegueWithIdentifier:@"pacts" sender:self];
}

- (IBAction)logoutTapped:(id)sender {
//    [self.ref unauth];
}

-(void)loginWithiOSAccount:(ACAccount *)account {
    //STTwitter
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        NSLog(@"ALSO VERIFIED IN STTWITTER!!!!!");

    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
