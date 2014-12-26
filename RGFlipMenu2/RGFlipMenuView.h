//
//  RGFlipMenuView.h
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGFlipMenu.h"

@interface RGFlipMenuView : UIView

@property (nonatomic, strong) UIView *menuWrapperView;

- (instancetype)initWithFlipMenu:(RGFlipMenu *)theFlipMenu;

- (void)flipMenu:(RGFlipMenu *)theFlipMenu;
- (void)showMenuLabel;
- (void)hideMenuLabel;
- (void)animateRadioButtonWithRadioButtonSelected:(BOOL)isRadioButtonSelected;
- (void)animateTap;
- (void)repositionViews;

@end
