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
#define kRGFlipMenuWidth        120
#define kRGFlipMenuHeight       120
#define kRGFlipMenuPadding      30.f

#define kRGFlipSubMenuWidth     80
#define kRGFlipSubMenuHeight    80


@interface RGFlipMenuView ()

@property (nonatomic, weak) RGFlipMenu *flipMenu;
@property (nonatomic, strong) UILabel *menuFrontLabel;
@property (nonatomic, strong) UILabel *menuBackLabel;
@property (nonatomic, strong) UIView *subMenuContainerView;

@end


@implementation RGFlipMenuView

- (instancetype)initWithFlipMenu:(RGFlipMenu *)theFlipMenu {
    self = [super init];
    if (self) {
//        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
        _flipMenu = theFlipMenu;
        
        _subMenuContainerView = [UIView new];
//        _subMenuContainerView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.2f];
        [self addSubview:_subMenuContainerView];
        
        [theFlipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            RGFlipMenuView *subMenuView = subMenu.menuView;
            [self addSubview:subMenuView];
        }];

        _menuWrapperView = [[UIView alloc] init];
//        _menuWrapperView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.9f];
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
    }
    return self;
}


- (void)didTapMenu:(id)sender {
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"inconsistent");
    
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


- (void)hideSubMenusWithCenter:(CGPoint)center {
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
//        subMenu.menuView.alpha = 0.f;
        subMenu.menuView.center = center;
        subMenu.menuView.menuWrapperView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
//        subMenu.menuView.width = 10.f;
//        subMenu.menuView.height = 10.f;
    }];
}


- (void)showSubMenusWithCenter:(CGPoint)center {
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        subMenu.menuView.menuWrapperView.transform = CGAffineTransformIdentity;
//        subMenu.menuView.alpha = 1.f;
//        subMenu.menuView.center = center;
    }];
}


- (void)repositionSubViews {
    CGPoint newCenter;

    if (self.flipMenu.isClosed) {
        // menu was opened when user tapped -> move to center again
        newCenter = self.middlePoint;

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
    [self repositionSubMenus];
}


# pragma mark - Private

- (void)repositionSubMenus {
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        [self repositionSubMenu:subMenu subMenuIndex:idx maxIndex:[self.flipMenu.subMenus count]];
    }];
}


- (void)repositionSubMenu:(RGFlipMenu *)subMenu subMenuIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex {
    
    CGPoint newCenter;
    
    if (self.flipMenu.isClosed) {
        // menu was opened when user tapped -> move to center again
        newCenter = self.center;
        subMenu.menuView.menuWrapperView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);

    } else {
        // menu was closed when user tapped -> depending on device orientation, move up or left
        
        if (isLandscape) {
            CGFloat x = CGRectGetWidth(self.menuFrontLabel.frame);
            CGRect subMenusContainerRect = CGRectMake(x, self.top, self.width-x, self.height);
            self.subMenuContainerView.frame = CGRectInset(subMenusContainerRect, 30, 30);
        } else {
            
            CGFloat y = CGRectGetHeight(self.menuFrontLabel.frame);
            CGRect subMenusContainerRect = CGRectMake(self.x, y, self.width, self.height-y);
            self.subMenuContainerView.frame = CGRectInset(subMenusContainerRect, 30, 30);
            
        }
        
        newCenter = [self subMenuCenterWithIndex:theIndex maxIndex:theMaxIndex subMenuContainerView:self.subMenuContainerView];
        subMenu.menuView.menuWrapperView.transform = CGAffineTransformIdentity;
    }
    
    subMenu.menuView.width = kRGFlipSubMenuWidth;
    subMenu.menuView.height = kRGFlipSubMenuHeight;
    subMenu.menuView.center = newCenter;
}


- (CGPoint)subMenuCenterWithIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex subMenuContainerView:(UIView *)subMenuContainerView {
    NSUInteger maxIndex;
    if (theMaxIndex%2 == 1)
        maxIndex = theMaxIndex+1;
    else
        maxIndex = theMaxIndex;
    
    if (isLandscape) {

        CGPoint subMenuCenter = CGPointMake(subMenuContainerView.x + subMenuContainerView.width/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.width/maxIndex*2.f),
                                            subMenuContainerView.y + subMenuContainerView.height*0.25f + subMenuContainerView.height*0.5f * (theIndex%2));
        return subMenuCenter;
        
    } else {
        
        CGPoint subMenuCenter = CGPointMake(subMenuContainerView.x + subMenuContainerView.width*0.25f + subMenuContainerView.width*0.5f * (theIndex%2),
                                            subMenuContainerView.y + subMenuContainerView.height/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.height/maxIndex*2.f));
        return subMenuCenter;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.flipMenu.superMenu) {

        // root menu
        self.menuWrapperView.frame = CGRectInset(self.frame, 20, 20);
        self.menuFrontLabel.width = kRGFlipMenuWidth;
        self.menuFrontLabel.height = kRGFlipMenuHeight;
        self.menuBackLabel.width = kRGFlipMenuWidth;
        self.menuBackLabel.height = kRGFlipMenuHeight;
        
    } else {
        
        // sub menu
        self.menuWrapperView.frame = CGRectInset(self.frame, 20, 20);
        self.menuFrontLabel.width = kRGFlipSubMenuWidth;
        self.menuFrontLabel.height = kRGFlipSubMenuHeight;
        self.menuBackLabel.width = kRGFlipSubMenuWidth;
        self.menuBackLabel.height = kRGFlipSubMenuHeight;
    }
    
    [self repositionSubViews];
    [self repositionSubMenus];
}

@end
