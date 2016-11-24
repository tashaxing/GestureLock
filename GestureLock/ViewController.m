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
    
    // 设置手势解锁的回调
    [GestureLockView sharedLockView].passwordSetBlock = ^(NSString *password){
        NSLog(@"%@", password);
    };
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
    [GestureLockView deletePassword];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
