//
//  PactAccordionHeaderView.h
//  Stakes
//
//  Created by Jeremy Feld on 3/30/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FZAccordionTableView/FZAccordionTableView.h>
#import "JDDPact.h"
#import "JDDDataSource.h"

static NSString *const accordionHeaderReuseIdentifier = @"AccordionHeaderViewReuseIdentifier";

@interface PactAccordionHeaderView : FZAccordionTableViewHeaderView
@property (nonatomic, strong) JDDPact *pact;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
