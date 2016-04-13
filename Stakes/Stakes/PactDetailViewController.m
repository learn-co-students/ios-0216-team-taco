//
//  PactDetailViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "PactDetailViewController.h"
#import "UserDescriptionView.h"
#import "JDDCheckIn.h"
#import "JDDDataSource.h"

@interface PactDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pactTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pactDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *stakesLabel;
@property (weak, nonatomic) IBOutlet UILabel *shamingLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UIView *scrollview;
@property (weak, nonatomic) IBOutlet UIStackView *stackview;
@property (strong, nonatomic) JDDDataSource *sharedData;


@end

@implementation PactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (UIView *subview in self.stackview.arrangedSubviews){
        [self.stackview removeArrangedSubview:subview];
    }
    NSLog(@"users to show count, %@", self.pact.usersToShowInApp);
    NSLog(@"users count, %@", self.pact.users);

    // then for each user, createa a UserDescriptionView and add it to the stackview
    for (JDDUser *user in self.pact.usersToShowInApp){
        
        UserDescriptionView *view = [[UserDescriptionView alloc]init];
        
        for (JDDCheckIn *checkin in self.pact.checkIns) {
            
            if ([checkin.userID isEqualToString:user.userID]) {
                
                view.checkinsCount ++;
            }
        }
        
        view.user = user;
        
        // same as [view setUser:user];
        [self.stackview addArrangedSubview:view];
        
        [view.widthAnchor constraintEqualToAnchor:self.scrollview.widthAnchor multiplier:0.5].active = YES;
        [self.stackview layoutSubviews];//give subviews a size
        view.clipsToBounds = YES;
        
    }
    self.pactTitleLabel.text = self.pact.title;
    self.pactDescriptionLabel.text = self.pact.pactDescription;
    self.checkinFrequencyLabel.text = [NSString stringWithFormat:@"%lu", self.pact.checkInsPerTimeInterval];
    self.checkinStringLabel.text = self.pact.timeInterval;
    self.stakesLabel.text = self.pact.stakes;
//    self.shamingLabel.text = self.pact.allowsShaming;
}


- (IBAction)deleteButtonTapped:(id)sender
{
//    self.sharedData = [JDDDataSource sharedDataSource];
//    
//        NSLog(@"trying to send a tweet");
//        NSString *tweet = self.pact.title;
//        [self.sharedData.twitter postStatusUpdate:tweet
//                                inReplyToStatusID:nil
//                                         latitude:nil
//                                        longitude:nil
//                                          placeID:nil
//                               displayCoordinates:nil
//                                         trimUser:nil
//                                     successBlock:^(NSDictionary *status) {
//                                         NSLog(@"SUCCESSFUL TWEET");
//                                     } errorBlock:^(NSError *error) {
//                                         NSLog(@"THERE WAS AN ERROR TWEETING");
//                                         NSString *message = [NSString stringWithFormat:@"You didn't really want to send that, did you? There was an error sending your Tweet: %@", error.localizedDescription];
//                                         NSLog(@"ERROR TWEETING: %@", error.localizedDescription);
//                                     }];
//    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
