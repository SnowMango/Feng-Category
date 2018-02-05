//
//  MiniPlayerView.h
//  LayoutTest
//
//  Created by zhengfeng on 2017/10/23.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniPlayerView : UIView
//enbleMoveArea don't set rect size less frame size, default value is self.frame;
@property (nonatomic) CGRect enbleMoveArea;

@end
