//
//  PactDetailViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "PactDetailViewController.h"

@interface PactDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stakeLabel;
@property (weak, nonatomic) IBOutlet UITextField *pactDescriptionText;
@property (weak, nonatomic) IBOutlet UITextField *tweeterPost;
@property (weak, nonatomic) IBOutlet UILabel *memberName1;
@property (weak, nonatomic) IBOutlet UILabel *memberName2;
@property (weak, nonatomic) IBOutlet UILabel *memberName3;
@property (weak, nonatomic) IBOutlet UIImageView *memberOneProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *memberTwoProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *memberThreeProfileImage;

@end

@implementation PactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
