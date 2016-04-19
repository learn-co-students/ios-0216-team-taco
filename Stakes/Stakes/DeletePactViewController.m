//
//  DeletePactViewController.m
//  Stakes
//
//  Created by Jeremy Feld on 4/19/16.
//  Copyright © 2016 JDD. All rights reserved.
//
#import <BALoadingView/BALoadingView.h>
#import "DeletePactViewController.h"
#import "Constants.h"

@interface DeletePactViewController ()
@property (weak, nonatomic) IBOutlet BALoadingView *loadingView;
@property(assign,nonatomic) BACircleAnimation animationType;

@end

@implementation DeletePactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.loadingView initialize];
    self.loadingView.lineCap = kCALineCapRound;
    self.loadingView.clockwise = true;
    self.loadingView.segmentColor = [UIColor whiteColor];
    
    [self.loadingView startAnimation:BACircleAnimationFullCircle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeleteCompleted:) name:PactDeletedNotificationName object:nil];
    //if done, wait a second,
    // [self dismissViewControllerAnimated:YES completion:nil];\



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleDeleteCompleted:(NSNotification *)notification
{
    UIAlertController *givingUp = [UIAlertController alertControllerWithTitle:@"I hope you're deleting this to make more pacts..." message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [givingUp addAction:noAction];
    [givingUp addAction:yesAction];
    
    [self presentViewController:givingUp animated:YES completion:nil];
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
