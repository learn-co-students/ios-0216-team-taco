//
//  LoginViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "LoginViewController.h"
#import <STTwitter/STTwitter.h>
#import <Accounts/Accounts.h>
#import <SafariServices/SafariServices.h>
#import "Secrets.h"

@interface LoginViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (weak, nonatomic) IBOutlet UITextField *tweetField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    [self.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"WE HAVE AN ACCESS TOKEN --- %@", self.twitter.oauthAccessToken);
        self.oauthtoken = self.twitter.oauthAccessToken;
        NSLog(@"------------- %@ --------- PROPERTY FOR ACCESS TOKEN", self.oauthtoken);
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


@end
