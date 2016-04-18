
//  UserPactDetailView.m
//  Stakes
//
//  Created by Dylan Straughan on 4/15/16.
//  Copyright © 2016 JDD. All rights reserved.

#import <BALoadingView/BALoadingView.h>

#import "UserPactDetailView.h"
#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDCheckIn.h"
#import "UserDescriptionView.h"
#import "Constants.h"



@interface UserPactDetailView ()

@property (strong, nonatomic) IBOutlet UserPactDetailView *contentView;
@property (strong, nonatomic) IBOutlet UIStackView *stackView;
@property (strong, nonatomic) IBOutlet UILabel *createdTitle;
@property (strong, nonatomic) IBOutlet UILabel *createdLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkInsTitle;
@property (strong, nonatomic) IBOutlet UILabel *checkInsPerWeekLabel;
@property (strong, nonatomic) IBOutlet UIButton *deletePactButton;
@property (strong, nonatomic) JDDDataSource *sharedData;
@property (strong, nonatomic) IBOutlet BALoadingView *loadingView;
@property(assign,nonatomic) BACircleAnimation animationType;
@property(assign,nonatomic) bool firstLoad;
@end

@implementation UserPactDetailView

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
    
    NSLog(@"commonInit called in UserPactDetailView.");
    
    [[NSBundle mainBundle] loadNibNamed:@"UserPactDetailView" owner:self options:nil];
    
    [self addSubview:self.contentView];
    
    self.pact = self.sharedData.currentPact;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.sharedData = [JDDDataSource sharedDataSource];
    
    self.pact = self.sharedData.currentPact;
    
    self.firstLoad = YES;
    self.loadingView.hidden = YES;
    
    if (self.firstLoad) {
        [self.loadingView initialize];
        self.loadingView.lineCap = kCALineCapRound;
        self.loadingView.clockwise = true;
        self.loadingView.segmentColor = [UIColor blackColor];
        self.firstLoad = NO;
    }
    
    // Do any additional setup after loading the view.
    
    // first empty the stackview
    for (UIView *subview in self.stackView.arrangedSubviews){
        [self.stackView removeArrangedSubview:subview];
    }
    
    // then for each user, createa a UserDescriptionView and add it to the stackview
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM'-'dd'-'yyyy'"];
    
    NSString *createText = [dateFormatter stringFromDate:self.pact.dateOfCreation];
    BOOL worked = createText != nil;
    self.createdLabel.text = worked ? createText : @"Error";
    NSLog(@"checkins %lu and timeinterval %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval);
    self.checkInsPerWeekLabel.text = [NSString stringWithFormat:@"%lu times per %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval];

}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)deleteButtonTapped:(id)sender
{
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete this pact?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.loadingView startAnimation:BACircleAnimationFullCircle];
        
        [self deleteAction];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [deleteAlert addAction:delete];
    [deleteAlert addAction:cancel];
    
    
//    [self presentViewController:deleteAlert animated:YES completion:^{
//        
//    }];
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
                    [self.loadingView stopAnimation];
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



@end
