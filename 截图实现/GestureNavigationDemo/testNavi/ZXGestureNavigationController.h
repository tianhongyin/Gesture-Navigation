//
//  ZXGestureNavigationController.h
//  testNavi
//
//  Created by tianhy on 15/2/5.
//  Copyright (c) 2015年 tianhy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _ZXGestureDirection
{
    
    ZXGestureDirectionUnKnown = 0,
    ZXGestureDirectionLeft = 1,
    ZXGestureDirectionRight = 2,
    ZXGestureDirectionUp = 3,
    ZXGestureDirectionDown = 4
    
} ZXGestureDirection;


@interface ZXGestureNavigationController : UINavigationController

@property (nonatomic, assign) BOOL supportDrag;

@end
