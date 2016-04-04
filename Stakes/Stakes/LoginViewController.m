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

@interface LoginViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (weak, nonatomic) IBOutlet UITextField *tweetField;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) FAuthData *firebaseUser;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource= [JDDDataSource sharedDataSource];
    
    self.ref = [[Firebase alloc] initWithUrl:kFirebaseURL];
    [self.ref observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData) {
            // user authenticated
            
            NSLog(@"have firebase auth %@", authData);
            
            NSDictionary *newUser = @{
                                      @"uid" : authData.uid,
                                      @"displayName": authData.providerData[@"displayName"],
                                      @"profileImageURL" : authData.providerData[@"profileImageURL"],
                                      @"twitterHandle" : authData.providerData[@"username"],
                                      };
            
            NSLog(@"NEW USER DICTIONARY: %@", newUser);
            
            [[[self.ref childByAppendingPath:@"users"]
              childByAppendingPath:authData.uid] setValue:newUser];
            
            NSLog(@"VIEW DID LOAD %@", authData);
        } else {
            // No user is signed in
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTapped:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_KEY
                                                 consumerSecret:TWITTER_SECRET];
    [self.twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        [[UIApplication sharedApplication] openURL:url];
    } authenticateInsteadOfAuthorize:NO
                        forceLogin:@(YES)
                        screenName:nil
                     oauthCallback:@"jdd-stakes-groupapp://twitter_access_tokens/"
                        errorBlock:^(NSError *error) {
        NSLog(@"-- error: %@", error);
    }];
    
    
}

-(void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {

    [self.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {

        self.dataSource.currentUser.twitterOAuth = self.twitter.oauthAccessToken;
        NSLog(@"in loginVC, setOAuthToken method %@", self.dataSource.currentUser.twitterOAuth);

        
        NSLog(@"auth data???? %@", self.ref.authData);
//        self.ref = [[Firebase alloc] initWithUrl:kFirebaseURL];
//        [self.ref observeAuthEventWithBlock:^(FAuthData *authData) {
//            if (authData) {
//    
//                NSLog(@"have firebase auth %@", authData);
//                
//                NSDictionary *newUser = @{
//                                          @"uid" : authData.uid,
//                                          @"displayName": authData.providerData[@"displayName"],
//                                          @"profileImageURL" : authData.providerData[@"profileImageURL"],
//                                          @"twitterHandle" : authData.providerData[@"username"],
//                                          };
//                
//                NSLog(@"NEW USER DICTIONARY: %@", newUser);
//                
//                [[[self.ref childByAppendingPath:@"users"]
//                  childByAppendingPath:authData.uid] setValue:newUser];
        
//                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                [defaults setObject:authData.uid forKey:@"uid"];
//                [defaults setObject:authData.providerData[@"displayName"] forKey:@"name"];
//                [defaults setObject:authData.providerData[@"profileImageURL"] forKey:@"profileImageURL"];
//                [defaults setObject:authData.providerData[@"username"] forKey:@"twitterHandle"];
//                [defaults setObject:self.twitter.oauthAccessToken forKey:@"oauthAccessToken"];
//                [defaults synchronize];
                
//                
//                JDDUser *newPerson = [[JDDUser alloc]init];
//                
//                newPerson.firstName = authData.providerData[@"displayName"];
//                newPerson.emailAddress= @"";
//                newPerson.phoneNumber= @"";
//                newPerson.userID= authData.providerData[@"username"];
//                newPerson.pacts = [[NSMutableArray alloc]init];
//                newPerson.checkins = [[NSMutableArray alloc]init];
//                newPerson.userImage = [UIImage imageNamed:@"Jeremy"];
//                
////                NSLog(@"newPerson check id: %@", newPerson.userID);
//
//            } else {
//                // THERE WAS AN ERROR
//            }
//        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
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

@end
