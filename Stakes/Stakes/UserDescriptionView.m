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

@property (weak, nonatomic) IBOutlet UILabel *countOfCheckInsLabel;
@property (weak, nonatomic) IBOutlet UILabel *intialsLabel;
@property (strong, nonatomic) JDDDataSource *sharedData;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImage;


@end


@implementation UserDescriptionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        [self commonInit];
//    }
//    return self;
//    
//}


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
    self.indicatorImage.hidden = YES;
//    self.indicatorImage.image = [self.indicatorImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.indicatorImage setTintColor:[UIColor redColor]];
    
    self.userNameLabel.text =self.user.displayName;
    
    
        self.intialsLabel.text = [self.user.displayName substringToIndex:1] ;
        
    self.countOfCheckInsLabel.text = [NSString stringWithFormat:@"%li",self.checkinsCount];
    
    [self.intialsLabel sizeToFit];
    [self.intialsLabel setFont: [self.intialsLabel.font fontWithSize: 50]];
    self.intialsLabel.layer.cornerRadius = self.intialsLabel.frame.size.width/2;
    self.intialsLabel.layer.borderWidth = 2;
    [self.intialsLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    
    [self.intialsLabel.layer setShadowRadius:3.0];
    [self.intialsLabel.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}
@end
