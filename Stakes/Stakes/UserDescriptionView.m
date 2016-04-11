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
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
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
    
    if ([self.user.userImageURL  isEqual: @""]) {
        self.userProfileImage.hidden = YES;
    } else {
    self.userProfileImage.hidden = NO;
        self.intialsLabel.hidden = YES;
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.user.userImageURL]]];
        self.userProfileImage.image = image;
    if (self.userNameLabel.text != nil) {
    self.userNameLabel.text =self.user.displayName;
        self.countOfCheckInsLabel.hidden = YES;
        NSString *name= self.user.displayName;
        
        self.intialsLabel.text = [name substringToIndex:1] ;
        
    } else {
        self.userNameLabel.text = @"";
        self.countOfCheckInsLabel.text = @"";
        self.intialsLabel.text = @"";
    }
    }
}
@end
