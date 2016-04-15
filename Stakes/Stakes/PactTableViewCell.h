//
//  PactTableViewCell.h
//  Stakes
//
//  Created by Dylan Straughan on 4/14/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDDPact.h"

@interface PactTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIStackView *stackView;

@property (nonatomic, strong)JDDPact * pact;


@end
