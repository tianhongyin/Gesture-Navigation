//
//  ZXGestureNavigationController.m
//  testNavi
//
//  Created by tianhy on 15/2/5.
//  Copyright (c) 2015年 tianhy. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication] keyWindow]
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define Min_Pan_Distance 2.0f
#define Min_Pop_Recognizer_Distance_X SCREEN_WIDTH/4.0f
#define Min_Pop_Recognizer_Distance_Y SCREEN_HEIGHT/8.0f

#import "ZXGestureNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+ZXLayout.h"


@interface ZXGestureNavigationController ()

@property (nonatomic, strong) UIImageView *lastScreenShotView;
@property (nonatomic, strong) NSMutableArray *screenShotsList;
@property (nonatomic, assign) BOOL isDraging;
@property (nonatomic, assign) CGPoint startTouchPoint;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) ZXGestureDirection startDirection;

@end

@implementation ZXGestureNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.supportDrag = YES;
    }
    return self;
}

- (void)dealloc
{
    self.screenShotsList = nil;
    self.lastScreenShotView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addGesture];
}

- (void)addGesture
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(gestureReceive:)];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
}

- (NSMutableArray *)screenShotsList
{
    if (!_screenShotsList) {
        _screenShotsList = [NSMutableArray new];
    }
    return _screenShotsList;
}

#pragma mark - capture

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - push & pop 

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.screenShotsList addObject:[self capture]];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    return [super popViewControllerAnimated:animated];
}

#pragma mark - Gesture Recognizer

- (void)gestureReceive:(UIPanGestureRecognizer *)aRecognizer
{
    if ([self.viewControllers count] <= 1 || !self.supportDrag) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    CGPoint touchPoint = [aRecognizer locationInView:KEY_WINDOW];
    
    ZXGestureDirection direction = [self judgeGestureDirection:aRecognizer];
    
    if (aRecognizer.state == UIGestureRecognizerStateBegan) {
        
        _isDraging = YES;
        _startTouchPoint = touchPoint;
        _startDirection = direction;
        
        [self addMaskBackgroundView];
        [self addMaskScreenShotView];
        
    } else if (aRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if ([self isHorizontalDirection:_startDirection]) {
            
            [self handleHorizontalAnimation:touchPoint completion:^{
                [weakSelf popViewControllerAnimated:NO];
                [weakSelf setNavigationToOrigin];
                [weakSelf removeMashBackgroundView];
                weakSelf.isDraging = NO;
            }];
            
        } else if ([self isVerticalDirection:_startDirection]){
            [self handleVerticalAnimation:touchPoint completion:^{
                [weakSelf popViewControllerAnimated:NO];
                [weakSelf setNavigationToOrigin];
                [weakSelf removeMashBackgroundView];
                weakSelf.isDraging = NO;
            }];
        }
        
        
        return;

    } else if (aRecognizer.state == UIGestureRecognizerStateCancelled
               || aRecognizer.state == UIGestureRecognizerStateFailed) {
        
        self.isDraging = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf moveViewWithX:0];
        } completion:^(BOOL finished) {
            weakSelf.backgroundView.hidden = YES;
        }];
        return;
    }
    
    if (direction == ZXGestureDirectionUnKnown) {
        return;
    } if (direction == ZXGestureDirectionRight || direction == ZXGestureDirectionLeft) {
        if (_isDraging) {
            if (![self isVerticalDirection:_startDirection]) {
                [self moveViewWithX:touchPoint.x - _startTouchPoint.x];
            } else {
                [self moveViewWithY:touchPoint.y - _startTouchPoint.y];
            }
            
        }
    } else if (direction == ZXGestureDirectionUp || direction == ZXGestureDirectionDown) {
        if (_isDraging) {
            if ([self isVerticalDirection:_startDirection]) {
                [self moveViewWithY:touchPoint.y - _startTouchPoint.y];
            } else {
                [self moveViewWithX:touchPoint.x - _startTouchPoint.x];
            }
        }
    }
}

- (void)moveViewWithX:(float)x
{
    x = x>SCREEN_WIDTH?SCREEN_WIDTH:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
}

- (void)moveViewWithY:(float)y
{
    y = y>SCREEN_HEIGHT?SCREEN_HEIGHT:y;
    
    CGRect frame = self.view.frame;
    frame.origin.y = y;
    self.view.frame = frame;

}

- (void)addMaskBackgroundView
{
    if (!self.backgroundView) {
        self.backgroundView = [UIView new];
    }
    
    if (self.backgroundView.superview) {
        [self.backgroundView removeFromSuperview];
    }
    
    [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
    [self.backgroundView ZX_showInSuperView:self.view.superview];

    self.backgroundView.hidden = NO;

}

- (void)addMaskScreenShotView
{
    
    if (_lastScreenShotView) {
        [_lastScreenShotView removeFromSuperview];
        _lastScreenShotView = nil;
    }
    
    UIImage *lastScreenShotImg = [self.screenShotsList lastObject];
    self.lastScreenShotView = [[UIImageView alloc] initWithImage:lastScreenShotImg];
    [self.lastScreenShotView ZX_showInSuperView:self.backgroundView];

}

- (void)removeMashBackgroundView
{
    if (_isDraging) {
        return;
    }
    
    if (!self.backgroundView) {
        return;
    }
    
    if (self.backgroundView && [self.backgroundView superview]) {
        [self.backgroundView removeFromSuperview];
    }
}


- (void)animateNavigationViewToX:(float)x complete:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self moveViewWithX:x];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)animateNavigationViewToY:(float)y complete:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self moveViewWithY:y];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)setNavigationToOrigin
{
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.view.frame = frame;
}

- (ZXGestureDirection)judgeGestureDirection:(UIPanGestureRecognizer *)recognizer
{
    CGPoint velocityPoint = [recognizer velocityInView:KEY_WINDOW];
    
    float velocity_x = velocityPoint.x;
    float velocity_y = velocityPoint.y;
    
    ZXGestureDirection direction;
    
    if (ABS(ABS(velocity_x) - ABS(velocity_y)) < Min_Pan_Distance) {
        direction = ZXGestureDirectionUnKnown;
        NSLog(@"未知");
    } else if ([self weatherRightDirection:velocityPoint]) {
        direction = ZXGestureDirectionRight;
        NSLog(@"向右");
    } else if ([self weatherLeftDirection:velocityPoint]) {
        direction = ZXGestureDirectionLeft;
        NSLog(@"向左");
    } else if ([self weatherUpDirection:velocityPoint]) {
        direction = ZXGestureDirectionUp;
        NSLog(@"向上");
    } else if ([self weatherDownDirection:velocityPoint]) {
        direction = ZXGestureDirectionDown;
        NSLog(@"向下");
    }
    
    return direction;
}

- (BOOL)weatherRightDirection:(CGPoint)velocityPoint
{
    float velocity_x = velocityPoint.x;
    float velocity_y = velocityPoint.y;
    
    if (ABS(ABS(velocity_x) - ABS(velocity_y)) > 5.0
        && velocity_x > ABS(velocity_y)
        && velocity_x > 0) {
        
        return YES;
    }
    
    return NO;
}

- (BOOL)weatherLeftDirection:(CGPoint)velocityPoint
{
    float velocity_x = velocityPoint.x;
    float velocity_y = velocityPoint.y;

    if (ABS(ABS(velocity_x) - ABS(velocity_y)) > 5.0
        && ABS(velocity_x) > ABS(velocity_y)
        && velocity_x < 0) {
        
        return YES;
    }
    
    return NO;
}

- (BOOL)weatherUpDirection:(CGPoint)velocityPoint
{
    float velocity_x = velocityPoint.x;
    float velocity_y = velocityPoint.y;
    
    if (ABS(ABS(velocity_x) - ABS(velocity_y)) > 5.0
        && ABS(velocity_y) >  ABS(velocity_x)
        && velocity_y < 0) {
        
        return YES;
    }
    
    return NO;
}

- (BOOL)weatherDownDirection:(CGPoint)velocityPoint
{
    float velocity_x = velocityPoint.x;
    float velocity_y = velocityPoint.y;

    if (ABS(ABS(velocity_x) - ABS(velocity_y)) > 5.0
        && ABS(velocity_y) >  ABS(velocity_x)
        && velocity_y > 0) {
        
        return YES;
    }
    
    return NO;
}

- (BOOL)isHorizontalDirection:(ZXGestureDirection)direction
{
    if (direction == ZXGestureDirectionLeft || direction == ZXGestureDirectionRight) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isVerticalDirection:(ZXGestureDirection)direction
{
    if (direction == ZXGestureDirectionDown || direction == ZXGestureDirectionUp) {
        return YES;
    }

    return NO;
}

- (void)handleHorizontalAnimation:(CGPoint)touchPoint completion:(void (^)(void))completion
{
    float touchPointSpacing_X = touchPoint.x - _startTouchPoint.x;
    __weak typeof(self) weakSelf = self;
    
    if (ABS(touchPointSpacing_X) > Min_Pop_Recognizer_Distance_X) {
        
        float navigationTargetLocation_X;
        
        if (touchPointSpacing_X > 0) {
            navigationTargetLocation_X = SCREEN_WIDTH;
        } else {
            navigationTargetLocation_X = -SCREEN_WIDTH;
        }
        
        [self animateNavigationViewToX:navigationTargetLocation_X complete:^{
            if (completion) {
                completion();
            }
        }];
        
    } else {
        
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isDraging = NO;
            weakSelf.backgroundView.hidden = YES;
        }];
    }

}

- (void)handleVerticalAnimation:(CGPoint)touchPoint completion:(void (^)(void))completion
{
    float touchPointSpacing_Y = touchPoint.y - _startTouchPoint.y;
    __weak typeof(self) weakSelf = self;
    
    if (ABS(touchPointSpacing_Y) > Min_Pop_Recognizer_Distance_Y) {
        
        float navigationTargetLocation_Y;
        
        if (touchPointSpacing_Y > 0) {
            navigationTargetLocation_Y = SCREEN_HEIGHT;
        } else {
            navigationTargetLocation_Y = -SCREEN_HEIGHT;
        }
        
        [self animateNavigationViewToY:navigationTargetLocation_Y complete:^{
            if (completion) {
                completion();
            }
        }];
        
    } else {
        
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf moveViewWithY:0];
        } completion:^(BOOL finished) {
            _isDraging = NO;
            weakSelf.backgroundView.hidden = YES;
        }];
    }
}
@end
