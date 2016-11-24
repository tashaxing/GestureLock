//
//  GestureLockViewController.m
//  GestureLock
//
//  Created by yxhe on 16/11/23.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "GestureLockView.h"

const int kRow = 3;          // 每行个数
const int kCol = 3;          // 每列个数

const float kBoardTop = 200; // 手势键盘顶部坐标
const float kDotSize = 50;   // 点的尺寸


@interface GestureLockView ()
{
    NSString *password; // 维持密码
    NSMutableArray<UIBezierPath *> *lineArray; // 连线数组
    UIBezierPath *tempLine; // 临时连线
    NSMutableArray *gestureDotIndexArray; // 存储手势轨迹的关联点索引
    BOOL isStartDotSelected; // 是否有第一个点被选中
    
    CGPoint startPoint, endPoint; // 存储路径起始点和终止点
    
    
    UILabel *tipLabel; // 提示语
}
@end

@implementation GestureLockView

+ (instancetype)sharedLockView
{
    static GestureLockView *instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        instance = [[GestureLockView alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // 全屏尺寸,并且一开始隐藏
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self = [[GestureLockView alloc] initWithFrame:CGRectMake(0, screenSize.height, screenSize.width, screenSize.height)];
        self.backgroundColor = [UIColor whiteColor];
        
        // 初始化数据
        lineArray = [NSMutableArray array];
        gestureDotIndexArray = [NSMutableArray array];
        isStartDotSelected = NO;
        
        // UI搭建
        [self createUI];
    }
    return self;
}

+ (NSString *)getGesturePassword
{
    // 从文件中读
    NSString *passwordStr = [[NSUserDefaults standardUserDefaults] objectForKey:kPasswordKey];
    return passwordStr;
}

+ (void)deletePassword
{
    // 删除对应的key
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 搭建初始UI
- (void)createUI
{
    // 提示语
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 50, 60, 100, 30)];
    tipLabel.text = @"请输入手势";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor redColor];
    [self addSubview:tipLabel];
    
    // 按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.frame.size.width / 2 - 50, 120, 100, 30);
    [button setTitle:@"隐藏手势" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(hide)
     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    // 九宫格点阵，每个点用view替代，用tag设置索引（其实可以设置图片，用数组存起来索引）
    CGFloat dotSpace = (self.frame.size.width - kCol * kDotSize) / (kCol + 1); // 点之间的间距
    
    for (int i = 0; i < kRow; i++)
    {
        for (int j = 0; j < kCol; j++)
        {
            UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(dotSpace + (kDotSize + dotSpace) * j, kBoardTop + dotSpace + (kDotSize + dotSpace) * i, kDotSize, kDotSize)];
            dotView.backgroundColor = [UIColor lightGrayColor]; // 初始颜色
            dotView.tag = (i * kCol + j) + 1000; // 索引
            dotView.layer.cornerRadius = kDotSize / 2; // 切成圆形
            [self addSubview:dotView];
        }
    }
}

- (void)resetGesture
{
    isStartDotSelected = NO;
    tempLine = nil;
    [lineArray removeAllObjects];
    [gestureDotIndexArray removeAllObjects];
    for (int i = 0; i < kRow * kCol; i++)
    {
        UIView *dotView = [self viewWithTag:i + 1000];
        dotView.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma mark - 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 清除之前的轨迹
    [lineArray removeAllObjects];
    
    // 把所有的点状态重置
    [gestureDotIndexArray removeAllObjects];
    for (int i = 0; i < kRow * kCol; i++)
    {
        UIView *dotView = [self viewWithTag:i + 1000];
        
        dotView.userInteractionEnabled = YES;
        dotView.backgroundColor = [UIColor lightGrayColor];
    }
    
    // 获取第一个点
    startPoint = [touches.anyObject locationInView:self];
    
    // 判断如果在某个dot里面就开始记录
    for (int i = 0; i < kRow * kCol; i++)
    {
        UIView *dotView = [self viewWithTag:i + 1000];
        if (CGRectContainsPoint(dotView.frame, startPoint))
        {
            // 第一个点选中了
            isStartDotSelected = YES;
            
            // 如果在里面就标记
            dotView.backgroundColor = [UIColor greenColor];
            dotView.userInteractionEnabled = NO; // 可以用其他的标志字，这里就简单用这个属性好了
            
            // 更改起始点为中心
            startPoint = dotView.center;
            
            // dot添加到轨迹
            [gestureDotIndexArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 终止点
    endPoint = [touches.anyObject locationInView:self];
    
    // 一定在起始点选中的基础上才有轨迹
    if (isStartDotSelected)
    {
        // 临时轨迹
        tempLine = [UIBezierPath bezierPath];
        [tempLine moveToPoint:startPoint];
        [tempLine addLineToPoint:endPoint];
        
        // 判断终点是否在dot里面,并且这个点没有划过
        for (int i = 0; i < kRow * kCol; i++)
        {
            UIView *dotView = [self viewWithTag:i + 1000];
            
            // 必须两个条件一起判保证点不会重入
            if (CGRectContainsPoint(dotView.frame, endPoint) && dotView.userInteractionEnabled)
            {
                // 如果在里面就标记
                dotView.backgroundColor = [UIColor colorWithRed:(arc4random() % 256) / 256.0f
                                                          green:(arc4random() % 256) / 256.0f
                                                           blue:(arc4random() % 256) / 256.0f
                                                          alpha: 1];
                dotView.userInteractionEnabled = NO; // 可以用其他的标志字，这里就简单用这个属性好了
                
                // dot添加到轨迹
                [gestureDotIndexArray addObject:[NSNumber numberWithInt:i]];
                
                // 重新规划路径
                
                UIBezierPath *settledLine = [[UIBezierPath alloc] init];
                [settledLine moveToPoint:startPoint];
                [settledLine addLineToPoint:dotView.center];
                
                // 存储路径
                [lineArray addObject:settledLine];
                
                // 此处判断一下线路是否相交
                
                
                // 修改起始点
                startPoint = dotView.center;
            }
        }
    }
    // 重绘
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    // 得到密码,并存到文件（或者用全局变量什么的也行）
    NSMutableString *passwordStr = [[NSMutableString alloc] init];
    for (NSNumber *indexNumber in gestureDotIndexArray)
    {
        [passwordStr appendString:[NSString stringWithFormat:@"%d", indexNumber.intValue]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:passwordStr forKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.passwordSetBlock)
    {
        self.passwordSetBlock(passwordStr);
    }
    
    // 最后清除存储的密码轨迹
    [self resetGesture];
    
    // 重绘
    [self setNeedsDisplay];
    
}

#pragma mark - 绘制
- (void)drawRect:(CGRect)rect
{
    // 绘制临时路径
    
    tempLine.lineWidth = 5;
    tempLine.lineJoinStyle = kCGLineJoinRound;
    [[UIColor redColor] set];
    [tempLine stroke];
    
    // 绘制轨迹
    for (UIBezierPath *path in lineArray)
    {
        path.lineWidth = 5;
        path.lineJoinStyle = kCGLineJoinRound;
        [[UIColor blueColor] set];
        [path stroke];
    }
}

#pragma mark - 抖动动画
- (void)shakeAnimationForView:(UIView *)view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}

#pragma mark - show和hide
- (void)showInView:(UIView *)parentView
{
    [parentView addSubview:self];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    } completion:^(BOOL finished) {
    }];
    
}

- (void)hide
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



@end
