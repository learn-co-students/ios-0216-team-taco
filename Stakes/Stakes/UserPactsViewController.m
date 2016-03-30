//
//  UserPactsViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "UserPactsViewController.h"
#import "JDDUser.h"
#import "JDDPact.h"
#import <FZAccordionTableView/FZAccordionTableView.h>
#import "PactAccordionHeaderView.h"

@interface UserPactsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) JDDPact *pactone;
@property (nonatomic, strong) JDDPact *pacttwo;
@property (nonatomic, strong) JDDUser *jeremy;

@end

@implementation UserPactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pactone = [[JDDPact alloc] init];
    self.pactone.title = @"Gym with Boys";
    self.pactone.pactDescription = @"Need to go to gym 3x a week";
    self.pactone.stakes = @"Loser has to buy beer";
    self.pactone.users = [[NSArray alloc]init];
    
    self.pactone.checkInsPerTimeInterval = 3;
    self.pactone.timeInterval = @"week";
    self.pactone.repeating = YES;
    
    self.pactone.allowsShaming = YES;
    self.pactone.twitterPost = @"I didn't go to the gym so I suck";
    
    self.pactone.messages = nil;
    
    self.pacttwo = [[JDDPact alloc] init];
    self.pacttwo.title = @"Get Up Early";
    self.pacttwo.pactDescription = @"Stop Snoozing";
    self.pacttwo.stakes = @"Loser has to buy coffee for next week";
    self.pacttwo.users = [[NSArray alloc]init];
    
    self.pacttwo.checkInsPerTimeInterval = 1;
    self.pacttwo.timeInterval = @"day";
    self.pacttwo.repeating = YES;
    
    self.pacttwo.allowsShaming = YES;
    self.pacttwo.twitterPost = @"I couldn't get out of bed today";
    
    self.pacttwo.messages = nil;

    self.jeremy = [[JDDUser alloc] init];
    self.jeremy.pacts = @[self.pactone, self.pacttwo];
    NSLog(@"PACT COUNT FOR USER %lu", self.jeremy.pacts.count);
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowMultipleSectionsOpen = YES;
    self.tableView.keepOneSectionOpen = NO;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), nil];
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"basicCell"];
//    for (JDDPact *pact in self.jeremy.pacts) {
    
        [self.tableView registerNib:[UINib nibWithNibName:@"PactAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:accordionHeaderReuseIdentifier];
  
//    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 88;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    cell.textLabel.text = @"work you piece of shit";
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.jeremy.pacts.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"IS THIS THE FUCKING TITLE";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
//    return [self tableView:tableView heightForHeaderInSection:section];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:accordionHeaderReuseIdentifier];
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}


@end
