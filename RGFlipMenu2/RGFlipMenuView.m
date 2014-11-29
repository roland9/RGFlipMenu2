//
//  RGFlipMenuView.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "RGFlipMenuView.h"
#import "FrameAccessor.h"


#define isLandscape  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
#define kRGFlipMenuWidth    120
#define kRGFlipMenuHeight   120
#define kRGFlipMenuPadding  30.f


@interface RGFlipMenuView ()

@property (nonatomic, weak) RGFlipMenu *flipMenu;
@property (nonatomic, strong) UILabel *menuFrontLabel;
@property (nonatomic, strong) UILabel *menuBackLabel;

@end


@implementation RGFlipMenuView

- (instancetype)initWithFlipMenu:(RGFlipMenu *)theFlipMenu {
    self = [super init];
    if (self) {
        _flipMenu = theFlipMenu;
        _menuWrapperView = [[UIView alloc] init];
//        _menuWrapperView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:.2f];
        [self addSubview:_menuWrapperView];
        
        _menuFrontLabel = [[UILabel alloc] init];
        _menuFrontLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuFrontLabel.textAlignment = NSTextAlignmentCenter;
        _menuFrontLabel.backgroundColor = [UIColor blueColor];
        _menuFrontLabel.text = theFlipMenu.menuText;
        [_menuWrapperView addSubview:_menuFrontLabel];

        _menuBackLabel = [[UILabel alloc] init];
        _menuBackLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuBackLabel.textAlignment = NSTextAlignmentCenter;
        _menuBackLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.8f];
        _menuBackLabel.text = @"Back";
        _menuBackLabel.userInteractionEnabled = NO;
        [_menuWrapperView addSubview:_menuBackLabel];

        _menuBackLabel.alpha = 0.f;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMenu:)];
        [_menuWrapperView addGestureRecognizer:tap];
        
//        self.menuWrapperView.transform = CGAffineTransformMakeScale(0.4, 0.4);

    }
    return self;
}


- (void)didTapMenu:(id)sender {
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"inconsistent");
    NSLog(@"bla");
    
    UITapGestureRecognizer *tap = sender;
    if (CGRectContainsPoint(self.menuFrontLabel.bounds, [tap locationInView:self.menuFrontLabel])) {
        [self.flipMenu didTapMenu:self];
    }
}


- (void)hideMenuLabel {
    self.menuFrontLabel.alpha = 0.f;
    self.menuBackLabel.alpha = 1.f;
}


- (void)showMenuLabel {
    self.menuFrontLabel.alpha = 1.f;
    self.menuBackLabel.alpha = 0.f;
}


- (void)repositionSubviews {
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint newCenter;

    if (self.flipMenu.isClosed) {
        // menu was opened when user tapped -> move to center again
        newCenter = self.center;

    } else {
        // menu was closed when user tapped -> depending on device orientation, move up or left
        if (isLandscape) {
            // landscape -> move left
            newCenter = CGPointMake(CGRectGetWidth(self.menuFrontLabel.frame)/2.f+kRGFlipMenuPadding, self.centerY);

        } else {
            // portrait -> move up
            newCenter = CGPointMake(self.centerX, CGRectGetHeight(self.menuFrontLabel.frame)/2.f+kRGFlipMenuPadding);
        }
    }

    self.menuWrapperView.center = newCenter;

    self.menuFrontLabel.center = [self convertPoint:self.menuWrapperView.center toView:self.menuWrapperView];
    self.menuBackLabel.center = self.menuFrontLabel.center;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.menuWrapperView.frame = CGRectInset(self.frame, 20, 20);
    self.menuFrontLabel.width = kRGFlipMenuWidth;
    self.menuFrontLabel.height = kRGFlipMenuHeight;
    self.menuBackLabel.width = kRGFlipMenuWidth;
    self.menuBackLabel.height = kRGFlipMenuHeight;
    
    [self repositionSubviews];
}

@end
