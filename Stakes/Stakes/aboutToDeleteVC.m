//
//  aboutToDeleteVC.m
//  Stakes
//
//  Created by Dylan Straughan on 4/1/16.
//  Copyright © 2016 JDD. All rights reserved.
//

#import "aboutToDeleteVC.h"

@interface aboutToDeleteVC ()

@end

@implementation aboutToDeleteVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = [JDDDataSource sharedDataSource];
    
    [self.dataSource setUpFireBaseRef];

}

- (IBAction)loginWFirebasePressed:(id)sender {
    
    
    [self.dataSource.firebaseRef authAnonymouslyWithCompletionBlock:^(NSError *error, FAuthData *authData) {
        
        if (error != nil) {
            
            NSLog(@"%@", error.description);
            
            
        } else {
            
            [self performSegueWithIdentifier:@"segueFromDeleteVCtoSmackTalkVC" sender:self];
            NSLog(@"%@", authData.description);

        }
        
    }];

    
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
