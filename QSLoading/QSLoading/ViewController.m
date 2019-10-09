//
//  ViewController.m
//  QSLoading
//
//  Created by wuqiushan on 2019/10/8.
//  Copyright © 2019 wuqiushan3@163.com. All rights reserved.
//

#import "ViewController.h"
#import "QSLoading.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QSLoading showTitle:@"加载中..." duration:10.0 didDismiss:^{
        NSLog(@"消失回调");
    }];
    
//    [self performSelector:@selector(delayAction) withObject:nil afterDelay:3];
}

- (void)delayAction {
    
    NSLog(@"时间到");
    [QSLoading dismiss];
}


@end
