//
//  UserPactCellView.m
//  Stakes
//
//  Created by Dylan Straughan on 3/31/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "UserPactCellView.h"

@interface UserPactCellView ()

@property (strong, nonatomic) IBOutlet UILabel *name1;
@property (strong, nonatomic) IBOutlet UILabel *name2;
@property (strong, nonatomic) IBOutlet UILabel *name3;
@property (strong, nonatomic) IBOutlet UILabel *pactTitle;
@property (strong, nonatomic) IBOutlet UILabel *pactDetail;
@property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
@property (strong, nonatomic) IBOutlet UILabel *stakesDetail;
@property (strong, nonatomic) IBOutlet UIImageView *name1Image;
@property (strong, nonatomic) IBOutlet UIImageView *name2Image;
@property (strong, nonatomic) IBOutlet UIImageView *name3Image;
@property (strong, nonatomic) IBOutlet UILabel *name1checkIns;
@property (strong, nonatomic) IBOutlet UILabel *name2checkIns;
@property (strong, nonatomic) IBOutlet UILabel *name3checkIns;

@end

@implementation UserPactCellView


//-(instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self commonInit];
//    }
//    return self;
//}
//
//-(instancetype)initWithFrame:(CGRect)frame
//{
//    
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//        [self commonInit];
//    }
//    return self;
//}
//
//-(void)commonInit
//{
//    
//    [[NSBundle mainBundle] loadNibNamed:@"UserPactCellView" owner:self options:nil];
//    
//    [self addSubview:self.contentView];
//    
//    self.contentView.frame = self.bounds;
//    
//    [self setShitUp];
//    
//}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setShitUp];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setPact:(JDDPact *)pact{
    _pact = pact;
    [self setShitUp];
}


-(void)setShitUp {
    
    
    // here we are going to have to create new views programatically and add in users in the pact. (probably with a custom xib) This is a sloppy way of doing it for the MVP to get something on screen
    
//    self.pact = [[JDDPact alloc]init];
    
    for (JDDUser *user in self.pact.users) {
        
        if ([user isEqual:self.pact.users[0]]) {
            
            self.name1.text = user.firstName;
            self.name1Image.image = user.userImage;
            
            for (JDDCheckIn * checkIn in user.checkins) {
                
                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
                
                if ([checkIn.pact isEqual:self.pact]) {
                    
                    [goodCount addObject:checkIn];

                }
                self.name1checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];

            }
        } else if ([user isEqual:self.pact.users[1]]) {
            
            self.name2.text = user.firstName;
            self.name2Image.image = user.userImage;
            
            for (JDDCheckIn * checkIn in user.checkins) {
                
                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
                
                if ([checkIn.pact isEqual:self.pact]) {
                    
                    [goodCount addObject:checkIn];
                    
                }
                self.name2checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];
                
            }
        } else if ([user isEqual:self.pact.users[2]]) {
            
            self.name3.text = user.firstName;
            self.name3Image.image = user.userImage;
            
            for (JDDCheckIn * checkIn in user.checkins) {
                
                NSMutableArray *goodCount = [[NSMutableArray alloc]init];
                
                if ([checkIn.pact isEqual:self.pact]) {
                    
                    [goodCount addObject:checkIn];
                    
                }
                self.name3checkIns.text = [NSString stringWithFormat:@"%lu",goodCount.count];
                
            }
        }
        
        self.pactTitle.text = @"Pact";
        self.pactDetail.text = self.pact.pactDescription;
        self.stakesTitle.text = @"Stakes";
        self.stakesDetail.text = self.pact.stakes;
        
    }
    

    
//    @property (strong, nonatomic) IBOutlet UILabel *name1;
//    @property (strong, nonatomic) IBOutlet UILabel *name2;
//    @property (strong, nonatomic) IBOutlet UILabel *name3;
//    @property (strong, nonatomic) IBOutlet UILabel *pactTitle;
//    @property (strong, nonatomic) IBOutlet UILabel *pactDetail;
//    @property (strong, nonatomic) IBOutlet UILabel *stakesTitle;
//    @property (strong, nonatomic) IBOutlet UILabel *stakesDetail;
//    @property (strong, nonatomic) IBOutlet UIImageView *name1Image;
//    @property (strong, nonatomic) IBOutlet UIImageView *name2Image;
//    @property (strong, nonatomic) IBOutlet UIImageView *name3Image;
//    @property (strong, nonatomic) IBOutlet UILabel *name1checkIns;
//    @property (strong, nonatomic) IBOutlet UILabel *name2checkIns;
//    @property (strong, nonatomic) IBOutlet UILabel *name3checkIns;

    
    
    
    
}

@end
