//
//  AppDelegate.m
//  Stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "AppDelegate.h"
#import "Secrets.h"
#import <STTwitter/STTwitter.h>
#import "LoginViewController.h"
#import "JDDDataSource.h"

@interface AppDelegate ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) JDDDataSource *dataSource;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //verify credentials!!!!!
    self.dataSource = [JDDDataSource sharedDataSource];
    
    if (!self.oauthToken) {
//        NSString *board = @"Main";
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:board bundle: nil];
//        LoginViewController *login = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        [self.viewcon presentViewController:login animated:YES completion:nil];
//        self performseguewith
    } else {
        //+[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
        
        // call -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
    
    }
    
    
    
    return YES;
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    for(NSString *string in queryComponents) {
        NSArray *pair = [string componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        NSString *key = pair[0];
        NSString *value = pair[1];
        dictionary[key] = value;
    }
    return dictionary;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    if ([[url scheme] isEqualToString:@"jdd-stakes-groupapp"] == NO) return NO;
    
    NSDictionary *tokenDictionary = [self parametersDictionaryFromQueryString:[url query]];
    self.dataSource.currentUser.twitterOAuth = tokenDictionary[@"oauth_token"];
    NSLog(@"datasource current user twitteroauth %@", self.dataSource.currentUser.twitterOAuth);
    NSString *verifier = tokenDictionary[@"oauth_verifier"];
    
    LoginViewController *vc = (LoginViewController *)[[self window] rootViewController];
    [vc setOAuthToken:self.dataSource.currentUser.twitterOAuth oauthVerifier:verifier];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //verify credentials!!!!!!!!!
#warning verify
    
    
    
    
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
