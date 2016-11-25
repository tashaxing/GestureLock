//
//  GestureLockViewController.h
//  GestureLock
//
//  Created by yxhe on 16/11/23.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPasswordKey @"passwordStr"

typedef enum GestureState
{
    CREATE_STATE, // 创建状态
    VERIFY_STATE  // 校验状态
}GestureState;

typedef void (^PasswordSetBlock)(NSString *);

@interface GestureLockView : UIView

// 单例
+ (instancetype)sharedLockView;
// 出现
- (void)showInView:(UIView *)parentView;
// 消失
- (void)hide;

@property (nonatomic, strong) PasswordSetBlock passwordSetBlock; // 设置密码成功回调
@property (nonatomic, assign) GestureState gestureState;

// 获取密码
+ (NSString *)getGesturePassword;
// 删除密码
+ (void)deletePassword;

@end
