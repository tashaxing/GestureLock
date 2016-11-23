//
//  GestureLockViewController.h
//  GestureLock
//
//  Created by yxhe on 16/11/23.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GestureLockView : UIView

// 单例
+ (instancetype)sharedLockView;
// 出现
- (void)showInView:(UIView *)parentView;
// 消失
- (void)hide;
// 获取密码
+ (NSString *)getPassword;
// 删除密码
+ (void)deletePassword;

@end
