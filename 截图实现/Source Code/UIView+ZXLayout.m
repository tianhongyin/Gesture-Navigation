//
//  UIView+ZXLayout.m
//  MultiLayerNavigation
//
//  Created by tianhy on 15/2/5.
//  Copyright (c) 2015年 Feather Chan. All rights reserved.
//

#import "UIView+ZXLayout.h"

@implementation UIView (ZXLayout)

- (void)ZX_showInSuperView:(UIView *)superView
{
    if ([self superview]) {
        if ([self superview] != superView) {
            [self removeFromSuperview];
            [superView addSubview:self];
        }
    } else {
        [superView addSubview:self];
    }
    
    NSMutableArray *allContraints = [NSMutableArray new];
    NSDictionary *viewDictionarys = NSDictionaryOfVariableBindings(superView,self);
    // H
    [allContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[self]-0-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewDictionarys]];
    // V
    [allContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[self]-0-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewDictionarys]];
    [superView addConstraints:allContraints];
}

@end
