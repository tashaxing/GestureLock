//
//  GestureLockViewController.m
//  GestureLock
//
//  Created by yxhe on 16/11/23.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import "GestureLockView.h"

const int kRow = 3;          // 每行个数
const int kCol = 3;          // 每列个数

const float kBoardTop = 150; // 手势键盘顶部坐标
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
    }
    return self;
}

+ (NSString *)getPassword
{
    // 从文件中读
    return nil;
}

+ (void)deletePassword
{
    
}

#pragma mark - 搭建UI
- (void)layoutSubviews
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
        
        // 判断终点是否在dot里面
        for (int i = 0; i < kRow * kCol; i++)
        {
            UIView *dotView = [self viewWithTag:i + 1000];
            if (CGRectContainsPoint(dotView.frame, startPoint))
            {
                // 如果在里面就标记
                dotView.backgroundColor = [UIColor greenColor];
                dotView.userInteractionEnabled = NO; // 可以用其他的标志字，这里就简单用这个属性好了
                
                // dot添加到轨迹
                [gestureDotIndexArray addObject:[NSNumber numberWithInt:i]];
                
                // 重新规划路径
                [tempLine addLineToPoint:dotView.center];
                
                // 存储路径
                [lineArray addObject:tempLine];
                
                // 修改起始点
                startPoint = dotView.center;
            }
        }
        
        // 重绘
        [self setNeedsLayout];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - 绘制
- (void)drawRect:(CGRect)rect
{
    // 绘制临时路径
    tempLine.lineWidth = 5;
    [[UIColor yellowColor] set];
    [tempLine stroke];
    
    // 绘制轨迹
    for (UIBezierPath *path in lineArray)
    {
        path.lineWidth = 5;
        [[UIColor redColor] set];
        [path stroke];
    }
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
