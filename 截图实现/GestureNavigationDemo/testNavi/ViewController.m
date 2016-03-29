//
//  ViewController.m
//  testNavi
//
//  Created by tianhy on 15/2/5.
//  Copyright (c) 2015年 tianhy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUInteger controllerCount = self.navigationController.viewControllers.count;
    
    if (controllerCount%2 == 0) {
        self.view.backgroundColor = [UIColor redColor];
    } else if (controllerCount%2 == 1) {
        self.view.backgroundColor = [UIColor greenColor];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, 280, [UIScreen mainScreen].bounds.size.width)];
    label.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, 220);
    label.text = [NSString stringWithFormat:@"%lu",self.navigationController.viewControllers.count];
    label.font = [UIFont systemFontOfSize:250];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(50, 340, 220, 50)];
    button.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, 340);
    [button setBackgroundColor:[UIColor blackColor]];
    [button setTitle:@"Push" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.title = [NSString stringWithFormat:@"%lu",self.navigationController.viewControllers.count];
}

#pragma mark - User Interaction -

- (void)pressBtn:(UIButton *)sender
{
    ViewController *vc = [[ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
