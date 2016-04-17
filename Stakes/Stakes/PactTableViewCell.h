//
//  PactTableViewCell.h
//  Stakes
//
//  Created by Dylan Straughan on 4/14/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDDPact.h"
#import "JDDDataSource.h"

@class PactTableViewCell;

@protocol PactTableViewCellDelegate <NSObject>

@optional
-(void)pactTableViewCell: (PactTableViewCell *)pactTableViewCell shouldSegueToSmackTalkVC: (BOOL)shouldSegueToSmacktalkVC;

@end

@interface PactTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, weak) id <PactTableViewCellDelegate> delegate;
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIStackView *stackView;
@property (nonatomic,strong) JDDDataSource *sharedData;

@property (nonatomic, strong)JDDPact * pact;


@end
