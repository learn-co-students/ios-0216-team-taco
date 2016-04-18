
//  UserPactDetailView.m
//  Stakes
//
//  Created by Dylan Straughan on 4/15/16.
//  Copyright © 2016 JDD. All rights reserved.


#import "UserPactDetailView.h"
#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDCheckIn.h"
#import "UserDescriptionView.h"
#import "Constants.h"


@interface UserPactDetailView ()

@property (strong, nonatomic) IBOutlet UserPactDetailView *contentView;
@property (strong, nonatomic) IBOutlet UIView *scrollViewView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIStackView *stackView;
@property (strong, nonatomic) IBOutlet UILabel *pactTitle;
@property (strong, nonatomic) IBOutlet UILabel *pactDescription;
@property (strong, nonatomic) IBOutlet UILabel *createdTitle;
@property (strong, nonatomic) IBOutlet UILabel *createdLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkInsTitle;
@property (strong, nonatomic) IBOutlet UILabel *checkInsPerWeekLabel;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesDescription;
@property (strong, nonatomic) IBOutlet UILabel *TwitterShameTitle;
@property (strong, nonatomic) IBOutlet UILabel *twitterShame;
@property (strong, nonatomic) IBOutlet UIButton *deletePactButton;
@property (strong, nonatomic) JDDDataSource *sharedData;

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
    // Do any additional setup after loading the view.
    
    // first empty the stackview
    for (UIView *subview in self.stackView.arrangedSubviews){
        [self.stackView removeArrangedSubview:subview];
    }
    
    // then for each user, createa a UserDescriptionView and add it to the stackview
    for (JDDUser *user in self.pact.usersToShowInApp){
        
        UserDescriptionView *view = [[UserDescriptionView alloc]init];
        
        for (JDDCheckIn *checkin in self.pact.checkIns) {
            
            if ([checkin.userID isEqualToString:user.userID]) {
                
                view.checkinsCount ++;
            }
        }
        ;
        NSString *valueIndicator = [NSString stringWithFormat:@"%@",[self.pact.users valueForKey:user.userID]] ;
        
        user.isReady = valueIndicator;
        view.user = user;
        NSLog(@"Is the view's user ready? %@", view.user.isReady);
        // same as [view setUser:user];
        [self.stackView addArrangedSubview:view];
        
        
        
        [view.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.33].active = YES;
        
        
        [self.stackView layoutSubviews];//give subviews a size
        view.clipsToBounds = YES;
        
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM'-'dd'-'yyyy'"];
    self.pactTitle.text = self.pact.title;
    self.pactDescription.text = [NSString stringWithFormat: @"%@",self.pact.pactDescription];
    
    NSString *createText = [dateFormatter stringFromDate:self.pact.dateOfCreation];
    BOOL worked = createText != nil;
    self.createdLabel.text = worked ? createText : @"Error";
    NSLog(@"checkins %lu and timeinterval %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval);
    self.checkInsPerWeekLabel.text = [NSString stringWithFormat:@"%lu times per %@", self.pact.checkInsPerTimeInterval, self.pact.timeInterval];
    self.stakesDescription.text = [NSString stringWithFormat:@"%@", self.pact.stakes];
    if (self.pact.allowsShaming) {
        self.twitterShame.text = self.pact.twitterPost;
    } else {
        self.TwitterShameTitle.hidden = YES;
        self.twitterShame.text = @"";
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
    
    
//    [self presentViewController:deleteAlert animated:YES completion:^{
        //
//    }]; going to need to build custom delegate here.
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



@end
