//
//  PactAccordionHeaderView.m
//  Stakes
//
//  Created by Jeremy Feld on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "PactAccordionHeaderView.h"
@interface PactAccordionHeaderView ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
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
    [[NSBundle mainBundle] loadNibNamed:@"PactAccordionHeaderView" owner:self options:nil];
    [self addSubview:self.contentView];
    
    [self.contentView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [self.contentView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;\
    [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    
}

-(void)setAccordionHeader:(JDDPact *)pact
{
    _pact = pact;
    [self updateUI];
}

-(void)updateUI;
{
    self.title.text = self.pact.title;
    self.rightImage.text = [NSString stringWithFormat:@"High: %.1fF", self.dailyForecast.temperatureMax];
    self.leftImage.text = self.pact.use
}


@end
