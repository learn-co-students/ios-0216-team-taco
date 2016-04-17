//
//  PactTableViewCell.m
//  Stakes
//
//  Created by Dylan Straughan on 4/14/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "PactTableViewCell.h"
#import "UserPactMainView.h"

@implementation PactTableViewCell


- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self createScrollView];
    
    [self createStackView];
    
    self.scrollView.delegate = self;
    
    [self.scrollView layoutIfNeeded];
    
    [self createMainPactViewAtIndex:0 withPact:self.pact inStackView:self.stackView];
    
    [self createPactDetailViewAtIndex:1 withPact:self.pact inStackView:self.stackView];
    
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
    [self.scrollView.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor].active = YES;
    
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    
    [self.scrollView setContentOffset:CGPointMake(self.contentView.frame.size.width,0) animated:YES];
    
}

-(void)createStackView {
    
    self.stackView = [[UIStackView alloc]init];
    [self.scrollView addSubview:self.stackView];
    
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.stackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
    [self.stackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor].active = YES;
    [self.stackView.leftAnchor constraintEqualToAnchor:self.scrollView.leftAnchor].active = YES;
    [self.stackView.rightAnchor constraintEqualToAnchor:self.scrollView.rightAnchor].active = YES;
    [self.stackView.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor].active = YES;
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    self.stackView.alignment = UIStackViewAlignmentFill;
}


-(void)createMainPactViewAtIndex:(NSUInteger)index withPact:(JDDPact *)pact inStackView:(UIStackView *)stackView{
    
    UserPactMainView * view = [[UserPactMainView alloc]initWithFrame:CGRectZero];
    
    view.pact = [[JDDPact alloc]init];
    view.pact = pact;
    [stackView addArrangedSubview:view];
    
    view.backgroundColor = [UIColor blueColor];
    
    
    [view.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;
    
}

-(void)createPactDetailViewAtIndex:(NSUInteger)index withPact:(JDDPact *)pact inStackView:(UIStackView *)stackView{
    
    UIView *view = [[UIView alloc]init];
    [stackView insertArrangedSubview:view atIndex:index];
    
    view.backgroundColor = [UIColor redColor];
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    BOOL didSwipeToCertainPoint = NO;
    if (scrollView.contentOffset.x < - (self.contentView.frame.size.width/6)) {
        
        didSwipeToCertainPoint = YES;
        
        [self.delegate pactTableViewCell:self shouldSegueToSmackTalkVC:didSwipeToCertainPoint];
    }
}

-(void)createLabel{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
