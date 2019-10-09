//
//  QSLoading.m
//  QSLoading
//
//  Created by wuqiushan on 2019/10/8.
//  Copyright © 2019 wuqiushan3@163.com. All rights reserved.
//  说明：
//  1.此loading是加载在一个全新的window容器里
//  2.动画包含两部，容器视图动画 和 图片动画
//  3.容器视图动画，在出现和消失时各有一个动画
//  4.为方便调用，仅开放类方法


#import "QSLoading.h"

#pragma mark === 引用循环
#define IOSWeakSelf    __weak __typeof(self)weakSelf = self;
#define IOSStrongSelf  __strong __typeof(weakSelf)strongSelf = weakSelf;

@interface QSLoading()<CAAnimationDelegate>

/** 单独创建一个window窗口 作用所有视图的根容器 */
@property (nonatomic, nullable, strong) UIWindow *window;

/** 所有视图都加载到此控制器下面 */
@property (nonatomic, nullable, strong) UIViewController *viewController;

/** 遮盖图，相显示该内容时，把底层视图遮挡住，触摸此视图时，关闭整个window窗口 */
@property (nonatomic, nullable, strong) UIView *shadeView;

/** 把要显示的内容视图直接加载在此容器上 */
@property (nonatomic, nullable, strong) UIView *containerView;

/** loading圈视图 */
@property (nonatomic, nullable, strong) UIImageView *iconImgView;

/** loading圈视图 */
@property (nonatomic, nullable, strong) UILabel *titleLabel;

/** 容器视图动画类型记录 */
@property (nonatomic, assign) LoadingContainerAnimateType animateType;

/** loading消失block回调 */
@property (nonatomic, copy) didDismiss didDismissBlock;

@end

@implementation QSLoading

#pragma mark - 对外公开方法
/**
 不带视图消失事件的loading圈
 
 @param title loading标题
 @param duration loading时长
 */
+ (void)showTitle:(NSString *)title duration:(double)duration {
    
    [QSLoading shared].titleLabel.text = title != nil ? title : @"loading...";
    [[QSLoading shared] loadingStart:duration];
}

/**
 带视图消失事件的loading圈

 @param title loading标题
 @param duration loading时长
 @param didDismissBlock loading消失回调
 */
+ (void)showTitle:(NSString *)title duration:(double)duration didDismiss:(didDismiss)didDismissBlock {
    
    [QSLoading shared].didDismissBlock = didDismissBlock;
    [QSLoading shared].titleLabel.text = title != nil ? title : @"loading...";
    [[QSLoading shared] loadingStart:duration];
}

/**
 关闭loading圈
 */
+ (void)dismiss {
    [[QSLoading shared] loadingEnd];
}


#pragma mark - 单例

static QSLoading *qsLoading = nil;
static dispatch_once_t onceToken;

+ (QSLoading *)shared {
    
    dispatch_once(&onceToken, ^{
        if(qsLoading == nil) {
            qsLoading = [[QSLoading alloc] init];
        }
    });
    return qsLoading;
}

- (void)shareDealloc {
    onceToken = 0;
    qsLoading = nil;
}

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // 遮盖图面
    [self shadeViewWithType:LoadingShadeBackgroundTypeSolid];
    
    CGFloat kPadding = 17;
    CGRect currentViewRect = CGRectMake(0, 0, 100, 100);
    CGRect viewRect = CGRectInset(currentViewRect, -kPadding, -kPadding);
    
    viewRect.origin.x = round(CGRectGetMidX(self.window.frame) - CGRectGetMidX(currentViewRect) - kPadding);
    viewRect.origin.y = round(CGRectGetMidY(self.window.frame) - CGRectGetMidY(currentViewRect) - kPadding);
    
    self.containerView.frame = viewRect;
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 5.0f;
    [self.viewController.view addSubview:self.containerView];
    
    self.iconImgView.frame = (CGRect){kPadding + 25, kPadding + 10, CGSizeMake(50, 50)};
    self.titleLabel.frame = (CGRect){kPadding, kPadding + 50, CGSizeMake(100, 100)};
    self.titleLabel.text = @"";
    
    [self.containerView addSubview:self.iconImgView];
    [self.containerView addSubview:self.titleLabel];
    
    // 动画
    [self animateShowHandelType:LoadingContainerAnimateTypeNone];
    self.animateType = LoadingContainerAnimateTypeNone;
    
    [self loadingStart:3.0];
}

- (void)loadingStart:(double)duration {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

    animation.duration = 1.0;
    animation.fromValue = [NSNumber numberWithFloat: 0.0f];
    animation.toValue   = [NSNumber numberWithFloat: 2 * M_PI];
    animation.repeatCount = duration;
    animation.delegate = self;
    [self.iconImgView.layer addAnimation:animation forKey:@"imageAnimationKey"];
}

#pragma mark 遮盖图
- (void)shadeViewWithType:(LoadingShadeBackgroundType)shadeBgType {
    
    self.shadeView.frame = self.viewController.view.frame;
    self.shadeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if (shadeBgType == LoadingShadeBackgroundTypeSolid) {
        self.shadeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
    }
    else if (shadeBgType == LoadingShadeBackgroundTypeBlur) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = self.shadeView.bounds;
        [self.shadeView addSubview:effectView];
    }
    
//    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]
//                                      initWithTarget:self action:@selector(loadingEnd)];
//    [self.shadeView addGestureRecognizer:tapGes];
    [self.viewController.view addSubview:self.shadeView];
}

#pragma mark 关闭处理
- (void)loadingEnd {
    
    if (self.animateType == LoadingContainerAnimateTypeNone) {
        [self dismissDealloc];
    }
    else {
        [self animateHiddenHandelType:self.animateType];
    }
}

- (void)dismissDealloc {
    
    [self.titleLabel removeFromSuperview];
    [self.iconImgView removeFromSuperview];
    [self.containerView removeFromSuperview];
    [self.viewController removeFromParentViewController];
    [self.window removeFromSuperview];
    self.containerView = nil;
    self.viewController = nil;
    self.window = nil;
    [self shareDealloc];
    
    if (self.didDismissBlock) {
        self.didDismissBlock();
    }
}

#pragma mark 容器动画处理
- (void)animateShowHandelType:(LoadingContainerAnimateType)animatedType {
    
    //self.containerView.hidden = YES;
    IOSWeakSelf
    if (animatedType == LoadingContainerAnimateTypeNone) {
        weakSelf.containerView.hidden = NO;
        return ;
    }
    else if (animatedType == LoadingContainerAnimateTypeZoomBig) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CABasicAnimation *animation =
            [weakSelf getAnimationWithKeyPath:@"transform.scale"
                                         from:@(0.1) to:@(1) duration:0.3
                                          way:kCAMediaTimingFunctionEaseOut];
            weakSelf.containerView.hidden = NO;
            [weakSelf.containerView.layer addAnimation:animation forKey:@""];
        });
    }
}

- (void)animateHiddenHandelType:(LoadingContainerAnimateType)animatedType {
    
    IOSWeakSelf
    if (animatedType == LoadingContainerAnimateTypeNone) {
        return ;
    }
    else if (animatedType == LoadingContainerAnimateTypeZoomBig) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CABasicAnimation *animation =
            [weakSelf getAnimationWithKeyPath:@"transform.scale"
                                         from:@(1) to:@(0) duration:0.3
                                          way:kCAMediaTimingFunctionEaseIn];
            weakSelf.containerView.hidden = NO;
            [weakSelf.containerView.layer addAnimation:animation forKey:@"hidden"];
        });
    }
}
#pragma mark 懒加载

- (UIWindow *)window {
    if(!_window) {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.opaque = NO;
    }
    return _window;
}

- (UIViewController *)viewController {
    if(!_viewController) {
        _viewController = [[UIViewController alloc] init];
        _viewController.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _viewController;
}

- (UIView *)shadeView {
    if(!_shadeView) {
        _shadeView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _shadeView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.backgroundColor = [UIColor colorWithDisplayP3Red: 0x99 / 255.0f
                                                                  green:0x99 / 255.0f
                                                                   blue:0x99 / 255.0f
                                                                  alpha:1.0];
    }
    return _containerView;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.image = [UIImage imageNamed:@"loading"];
    }
    return _iconImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"loading";
    }
    return _titleLabel;
}

#pragma mark 动画工具方法
- (CABasicAnimation *)getAnimationWithKeyPath:(NSString *)keyPath
                                         from:(id)fromValue
                                           to:(id)toValue
                                     duration:(CFTimeInterval)duration
                                          way:(NSString *)way
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:way];
    return animation;
}

#pragma mark 动画代理
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (flag && [self.containerView.layer.animationKeys containsObject:@"hidden"]) {
        [self dismissDealloc];
    }
    else if (flag && ![self.iconImgView.layer.animationKeys containsObject:@"imageAnimationKey"]) {
        [self dismissDealloc];
    }
}


@end
