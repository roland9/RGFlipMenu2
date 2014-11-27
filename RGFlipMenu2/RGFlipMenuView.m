//
//  RGFlipMenuView.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "RGFlipMenuView.h"
#import "FrameAccessor.h"


#define kRGFlipMenuWidth    180
#define kRGFlipMenuHeight   180

@interface RGFlipMenuView ()

@property (nonatomic, weak) RGFlipMenu *flipMenu;
@property (nonatomic, strong) UIView *menuBackground;
@property (nonatomic, strong) UILabel *menuFrontLabel;
@property (nonatomic, strong) UILabel *menuBackLabel;

@end


@implementation RGFlipMenuView

- (instancetype)initWithFlipMenu:(RGFlipMenu *)theFlipMenu {
    self = [super init];
    if (self) {
        _flipMenu = theFlipMenu;
        _menuWrapperView = [[UIView alloc] init];
//        _menuWrapperView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.2];
        [self addSubview:_menuWrapperView];
        
        _menuBackground = [[UIView alloc] init];
        _menuBackground.backgroundColor = [UIColor blueColor];
        [_menuWrapperView addSubview:_menuBackground];
        
        _menuFrontLabel = [[UILabel alloc] init];
        _menuFrontLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuFrontLabel.textAlignment = NSTextAlignmentCenter;
        _menuFrontLabel.text = theFlipMenu.menuText;
        _menuFrontLabel.userInteractionEnabled = NO;
        [_menuBackground addSubview:_menuFrontLabel];

        _menuBackLabel = [[UILabel alloc] init];
        _menuBackLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuBackLabel.textAlignment = NSTextAlignmentCenter;
        _menuBackLabel.text = @"Back";
        _menuBackLabel.userInteractionEnabled = NO;
        [_menuBackground addSubview:_menuBackLabel];

        _menuBackLabel.alpha = 0.f;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMenu:)];
        [_menuBackground addGestureRecognizer:tap];
        
    }
    return self;
}


- (void)didTapMenu:(id)sender {
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"inconsistent");
    NSLog(@"bla");
    
    [self.flipMenu didTapMenu:self];
}


- (void)hideMenuLabel {
    self.menuFrontLabel.alpha = 0.f;
    self.menuBackLabel.alpha = 1.f;
}


- (void)showMenuLabel {
    self.menuFrontLabel.alpha = 1.f;
    self.menuBackLabel.alpha = 0.f;
}


#define isLandscape  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))

- (void)repositionSubviews {
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint newCenter;

    if (self.flipMenu.isClosed) {
        // menu was opened when user tapped -> move to center again
        newCenter = self.center;

    } else {
        // menu was closed when user tapped -> depending on orientation, move up or left
        if (isLandscape) {
            // landscape -> left
            newCenter = CGPointMake(self.width*0.3f, self.centerY);

        } else {
            // portrait -> up
            newCenter = CGPointMake(self.centerX, self.height*0.3f);
        }

    }

    self.menuWrapperView.center = newCenter;

    self.menuBackground.center = CGPointMake(self.menuWrapperView.centerX, CGRectGetHeight(self.menuWrapperView.bounds)/2.f);
    self.menuFrontLabel.center = self.menuBackground.middlePoint;
    self.menuBackLabel.center = self.menuBackground.middlePoint;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.menuWrapperView.bounds = CGRectInset(self.bounds, 20, 20);
    self.menuBackground.bounds = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
    self.menuFrontLabel.bounds = self.menuBackground.bounds;
    self.menuBackLabel.bounds = self.menuBackground.bounds;
    
    [self repositionSubviews];
}

@end
