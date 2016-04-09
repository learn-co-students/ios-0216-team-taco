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
    
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self updateUI];;
}

-(void)setPact:(JDDPact *)pact
{
    _pact = pact;
    [self updateUI];
}

-(void)updateUI;
{
    self.title.text = @"test";//self.pact.title;
    
}


@end
