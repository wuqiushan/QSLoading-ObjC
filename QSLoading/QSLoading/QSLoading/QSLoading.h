//
//  QSLoading.h
//  QSLoading
//
//  Created by wuqiushan on 2019/10/8.
//  Copyright © 2019 wuqiushan3@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoadingContainerAnimateType) {
    
    /** 默认没有动画 */
    LoadingContainerAnimateTypeNone,
    /** 动画放大 */
    LoadingContainerAnimateTypeZoomBig,
};

typedef NS_ENUM(NSInteger, LoadingShadeBackgroundType) {
    
    /** 遮盖图固定色(透明) */
    LoadingShadeBackgroundTypeSolid,
    /** 毛玻璃色，(系统UIBlurEffectStyleLight) */
    LoadingShadeBackgroundTypeBlur,
};

typedef void(^didDismiss)(void);

NS_ASSUME_NONNULL_BEGIN

@interface QSLoading : UIView

/**
 不带视图消失事件的loading圈
 
 @param title loading标题
 @param duration loading时长
 */
+ (void)showTitle:(NSString *)title duration:(double)duration;

/**
 带视图消失事件的loading圈
 
 @param title loading标题
 @param duration loading时长
 @param didDismissBlock loading消失回调
 */
+ (void)showTitle:(NSString *)title duration:(double)duration didDismiss:(didDismiss)didDismissBlock;

/**
 关闭loading圈
 */
+ (void)dismiss;

@end

NS_ASSUME_NONNULL_END
