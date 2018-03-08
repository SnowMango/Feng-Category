//
//  UIView+StoryboardLayout.m
//  layoutTest
//
//  Created by zhengfeng on 2017/8/22.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "UIView+StoryboardLayout.h"

@implementation UIView (StoryboardLayout)


- (NSLayoutConstraint*)lsb_top:(CGFloat)constant
{
    return [self lsb_alignTop:constant toItem:self.superview];
}

- (NSLayoutConstraint*)lsb_leading:(CGFloat)constant
{
    return [self lsb_alignLeading:constant toItem:self.superview];
}
- (NSLayoutConstraint*)lsb_bottom:(CGFloat)constant
{
    
    return [self lsb_alignBottom:constant toItem:self.superview];
}
- (NSLayoutConstraint*)lsb_trailing:(CGFloat)constant
{
    return [self lsb_alignTrailing:constant toItem:self.superview];
}

- (NSLayoutConstraint*)lsb_top:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeBottom
                                       multiplier:1.0
                                         constant:constant];
}

- (NSLayoutConstraint*)lsb_leading:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeLeading
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0
                                         constant:constant];
}
- (NSLayoutConstraint*)lsb_bottom:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeBottom
                                       multiplier:1.0
                                         constant:constant];
}
- (NSLayoutConstraint*)lsb_trailing:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeLeading
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0
                                         constant:constant];
}


- (NSLayoutConstraint*)lsb_width:(CGFloat)constant
{
    return [self lsb_width:constant toItem:nil];
}

- (NSLayoutConstraint*)lsb_height:(CGFloat)constant
{
    return [self lsb_height:constant toItem:nil];
}

- (NSLayoutConstraint*)lsb_width:(CGFloat)constant toItem:(id)otherView
{
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:otherView attribute:NSLayoutAttributeWidth
                                multiplier:1.0
                                  constant:constant];
    return constraint;
}

- (NSLayoutConstraint*)lsb_height:(CGFloat)constant toItem:(id)otherView
{
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:otherView attribute:NSLayoutAttributeHeight
                                multiplier:1.0
                                  constant:constant];
    return constraint;
}

- (NSLayoutConstraint*)lsb_aspect:(CGFloat)multiplier
{
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self attribute:NSLayoutAttributeHeight
                                multiplier:multiplier
                                  constant:0];

    return constraint;
}


@end


@implementation UIView (StoryboardLayoutMargin)

- (NSLayoutConstraint*)lsb_topMargin:(CGFloat)constant
{
    return [self lsb_topMargin:constant toItem:self.superview];
}
- (NSLayoutConstraint*)lsb_leadingMargin:(CGFloat)constant
{
    return [self lsb_leadingMargin:constant toItem:self.superview];
}
- (NSLayoutConstraint*)lsb_bottomMargin:(CGFloat)constant
{
    return [self lsb_bottomMargin:constant toItem:self.superview];
}
- (NSLayoutConstraint*)lsb_trailingMargin:(CGFloat)constant
{
    return [self lsb_trailingMargin:constant toItem:self.superview];
}

- (NSLayoutConstraint*)lsb_topMargin:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeTopMargin
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeTopMargin
                                       multiplier:1.0
                                         constant:constant];
}
- (NSLayoutConstraint*)lsb_leadingMargin:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeLeadingMargin
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeLeadingMargin
                                       multiplier:1.0
                                         constant:constant];
}
- (NSLayoutConstraint*)lsb_bottomMargin:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeBottomMargin
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeBottomMargin
                                       multiplier:1.0
                                         constant:constant];
}
- (NSLayoutConstraint*)lsb_trailingMargin:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeTrailingMargin
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeTrailingMargin
                                       multiplier:1.0
                                         constant:constant];
}


@end

@implementation UIView (StoryboardLayoutAlignment)

- (NSLayoutConstraint*)lsb_alignTop:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeTop
                                       multiplier:1.0
                                         constant:constant];
}

- (NSLayoutConstraint*)lsb_alignLeading:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeLeading
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeLeading
                                       multiplier:1.0
                                         constant:constant];
}
- (NSLayoutConstraint*)lsb_alignBottom:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeBottom
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeBottom
                                       multiplier:1.0
                                         constant:constant];
}
- (NSLayoutConstraint*)lsb_alignTrailing:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0
                                         constant:constant];
}

- (NSLayoutConstraint*)lsb_horizontally:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeCenterX
                                       multiplier:1.0
                                         constant:constant];
}

- (NSLayoutConstraint*)lsb_vertically:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeCenterY
                                       multiplier:1.0
                                         constant:constant];
}

- (NSLayoutConstraint*)lsb_baseline:(CGFloat)constant toItem:(id)otherView
{
    return [NSLayoutConstraint baseConstraintWithItem:self attribute:NSLayoutAttributeLastBaseline
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:otherView attribute:NSLayoutAttributeLastBaseline
                                       multiplier:1.0
                                         constant:constant];
}

- (NSLayoutConstraint*)lsb_horizontally:(CGFloat)constant
{
    return [self lsb_horizontally:constant toItem:self.superview];
}
- (NSLayoutConstraint*)lsb_vertically:(CGFloat)constant
{
    
    return [self lsb_vertically:constant toItem:self.superview];
}


@end

#import <objc/runtime.h>

const NSString *ConstraintKey = @"viewConstraintKey";

@implementation UIView (StoryboardSizeClass)
+ (void)load
{
    Method m1 = class_getInstanceMethod(self, @selector(traitCollectionDidChange:));
    Method m2 = class_getInstanceMethod(self, @selector(sizeClassTraitCollectionDidChange:));
    method_exchangeImplementations(m1, m2);
}

- (void)setViewConstraint:(NSMutableArray *)viewConstraint
{
    objc_setAssociatedObject(self, &ConstraintKey, viewConstraint, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)viewConstraint
{
    id obj = objc_getAssociatedObject(self, &ConstraintKey);
    
    return obj;
}

- (void)sizeClassTraitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    
    NSLayoutSupportDeviceDirection direction = NSLayoutSupportDeviceDirectionAll;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        NSInteger v = self.traitCollection.verticalSizeClass;
        NSInteger h = self.traitCollection.horizontalSizeClass;
        if (h == UIUserInterfaceSizeClassCompact && v == UIUserInterfaceSizeClassRegular) {
            direction = NSLayoutSupportDeviceDirectionPortrait;
        }else if(v == UIUserInterfaceSizeClassCompact){
            direction = NSLayoutSupportDeviceDirectionLandscape;
        }
    }else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            direction = NSLayoutSupportDeviceDirectionLandscape;
        }else if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)){
            direction = NSLayoutSupportDeviceDirectionPortrait;
        }
    }
    NSAssert(direction != NSLayoutSupportDeviceDirectionAll, @"%@ this view don't know direction",NSStringFromSelector(_cmd));
    if (direction == NSLayoutSupportDeviceDirectionAll) {
        return;
    }
    
    [self.viewConstraint enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([constraint.identifier isEqualToString:@"topH"]||[constraint.identifier isEqualToString:@"topV"] || [constraint.identifier isEqualToString:@"height"]) {
            NSLog(@"constraint.identifier = %@:%@",constraint.identifier, constraint.active?@"YES":@"NO");
        }
        if (constraint.supportDeviceDirection == direction) {
            if (!constraint.active) {
                constraint.active = YES;
            }
        }else if (constraint.supportDeviceDirection != NSLayoutSupportDeviceDirectionAll){
            if (constraint.active) {
                constraint.active = NO;
            }
        }
    }];
    [self sizeClassTraitCollectionDidChange:previousTraitCollection];
}

@end

const NSString *Support = @"SupportDeviceDirection";
@implementation NSLayoutConstraint (ChangeValue)

- (void)setSupportDeviceDirection:(NSLayoutSupportDeviceDirection)supportDeviceDirection
{
    if (supportDeviceDirection != NSLayoutSupportDeviceDirectionLandscape &&
        supportDeviceDirection != NSLayoutSupportDeviceDirectionPortrait) {
        supportDeviceDirection = NSLayoutSupportDeviceDirectionAll;
    }
    objc_setAssociatedObject(self, &Support, @(supportDeviceDirection), OBJC_ASSOCIATION_ASSIGN);
}

- (NSLayoutSupportDeviceDirection)supportDeviceDirection
{
    id obj = objc_getAssociatedObject(self, &Support);
    return [obj integerValue];
}


- (NSLayoutConstraint*)changeRelation:(NSLayoutRelation)relation
{
    return [NSLayoutConstraint baseConstraintWithItem:self.firstItem attribute:self.firstAttribute
                                        relatedBy:relation
                                           toItem:self.secondItem attribute:self.secondAttribute
                                       multiplier:self.multiplier
                                         constant:self.constant];
}

- (NSLayoutConstraint*)changeMultiplier:(CGFloat)multiplier
{
    return [NSLayoutConstraint baseConstraintWithItem:self.firstItem attribute:self.firstAttribute
                                        relatedBy:self.relation
                                           toItem:self.secondItem attribute:self.secondAttribute
                                       multiplier:multiplier
                                         constant:self.constant];
}

+(instancetype)baseConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(nullable id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c
{

    if (((UIView*)view1).translatesAutoresizingMaskIntoConstraints) {
        ((UIView*)view1).translatesAutoresizingMaskIntoConstraints = NO;
    }
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c];
    constraint.priority = UILayoutPriorityDefaultHigh;
    constraint.supportDeviceDirection = NSLayoutSupportDeviceDirectionAll;
    
    UIView * installView = nil;
    if ([view2 isKindOfClass:[UIView class]]) {
        UIView *secondViewSuperview = view2;
        while (!installView && secondViewSuperview) {
            UIView *firstViewSuperview = view1;
            while (!installView && firstViewSuperview) {
                if (secondViewSuperview == firstViewSuperview) {
                    installView = secondViewSuperview;
                }
                firstViewSuperview = firstViewSuperview.superview;
            }
            secondViewSuperview = secondViewSuperview.superview;
        }
    }else if (attr1 == NSLayoutAttributeHeight || attr1 == NSLayoutAttributeWidth){
        installView = view1;
    }else{
        installView = ((UIView *)view1).superview;
    }
    if (installView) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:installView.viewConstraint];
        [temp addObject:constraint];
        installView.viewConstraint = temp;
    }
    constraint.active = YES;
    return constraint;
}


@end

