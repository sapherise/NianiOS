//
//  VVeboLabel.h
//  VVeboTableViewDemo
//
//  Created by Johnil on 15/5/25.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VVeboLabel : UIView

@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, strong, nullable) UIColor *textColor;
@property (nonatomic, strong, nullable) UIFont *font;
@property (nonatomic) NSInteger lineSpace;
@property (nonatomic) NSTextAlignment textAlignment;
//==
typedef void (^VVeboHandler)(NSString *string);
@property (nullable, nonatomic, copy) VVeboHandler AccountHandler;
@property (nullable, nonatomic, copy) VVeboHandler URLHandler;
//
- (void)debugDraw;
- (void)clear;
- (BOOL)touchPoint:(CGPoint)point;

@end