//
//  ViewController.m
//  GestureLock
//
//  Created by yxhe on 16/11/23.
//  Copyright © 2016年 tashaxing. All rights reserved.
//
// ---- 手势解锁 ---- //

#import "ViewController.h"
#import "GestureLockView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

// 创建手势
- (IBAction)createBtn:(id)sender
{
    // 显示
    [[GestureLockView sharedLockView] showInView:self.view];
}

// 验证手势
- (IBAction)verifyBtn:(id)sender
{
    
}

// 删除手势
- (IBAction)deleteBtn:(id)sender
{
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
