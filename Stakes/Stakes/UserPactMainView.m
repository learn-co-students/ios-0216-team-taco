//
//  UserPactCellView.m
//  Stakes
//
//  Created by Dylan Straughan on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "UserPactMainView.h"
#import "JDDDataSource.h"
#import "JDDCheckIn.h"
#import "JSQMessage.h"
#import "JSQLocationMediaItem.h"
#import "UserDescriptionView.h"
#import "Firebase.h"
#import "Constants.h"
#import "PactDetailViewController.h"
#import "UserPactsViewController.h"
#import "Constants.h"

@interface UserPactMainView ()

@property (strong, nonatomic) IBOutlet UserPactMainView * contentView;
@property (strong, nonatomic) IBOutlet UIView *viewForScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIStackView *stackView;
@property (strong, nonatomic) IBOutlet UIView *textView;
@property (strong, nonatomic) IBOutlet UILabel *twitterText;
@property (strong, nonatomic) IBOutlet UILabel *TwitterTitle;
@property (strong, nonatomic) IBOutlet UILabel *pactText;
@property (strong, nonatomic) IBOutlet UILabel *stakesText;
@property (strong, nonatomic) IBOutlet UILabel *pactTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UIView *CheckInButtonView;
@property (strong, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet UILabel *checkInLabel;

@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) CLLocation *location;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) JDDDataSource *sharedData;
@property (nonatomic, strong) JDDCheckIn *checkIn;
@property (nonatomic,strong) Firebase *firebase;

@end

@implementation UserPactMainView

//=============================================================================================================================


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
   
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit
{
    
    NSLog(@"commonInit called in UserPactMainView.");
    
    [[NSBundle mainBundle] loadNibNamed:@"UserPactMainView" owner:self options:nil];
    
    [self addSubview:self.contentView];
    
    self.sharedData = [JDDDataSource sharedDataSource];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
    [self addObserver:self forKeyPath:@"pact.users" options:NSKeyValueObservingOptionNew context:nil];
}


- (IBAction)checkInButtonPressed:(id)sender {
       
    NSLog(@"checkin Button Pressed");
    NSLog(@"userIs : %@", self.sharedData.currentUser.userID);

    self.pact.checkIns = [[NSMutableArray alloc]init];

    self.checkIn = [[JDDCheckIn alloc]init];
    NSDate * now = [NSDate date];
    self.checkIn.userID = self.sharedData.currentUser.userID;
    self.checkIn.checkInDate = now;
    
    Firebase *checkinRef = [self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@/checkins",self.pact.pactID]];
    
    Firebase *newCheckin = [checkinRef childByAutoId];
    
    self.checkIn.checkInID = [newCheckin.description stringByReplacingOccurrencesOfString:checkinRef.description withString:@""];
    
    NSMutableDictionary *finalCheckinDictionary = [self.sharedData createDictionaryToSendToFirebaseWithJDDCheckIn:self.checkIn];
    
    [newCheckin setValue:finalCheckinDictionary];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector
         (requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserCheckedInNotificationName object:self.pact];
    
}

//location geo delagates methods.
//=====================================================================================================================
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
        //        [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Error", @"Error")];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location= [locations lastObject];
    self.latitude= self.location.coordinate.latitude;
    self.longitude = self.location.coordinate.longitude;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'hh:mm'"];
    
    NSMutableDictionary *JSQMessageDictionary = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                                 @"senderId" : self.sharedData.currentUser.userID,
                                                                                                 @"senderDisplayName" :self.sharedData.currentUser.displayName,
                                                                                                 @"date" : [dateFormatter stringFromDate:[NSDate date]],
                                                                                                 @"text" : [NSString stringWithFormat:@"%@ just checked in!",self.sharedData.currentUser.displayName]
                                                                                                 
                                                                                                 }];
    
    
    [[[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"chatrooms/%@",self.pact.pactID]] childByAutoId] setValue:JSQMessageDictionary];
    
    NSMutableDictionary * locationDictionary = [[NSMutableDictionary alloc]initWithDictionary: @{
                                                                                                 @"senderId" : self.sharedData.currentUser.userID,
                                                                                                 @"senderDisplayName" :self.sharedData.currentUser.displayName,
                                                                                                 @"date" : [dateFormatter stringFromDate:[NSDate date]],
                                                                                                 @"longitude" :[NSNumber numberWithFloat: self.longitude],
                                                                                                 @"latitude" :[NSNumber numberWithFloat: self.latitude]
                                                                                                 }];
    
    [[[self.sharedData.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"chatrooms/%@",self.pact.pactID]] childByAutoId] setValue:locationDictionary];

    
    [self.locationManager stopUpdatingLocation];

}
//===================================================================================================================

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
 
    NSLog(@"observed changes %@", change);
}


-(void)setPact:(JDDPact *)pact{
    _pact = pact;
    [self setShitUp];
}

-(void)setShitUp {

    // first empty the stackview
    for (UIView *subview in self.stackView.arrangedSubviews){
        [self.stackView removeArrangedSubview:subview];
        
    }
    
    // then for each user, createa a UserDescriptionView and add it to the stackview
    for (JDDUser *user in self.pact.usersToShowInApp){
       
        UserDescriptionView *view1 = [[UserDescriptionView alloc]init];
        
        for (JDDCheckIn *checkin in self.pact.checkIns) {
            
            if ([checkin.userID isEqualToString:user.userID]) {
                
                view1.checkinsCount ++;
            }
        }
        ;
        
        NSString *valueIndicator = [NSString stringWithFormat:@"%@",[self.pact.users valueForKey:user.userID]] ;
        NSString *currentPact = [NSString stringWithFormat:@"%@",self.pact.title];
  
        user.isReady = valueIndicator;
        user.currentPactIn = currentPact;
        view1.borderView.layer.borderWidth = 1.0;
        view1.user = user;
        NSLog(@"Is the view's user ready? %@", view1.user.isReady);
        // same as [view setUser:user];
        [self.stackView addArrangedSubview:view1];
        
        
//        if (self.pact.users.count == 2) {
            [view1.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.33].active = YES;
//        } else {
//        [view1.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.33].active = YES;
//        }
        
        [self.stackView layoutSubviews];//give subviews a size
        view1.clipsToBounds = YES;
        
    }
    
    self.stakesText.text = self.pact.stakes;
    self.pactText.text = self.pact.pactDescription;
    self.checkInLabel.layer.borderWidth = 1;
    self.checkInLabel.layer.cornerRadius = 10;
    
    
    
    
    if (self.pact.twitterPost.length > 0) {
        self.TwitterTitle.text = self.pact.twitterPost;
        self.TwitterTitle.hidden = NO;
        self.twitterText.hidden = NO;

    } else {
        self.TwitterTitle.hidden = YES;
        self.twitterText.hidden = YES;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
            PactDetailViewController *pactVC = segue.destinationViewController;
            pactVC.pact = self.pact;
}



@end
