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
#import "JDDCheckIn.h"

@interface AppDelegate ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) NSDate * currentDate;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    NSLog(@"background Fetch has started");
    
    self.currentDate = [NSDate date];
    
    [self.dataSource establishCurrentUserWithBlock:^(BOOL completionBlock) {
        
        NSLog(@"establishing current user");
        
        if (completionBlock) {
            
            if (self.dataSource.currentUser.pacts.count == 0) {
                
                //do nothing
                
            } else {
                
                [self.dataSource methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
                    
                    if (completionBlock) {
                        
                        NSLog(@"awesome now we have all the pacts %@", self.dataSource.currentUser.pactsToShowInApp);
                        
                        NSUInteger pactCount = self.dataSource.currentUser.pactsToShowInApp.count;
                        
                        // throw this bad boy in a for loop and check all sorts of weird.
                        
                        for (JDDPact *pact in self.dataSource.currentUser.pactsToShowInApp) {
                            
                            
                            NSLog(@"time interval %@",pact.timeInterval);
                            pactCount --;
                            
                            NSDateFormatter *checkInDateFormatter = [[NSDateFormatter alloc]init];
                            [checkInDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
                            if (pact.isActive) {
                                
                                if ([self checkIfPactHasExpiredWithStartDate:pact.dateOfCreation andTimeInterval:pact.timeInterval]){
                                    
                                    NSLog(@"time interval %@",pact.timeInterval);
                                    NSLog(@"ok a pact has expired!");
                                    
                                    
                                    
                                    if ([self hasUserAccomplishedCheckinGoalWithPact:pact] == NO) {
                                        
                                        NSLog(@"ok someone hasn't completed their pact!");
                                        
                                        [self sendTwitterShameMessageWithPact:pact];
                                        
                                        NSLog(@"twitterShame Sent is: %@",pact.twitterPost);
                                        NSLog(@"OH SHIT TWITTER SHAME");
                                        
                                        if (pactCount == 0) {
                                            completionHandler(UIBackgroundFetchResultNewData);
                                        }
                                    }
                                    
                                }
                            } else {
                                
                                pactCount --;
                            }
                        }
                    }
                }];
                
            }
            
        }
        
    }];
    
}

-(BOOL)checkIfPactHasExpiredWithStartDate:(NSDate *)startDate andTimeInterval:(NSString *)timeInterval {
    
    BOOL boolToReturn = NO;
    
    NSDate *executionDate = [[NSDate alloc]init];
    
    if ([timeInterval isEqualToString:@"day"]) {
        
        executionDate = [startDate dateByAddingTimeInterval:60*60*24];
        
    } else if ([timeInterval isEqualToString:@"week"]) {
        
        executionDate = [startDate dateByAddingTimeInterval:60*60*24 *7];
        
    } else if ([timeInterval isEqualToString:@"month"]) {
        
        executionDate = [startDate dateByAddingTimeInterval:60*60*24 *30.5];
        
    } else if ([timeInterval isEqualToString:@"year"]) {
        
        executionDate = [startDate dateByAddingTimeInterval:60*60*24 *365];
        
    }
    
        if ([[NSDate date] compare: executionDate] == NSOrderedDescending){
    
            boolToReturn = YES;
        }
    
    return (boolToReturn);
}

-(BOOL)hasUserAccomplishedCheckinGoalWithPact:(JDDPact *)pact{
    
    BOOL boolToReturn = YES;
    
    NSUInteger checkinCount = pact.checkIns.count;
    
    NSUInteger userCheckinCount = 0;
    
    if (pact.checkIns.count == 0) {
        return NO;
    }
    
    for (JDDCheckIn * checkin in pact.checkIns) {
        
        checkinCount --;
        
        if ([checkin.userID isEqualToString:self.dataSource.currentUser.userID]) {
            
            userCheckinCount ++;
        }
        
        if (checkinCount == 0 && (pact.checkInsPerTimeInterval > userCheckinCount)) {
            
            boolToReturn = NO;
            
        }
    }
    
    
    return boolToReturn;
}


- (void)sendTwitterShameMessageWithPact:(JDDPact *)pact {
    
    NSLog(@"twitterShameSent!");
    
        NSLog(@"trying to send a tweet");
    
        NSString *tweet = pact.twitterPost;
    
        [self.dataSource.twitter postStatusUpdate:tweet
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
                                         NSLog(@"ERROR TWEETING: %@", error.localizedDescription);
                                     }];
    
}


@end
