//
//  UIView+StoryboardLayout.h
//  layoutTest
//
//  Created by zhengfeng on 2017/8/22.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (StoryboardLayout)

- (NSLayoutConstraint*)lsb_top:(CGFloat)constant;
- (NSLayoutConstraint*)lsb_leading:(CGFloat)constant;
- (NSLayoutConstraint*)lsb_bottom:(CGFloat)constant;
- (NSLayoutConstraint*)lsb_trailing:(CGFloat)constant;

- (NSLayoutConstraint*)lsb_top:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_leading:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_bottom:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_trailing:(CGFloat)constant toItem:(id)otherView;

- (NSLayoutConstraint*)lsb_width:(CGFloat)constant;
- (NSLayoutConstraint*)lsb_height:(CGFloat)constant;

- (NSLayoutConstraint*)lsb_width:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_height:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_aspect:(CGFloat)multiplier;

@end


@interface UIView (StoryboardLayoutMargin)

- (NSLayoutConstraint*)lsb_topMargin:(CGFloat)constant NS_AVAILABLE_IOS(8.0);
- (NSLayoutConstraint*)lsb_leadingMargin:(CGFloat)constant NS_AVAILABLE_IOS(8.0);
- (NSLayoutConstraint*)lsb_bottomMargin:(CGFloat)constant NS_AVAILABLE_IOS(8.0);
- (NSLayoutConstraint*)lsb_trailingMargin:(CGFloat)constant NS_AVAILABLE_IOS(8.0);

- (NSLayoutConstraint*)lsb_topMargin:(CGFloat)constant toItem:(id)otherView NS_AVAILABLE_IOS(8.0);
- (NSLayoutConstraint*)lsb_leadingMargin:(CGFloat)constant toItem:(id)otherView NS_AVAILABLE_IOS(8.0);
- (NSLayoutConstraint*)lsb_bottomMargin:(CGFloat)constant toItem:(id)otherView NS_AVAILABLE_IOS(8.0);
- (NSLayoutConstraint*)lsb_trailingMargin:(CGFloat)constant toItem:(id)otherView NS_AVAILABLE_IOS(8.0);

@end


@interface UIView (StoryboardLayoutAlignment)
- (NSLayoutConstraint*)lsb_alignTop:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_alignLeading:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_alignBottom:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_alignTrailing:(CGFloat)constant toItem:(id)otherView;

- (NSLayoutConstraint*)lsb_horizontally:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_vertically:(CGFloat)constant toItem:(id)otherView;
- (NSLayoutConstraint*)lsb_baseline:(CGFloat)constant toItem:(id)otherView;

- (NSLayoutConstraint*)lsb_horizontally:(CGFloat)constant;
- (NSLayoutConstraint*)lsb_vertically:(CGFloat)constant;
@end

typedef NS_OPTIONS(NSUInteger, NSLayoutSupportDeviceDirection) {
    NSLayoutSupportDeviceDirectionLandscape  =    1 << 0,
    NSLayoutSupportDeviceDirectionPortrait =   1 << 1,
    NSLayoutSupportDeviceDirectionAll = 0
};

@interface UIView (StoryboardSizeClass)

@property (nonatomic, strong) NSArray *viewConstraint;

@end


@interface NSLayoutConstraint (ChangeValue)

@property (nonatomic, assign) NSLayoutSupportDeviceDirection supportDeviceDirection;

- (NSLayoutConstraint*)changeRelation:(NSLayoutRelation)relation;
- (NSLayoutConstraint*)changeMultiplier:(CGFloat)multiplier;

+(instancetype)baseConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
@end
