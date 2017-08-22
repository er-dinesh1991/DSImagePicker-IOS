//
//  ViewController.m
//  DSImagePicker
//
//  Created by Dinesh Saini on 8/22/17.
//  Copyright © 2017 Dinesh Saini. All rights reserved.
//

#import "ViewController.h"
#import "DSImagePicker.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showImagePicker:(id)sender{
    [[DSImagePicker shared] imagePickerInViewController:self allowEditing:YES WithSuccess:^(UIImage *image) {
        
    } failure:^(NSError *error) {
        
    }];
}

@end
