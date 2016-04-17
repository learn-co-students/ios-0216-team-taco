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
#import "Constants.h"

@interface PactDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pactTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pactDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinLabel;
@property (weak, nonatomic) IBOutlet UILabel *stakesLabel;
@property (weak, nonatomic) IBOutlet UILabel *shamingLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UIView *scrollview;
@property (weak, nonatomic) IBOutlet UIStackView *stackview;
@property (strong, nonatomic) JDDDataSource *sharedData;
@property (weak, nonatomic) IBOutlet UILabel *twitterShameHeadingLabel;

@end

@implementation PactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharedData = [JDDDataSource sharedDataSource];
    
    // Do any additional setup after loading the view.
    
    // first empty the stackview
    for (UIView *subview in self.stackview.arrangedSubviews){
        [self.stackview removeArrangedSubview:subview];
    }
    
    // then for each user, createa a UserDescriptionView and add it to the stackview
    for (JDDUser *user in self.pact.usersToShowInApp){
        
        UserDescriptionView *view2 = [[UserDescriptionView alloc]init];
        
        for (JDDCheckIn *checkin in self.pact.checkIns) {
            
            if ([checkin.userID isEqualToString:user.userID]) {
                
                view2.checkinsCount ++;
            }
        }
        ;
        NSString *valueIndicator = [NSString stringWithFormat:@"%@",[self.pact.users valueForKey:user.userID]] ;
        
        user.isReady = valueIndicator;
        view2.user = user;
        NSLog(@"Is the view's user ready? %@", view2.user.isReady);
        // same as [view setUser:user];
        [self.stackview addArrangedSubview:view2];
        
        
        
            [view2.widthAnchor constraintEqualToAnchor:self.scrollview.widthAnchor multiplier:0.33].active = YES;
        
        
        [self.stackview layoutSubviews];//give subviews a size
        view2.clipsToBounds = YES;
        
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM'-'dd'-'yyyy'"];
    self.pactTitleLabel.text = self.pact.title;
    self.pactDescriptionLabel.text = [NSString stringWithFormat: @"%@",self.pact.pactDescription];
    
    NSString *createText = [dateFormatter stringFromDate:self.pact.dateOfCreation];
    BOOL worked = createText != nil;
    self.createdLabel.text = worked ? createText : @"Error";
    NSLog(@"checkins %lu and timeinterval %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval);
    self.checkinLabel.text = [NSString stringWithFormat:@"%lu times per %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval];
    self.stakesLabel.text = [NSString stringWithFormat:@"%@", self.pact.stakes];
    if (self.pact.allowsShaming) {
    self.shamingLabel.text = self.pact.twitterPost;
    } else {
        self.twitterShameHeadingLabel.hidden = YES;
        self.shamingLabel.text = @"";
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)deleteButtonTapped:(id)sender
{
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete this pact?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAction];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [deleteAlert addAction:delete];
    [deleteAlert addAction:cancel];

    
    [self presentViewController:deleteAlert animated:YES completion:^{
        //
    }];
}

-(void)deleteAction
{

    [self deleteCurrentUserPactReferenceWithCompletion:^(BOOL done) {
        if (done) {
            [self deleteAllUserPactReferences];
            [self deletePactReferenceWithCompletion:^(BOOL doneWithPact) {
                if (doneWithPact) {
                    
//                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                        
//                        [self dismissViewControllerAnimated:YES completion:nil];
//                        
//                    }];
                    //send notification to VC
                    [[NSNotificationCenter defaultCenter] postNotificationName:UserDeletedPactNotificationName object:self.pact];

                }
            }];
        }
        
    }];
}

-(void)deleteCurrentUserPactReferenceWithCompletion:(void(^)(BOOL))completed {

    [[[[[self.sharedData.firebaseRef childByAppendingPath:@"users"] childByAppendingPath:self.sharedData.currentUser.userID] childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID]removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        completed(YES);
    }];
}
    
-(void)deleteAllUserPactReferences
{
    for (JDDUser *user in self.pact.usersToShowInApp) {
        NSLog(@"ARE WE IN THE LOO{):");
        NSString *userID = user.userID;
        [[[[[self.sharedData.firebaseRef childByAppendingPath:@"users"] childByAppendingPath:userID] childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] removeValue];
    }

}
-(void)deletePactReferenceWithCompletion:(void(^)(BOOL))referenceDeleted {

    [[[self.sharedData.firebaseRef childByAppendingPath:@"pacts"] childByAppendingPath:self.pact.pactID] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        
        NSLog(@"in remove value completionblock");
        referenceDeleted(YES);
    }];

}

- (IBAction)exitTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
