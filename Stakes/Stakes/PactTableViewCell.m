//
//  PactTableViewCell.m
//  Stakes
//
//  Created by Dylan Straughan on 4/14/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "PactTableViewCell.h"
#import "UserPactMainView.h"
#import "UserPactDetailView.h"
#import "JDDDataSource.h"

@interface PactTableViewCell ()

@property (nonatomic, strong)NSLayoutConstraint *messageShapeTrailingAnchor;
@property (nonatomic, strong)NSLayoutConstraint *messageShapeHeightAnchor;
@property (nonatomic, strong)UIImageView *messageImageView;

@end


@implementation PactTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSLog(@"PactTableViewCell awakeFromNib called!");
    
    self.sharedData = [JDDDataSource sharedDataSource];

    [self createScrollView];
    self.scrollView.delegate = self;
    
    [self.scrollView layoutIfNeeded];

    //    self.pact = self.sharedData.currentPact;
    [self createView];
    
    //    [self createMainPactViewAtIndex:0 withPact:self.sharedData.currentPact inStackView:self.stackView];
    //    [self createPactDetailViewAtIndex:1 withPact:self.sharedData.currentPact inStackView:self.stackView];
    
    
    
    //    [[NSBundle mainBundle] loadNibNamed:@"PactTableViewCell" owner:self options:nil];
    //
    //    [self addSubview:self.viewOfContent];

    
}

-(void)setPact:(JDDPact *)pact {
    [self createStackView];

    _pact = pact;
   
    for (UIView *subviews in self.stackView.arrangedSubviews) {
        [subviews removeFromSuperview];
    }
    
    [self createMainPactViewAtIndex:0 withPact:pact inStackView:self.stackView];
    [self createPactDetailViewAtIndex:1 withPact:pact inStackView:self.stackView];
    
}

-(void)createScrollView {
    
    self.scrollView = [[UIScrollView alloc]init];
    
    [self.contentView addSubview:self.scrollView];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor
     ].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;

    
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    
    [self.scrollView setContentOffset:CGPointMake(self.contentView.frame.size.width,0) animated:YES];
    
}

-(void)createStackView {
    
    self.stackView = [[UIStackView alloc]init];
    [self.scrollView addSubview:self.stackView];
    
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.sharedData.currentUser.pacts.count == 0 || [self.sharedData.currentUser.pacts isEqual:nil]) {
        [self.stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    } else {
        [self.stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:-22].active = YES;
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-20].active = YES;
    }
    
    
    [self.stackView.leftAnchor constraintEqualToAnchor:self.scrollView.leftAnchor].active = YES;
    [self.stackView.rightAnchor constraintEqualToAnchor:self.scrollView.rightAnchor].active = YES;
    
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    self.stackView.alignment = UIStackViewAlignmentFill;
}


-(void)createMainPactViewAtIndex:(NSUInteger)index withPact:(JDDPact *)pact inStackView:(UIStackView *)stackView{
    
    UserPactMainView * view = [[UserPactMainView alloc]initWithFrame:CGRectZero];
    
    [stackView addArrangedSubview:view];
    if ([pact.title isEqualToString:@"Tap On Me :)"]) {
        view.checkInButton.hidden = YES;
        view.checkInLabel.hidden =YES;
        view.stakesText.numberOfLines = 3;
        view.pactText.numberOfLines = 3;
        view.twitterText.numberOfLines = 3;
        view.viewForScrollView.hidden = YES;
        view.stackView.hidden = YES;
        view.scrollView.hidden = YES;
        view.CheckInButtonView.hidden = YES;
        
        [view.textView.topAnchor constraintEqualToAnchor:view.contentView.topAnchor].active = YES;
        [view.textView.bottomAnchor constraintEqualToAnchor:view.contentView.bottomAnchor].active = YES;
        
        
       
        
        view.pact = pact;

    } else {
        view.pact = pact;

    }

    //    view.pact = self.sharedData.currentPact;
    
    [view.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;
    //    [view.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor].active = YES;

    
}

-(void)createPactDetailViewAtIndex:(NSUInteger)index withPact:(JDDPact *)pact inStackView:(UIStackView *)stackView{
    
    UserPactDetailView *view = [[UserPactDetailView alloc]initWithFrame:CGRectZero];
    view.pact = pact;
    //    view.pact = self.sharedData.currentPact;

    [stackView insertArrangedSubview:view atIndex:index];
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    BOOL didSwipeToCertainPoint = NO;
    
    self.messageShapeTrailingAnchor.constant = -(scrollView.contentOffset.x *2)-(self.contentView.frame.size.width/3.3);
    self.messageImageView.alpha = -(scrollView.contentOffset.x)/(self.contentView.frame.size.width/4);
    
    
    
    NSLog(@"alpha is %f", self.messageImageView.alpha);
    
    if (scrollView.contentOffset.x < - (self.contentView.frame.size.width/4)) {
        
        didSwipeToCertainPoint = YES;
        
        [self.delegate pactTableViewCell:self shouldSegueToSmackTalkVC:didSwipeToCertainPoint];
    }
}

-(void)createView{
    
    UIImage *messageImage = [UIImage imageNamed:@"MessageShape"];
    self.messageImageView = [[UIImageView alloc]initWithImage:messageImage];
    self.messageImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.messageImageView];
    
    self.messageImageView.alpha =0.0001;
    
    self.messageImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.messageImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    self.messageShapeHeightAnchor = [self.messageImageView.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor multiplier:.1];
    self.messageShapeHeightAnchor.active = YES;
    [self.messageImageView.widthAnchor constraintEqualToAnchor:self.contentView.heightAnchor multiplier:.1].active = YES;
    self.messageShapeTrailingAnchor  = [self.messageImageView.trailingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor];
    self.messageShapeTrailingAnchor.active = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
