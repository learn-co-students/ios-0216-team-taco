//
//  UserPactDetailView.m
//  Stakes
//
//  Created by Dylan Straughan on 4/15/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "UserPactDetailView.h"

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
    
    NSLog(@"commonInit called in UserPactMainView.");
    
    [[NSBundle mainBundle] loadNibNamed:@"UserPactDetailView" owner:self options:nil];
    
    [self addSubview:self.contentView];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
}


@end
