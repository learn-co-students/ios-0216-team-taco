//
//  PactAccordionHeaderView.m
//  Stakes
//
//  Created by Jeremy Feld on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "PactAccordionHeaderView.h"
@interface PactAccordionHeaderView ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;


@end


@implementation PactAccordionHeaderView

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
    
//    [[NSBundle mainBundle] loadNibNamed:@"PactAccordionHeaderView" owner:self options:nil];
//    [self addSubview:self.containerView];
    
    
//    self.title = self.subviews[0].subviews[2];
//    
//    [self.containerView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
//    [self.containerView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
//    [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
//    [self.containerView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;

    
}

-(void)awakeFromNib
{
    [super awakeFromNib];
     [self addSubview:self.containerView];
    [self.containerView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [self.containerView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.containerView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
}

-(void)setPact:(JDDPact *)pact
{
    _pact = pact;
    [self updateUI];
}

-(void)updateUI;
{
    self.title.text = self.pact.title;
//set images to user images
}


@end
