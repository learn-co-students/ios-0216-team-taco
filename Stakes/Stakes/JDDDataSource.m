//
//  JDDDataSource.m
//  Stakes
//
//  Created by Dylan Straughan on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDCheckIn.h"
#import "JDDMessage.h"
#import "UIImageView+AFNetworking.h"
#import "Firebase.h"
#import "JSQMessage.h"

@import UIKit;


@implementation JDDDataSource

+ (instancetype)sharedDataSource {
    
    static JDDDataSource *_sharedPiratesDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedPiratesDataStore = [[JDDDataSource alloc] init];
        
    });
    
    return _sharedPiratesDataStore;
    
}

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self establishCurrentUser];
        
    }
    
    return self;
}

//-(void)generateFakeData{
//   
//    JDDUser * dylan = [self createNewUser1];
//    JDDUser * jeremy = [self createNewUser2];
//    JDDUser * dimitry = [self createNewUser3];
//    
//    JDDPact *pact = [self createPact];
//    JDDPact *pact1 = [self createPact1];
//    [pact.users addObjectsFromArray: @[dylan, dimitry, jeremy]];
//    [pact1.users addObjectsFromArray: @[dylan, dimitry, jeremy]];
//    
//    [dylan.pacts addObjectsFromArray:@[pact,pact1]];
//    [jeremy.pacts addObjectsFromArray:@[pact,pact1]];
//    [dimitry.pacts addObjectsFromArray:@[pact,pact1]];
//    
//    [dylan.checkins addObject:[self createCheckInWtihPact:pact user:dylan]];
//    [jeremy.checkins addObject:[self createCheckInWtihPact:pact user:jeremy]];
//    [dimitry.checkins addObject:[self createCheckInWtihPact:pact user:dimitry]];
//    
//    [dylan.checkins addObject:[self createCheckInWtihPact:pact1 user:dylan]];
//    [jeremy.checkins addObject:[self createCheckInWtihPact:pact1 user:jeremy]];
//    [dimitry.checkins addObject:[self createCheckInWtihPact:pact1 user:dimitry]];
//    
//    self.users = [[NSMutableArray alloc]init];
//    
//    [self.users addObjectsFromArray: @[dylan, dimitry, jeremy]];
//    
//}
//
//-(JDDUser*)createNewUser1 {
//    
//    JDDUser *dylan = [[JDDUser alloc]init];
//    
//    dylan.firstName = @"Dylan";
//    dylan.lastName = @"Straughan";
//    dylan.phoneNumber= @"3015128925";
//    dylan.userID= @"1278619234798";
//    dylan.pacts = [[NSMutableArray alloc]init];
//    dylan.checkins = [[NSMutableArray alloc]init];
//    dylan.twitterHandle= @"@DylanStraughan";
//    dylan.userImage = [UIImage imageNamed:@"Dylan"];
//    dylan.userID = [NSString stringWithFormat:@"%d", 1000];
//    
//    return dylan;
//    
//}
//
//-(JDDUser*)createNewUser2 {
//    
//    JDDUser *jeremy = [[JDDUser alloc]init];
//    
//    jeremy.firstName = @"Jeremy";
//    jeremy.lastName = @"Feld";
//    jeremy.phoneNumber= @"3011111112";
//    jeremy.userID= @"1278619234799";
//    jeremy.pacts = [[NSMutableArray alloc]init];
//    jeremy.checkins = [[NSMutableArray alloc]init];
//    jeremy.userImage = [UIImage imageNamed:@"Jeremy"];
//    jeremy.userID = [NSString stringWithFormat:@"%d", 1001];
//
//
//    jeremy.twitterHandle= @"@jfeld";
//    
//    return jeremy;
//}
//
//-(JDDUser*)createNewUser3 {
//    
//    JDDUser *dimitry = [[JDDUser alloc]init];
//    
//    dimitry.firstName = @"Dimitry";
//    dimitry.lastName = @"Kruyakla;fnkdmal;fd";
//    dimitry.phoneNumber= @"3011111113";
//    dimitry.userID= @"1278619234799";
//    dimitry.pacts = [[NSMutableArray alloc]init];
//    dimitry.checkins = [[NSMutableArray alloc]init];
//    dimitry.userImage = [UIImage imageNamed:@"Dimitry"];
//    dimitry.userID = [NSString stringWithFormat:@"%d", 1002];
//
//    
//    dimitry.twitterHandle= @"@dKaoiruek";
//    
//    return dimitry;
//}

-(JDDPact*)createPactForFirstTimeUser{
    
    JDDPact *pact = [[JDDPact alloc]init];
    
    pact.title = @"Gym with Boys";
    pact.pactDescription = @"Need to go to gym 3x a week";
    pact.stakes = @"Loser has to buy beer";
    pact.users = [[NSMutableArray alloc]init];
    
    pact.checkInsPerTimeInterval = 3;
    pact.timeInterval = @"week";
    pact.repeating = YES;
    
    pact.allowsShaming = YES;
    pact.twitterPost = @"man, all these donuts are incredible";
    
    pact.users = [[NSMutableArray alloc]init];
    
    pact.messages = [NSMutableArray new];
 
    return pact;
}

//
//-(JDDPact*)createPact1{
//    
//    JDDPact *pact = [[JDDPact alloc]init];
//    
//    pact.title = @"Jump Like an idiot";
//    pact.pactDescription = @"Jump 5 times a day";
//    pact.stakes = @"Loser has to buy a pony";
//    pact.users = [[NSMutableArray alloc]init];
//    
//    pact.checkInsPerTimeInterval = 7;
//    pact.timeInterval = @"week";
//    pact.repeating = YES;
//    
//    pact.allowsShaming = YES;
//    pact.twitterPost = @"Im jumping like a clown";
//    
//    pact.messages = [NSMutableArray new];
//    
//    return pact;
//}
//
//-(JDDCheckIn*)createCheckInWtihPact:(JDDPact *)pact user:(JDDUser *)user {
//    
//    JDDCheckIn *checkIn = [[JDDCheckIn alloc]init];
//    
//    checkIn.checkInDate = [NSDate date];
//    checkIn.checkInLocation = [[CLLocation alloc]init];
//    checkIn.checkInMessage = @"I'm here mothafluppa";
//    
//    checkIn.userID = user.userID;
//    checkIn.pactID = pact.pactID;
//    
//    return checkIn;
//    
//}

//-(void)tweetMessageForUserWhoHasntCompletedPact {



// For Twitter API
// needs BOOL (completed or not completed) - NSDate, User and Pact
// if User has not completed checkins in a specific NSdate (BOOL)
// maybe this takes a NSNotification? that is called when a date hits



//}

-(void)setUpFireBaseRef {
    
    self.firebaseRef = [[Firebase alloc]initWithUrl:@"https://jddstakes.firebaseio.com/"];
        
}

-(void)establishCurrentUser {
    
    [self setUpFireBaseRef];
    
    self.currentUser = [[JDDUser alloc]init];
    self.currentUserPacts = [[NSMutableArray alloc]init];
    
//this is taking value in the phone and checking it vs the database
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"userDefaults for stakesID is %@",[defaults stringForKey:@"stakesUserID"]);
    NSString *currentUserID = [defaults stringForKey:@"stakesUserID"];
    
// pulling value from NSUserDefaults from firebase
    
    if ([defaults stringForKey:@"stakesUserID"]) {
    
    Firebase *newRef = [self.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",currentUserID]];
    
    [newRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) { //Happens only when a change to firebase happens
        
        self.currentUser = [self takeSnapShotAndCreateUser:snapshot];
        
        NSLog(@"snapshot %@", snapshot.value);
        NSLog(@"this is the current user %@", self.currentUser);
        
// pulling pacts from currentUser from firebase
        for (NSString *pactID in self.currentUser.pacts) {
            
            Firebase *pactRef = [self.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@",pactID]];
            
            [pactRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot2) {
                
                [self.currentUserPacts addObject:[self takeSnapShotAndCreatePact:snapshot2]];
                
                NSLog(@"this is the pact getting added to self.currentUserPacts %@", snapshot2.value);
                NSLog(@"currentUserPacts: %@", self.currentUserPacts);
                
            }];
            
            
        }
        
    } withCancelBlock:^(NSError *error) {
        
        NSLog(@"snapshot value %@", error.description);
        
    }];
        
    }
    
}

-(JDDUser *)takeSnapShotAndCreateUser:(FDataSnapshot *)snapshot {
    
    JDDUser *user = [[JDDUser alloc]init];

    UIImageView * image = [[UIImageView alloc]init];
    [image setImageWithURL:[NSURL URLWithString:snapshot.value[@"profileImageURL"]]];
    user.userID = snapshot.value[@"userID"];
    user.userImage = image.image;
    user.twitterHandle = snapshot.value[@"twitterHandle"];
    user.displayName = snapshot.value[@"userID"];
    user.phoneNumber = snapshot.value[@"phoneNumber"];
    
    self.twitter = [[STTwitterAPI alloc]init];
    
    self.currentUser = [[JDDUser alloc]init];
    
    

    if(snapshot.value[@"pacts"]) {
        
        user.pacts = snapshot.value[@"pacts"];
        
    }
    
    if(snapshot.value[@"pactHistory"]) {
        
        user.pacts = snapshot.value[@"pactHistory"];
        
    }
    
    if(snapshot.value[@"pendingPacts"]) {
        
        user.pacts = snapshot.value[@"pendingPacts"];
        
    }
    
    return user;
}

-(JDDPact *)takeSnapShotAndCreatePact:(FDataSnapshot*)snapshot {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
    
    JDDPact *pact = [[JDDPact alloc]init];
    
    pact.pactID = snapshot.value[@"pactID"];
    pact.pactDescription = snapshot.value[@"pactDescription"];
    pact.title = snapshot.value[@"title"];

    pact.stakes = snapshot.value[@"twitterHandle"];
    pact.users = snapshot.value[@"users"];
    pact.repeating = [snapshot.value[@"repeating"] boolValue];
    pact.allowsShaming = [snapshot.value[@"allowsShaming"] boolValue];
    pact.checkInsPerTimeInterval = [snapshot.value[@"allowsShaming"] integerValue];
    pact.twitterPost = snapshot.value[@"twitterPost"];
    pact.dateOfCreation = [dateFormatter dateFromString:snapshot.value[@"dateOfCreation"]];
    
    if(snapshot.value[@"messages"]) {
        
        pact.messages = snapshot.value[@"messages"];
        
    }
    
    return pact;

}

-(JDDCheckIn *)takeSnapShotAndCreateCheckIn:(FDataSnapshot*)snapshot {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'-'ss'"];
    
    JDDCheckIn *checkIn = [[JDDCheckIn alloc]init];
    
    checkIn.checkInID = snapshot.value[@"checkInID"];
    checkIn.checkInDate = [dateFormatter dateFromString:snapshot.value[@"checkInDate"]];
    checkIn.checkInMessage = snapshot.value[@"checkInMessage"];
    
    checkIn.userID = snapshot.value[@"userID"];
    checkIn.pactID = snapshot.value[@"pactID"];
    
    return checkIn;
}

-(NSMutableDictionary*)createDictionaryToSendToFirebasefromJDDUser:(JDDUser*)user {
    
    NSDictionary *newUser = @{ @"userID" : user.userID,
                               @"profileImageURL" : user.userImageURL,
                               @"twitterHandle" : user.twitterHandle,
                               @"firstName" : user.displayName,
                               @"phoneNumber" : user.phoneNumber
                               
                               };
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithDictionary:newUser];
    
    return dictionary;
    
}





@end
