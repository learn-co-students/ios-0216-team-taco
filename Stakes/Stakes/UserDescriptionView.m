//
//  UserDescriptionView.m
//  Stakes
//
//  Created by Dimitry Knyajanski on 4/6/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "UserDescriptionView.h"
#import <Masonry/Masonry.h>
#import "JDDDataSource.h"

@interface UserDescriptionView ()

@property (strong, nonatomic) IBOutlet UserDescriptionView *contentView;

@property (strong, nonatomic) JDDDataSource *sharedData;


@end


@implementation UserDescriptionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
    
}


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
    
    [[NSBundle mainBundle] loadNibNamed:@"UserDescriptionView" owner:self options:nil];
    
    [self addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
        
    }];
    
}


-(void)setUser:(JDDUser *)user
{
    _user =user;
    [self updateUI];
    
}

-(void)updateUI
{
    self.indicatorLabel.layer.cornerRadius = self.indicatorLabel.frame.size.width/2;
    self.indicatorLabel.text = @"";
     NSString *Boolian = (NSString*)self.user.isReady;
    
    
        
    
        if ([Boolian isEqual:@"1"]) {
            self.indicatorLabel.backgroundColor = [UIColor greenColor];
        } else {
            self.indicatorLabel.backgroundColor = [UIColor redColor];
        }

    
    
    
    self.userNameLabel.text =self.user.displayName;
    
        self.intialsLabel.text = [self.user.displayName substringToIndex:1] ;
    NSLog(@"countOfCheckIns called!!!! - %lu", (unsigned long)self.checkinsCount);
    
    self.countOfCheckInsLabel.text = [NSString stringWithFormat:@"%li",self.checkinsCount];
    
}
@end
