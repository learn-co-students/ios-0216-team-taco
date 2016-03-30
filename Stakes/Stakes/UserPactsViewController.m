//
//  UserPactsViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "UserPactsViewController.h"
#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDPact.h"


@interface UserPactsViewController ()

@end

@implementation UserPactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JDDDataSource *dataSource = [JDDDataSource sharedDataSource];
    
    [dataSource generateFakeData];
    
    NSLog(@"%@",dataSource.users);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
