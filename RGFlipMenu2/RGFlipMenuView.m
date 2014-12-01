//
//  RGFlipMenuView.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "RGFlipMenuView.h"
#import "FrameAccessor.h"
//#import "RGFlipMenuColors.h"


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
        _subMenuContainerView.userInteractionEnabled = NO;
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
        _menuFrontLabel.text = theFlipMenu.menuText;
        _menuFrontLabel.numberOfLines = 2;
        _menuFrontLabel.layer.cornerRadius = 5.f;
        _menuFrontLabel.layer.masksToBounds = YES;
        [_menuWrapperView addSubview:_menuFrontLabel];
        
        _menuBackLabel = [[UILabel alloc] init];
        _menuBackLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuBackLabel.textAlignment = NSTextAlignmentCenter;
        _menuBackLabel.text = @"Back";
        _menuBackLabel.numberOfLines = 2;
        _menuBackLabel.userInteractionEnabled = NO;
        _menuBackLabel.layer.cornerRadius = 5.f;
        _menuBackLabel.layer.masksToBounds = YES;
        [_menuWrapperView addSubview:_menuBackLabel];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _menuFrontLabel.backgroundColor = [[self colorClass] performSelector:@selector(frontColor)];
        _menuFrontLabel.textColor = [[self colorClass] performSelector:@selector(frontTextColor)];
        _menuBackLabel.backgroundColor = [[self colorClass] performSelector:@selector(backColor)];
        _menuBackLabel.textColor = [[self colorClass] performSelector:@selector(backTextColor)];
#pragma clang diagnostic pop

        _menuBackLabel.alpha = 0.f;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMenu:)];
        [_menuWrapperView addGestureRecognizer:tap];
    }
    return self;
}


- (void)didTapMenu:(id)sender {
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"inconsistent");
    
    UITapGestureRecognizer *tap = sender;
    CGPoint tapPoint = [tap locationInView:self.menuFrontLabel];
    if (CGRectContainsPoint(self.menuFrontLabel.bounds, tapPoint)) {
        [self.flipMenu didTapMenu:self];
        return;
    }
    
    [self performTapOnSubMenusWithTapPoint:[tap locationInView:self]];
}


- (void)performTapOnSubMenusWithTapPoint:(CGPoint)tapPoint {
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        CGPoint tapPointConverted = [self convertPoint:tapPoint toView:subMenu.menuView];
        if (CGRectContainsPoint(subMenu.menuView.menuFrontLabel.bounds, tapPointConverted)) {
            [subMenu didTapMenu:self];
            *stop = YES;
        }
    }];
}


- (void)hideMenuLabel {
    self.menuFrontLabel.alpha = 0.f;
    self.menuBackLabel.alpha = 1.f;
}


- (void)showMenuLabel {
    self.menuFrontLabel.alpha = 1.f;
    self.menuBackLabel.alpha = 0.f;
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

- (Class)colorClass {
    return [self.flipMenu.rgFlipMenuColorClass class] ?: [self.flipMenu.superMenu.rgFlipMenuColorClass class];
}

- (void)repositionSubMenus {
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        [self repositionSubMenu:subMenu subMenuIndex:idx maxIndex:[self.flipMenu.subMenus count]];
    }];
}


- (void)repositionSubMenu:(RGFlipMenu *)subMenu subMenuIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex {
    
    CGPoint newCenter;
    
    if (self.flipMenu.superMenu && self.flipMenu.isClosed) {
        subMenu.menuView.alpha = 0.f;
    } else if (self.flipMenu.superMenu && !self.flipMenu.isClosed) {
        subMenu.menuView.alpha = 1.f;
    }
    
    if (self.flipMenu.isClosed) {
        // menu was opened when user tapped -> move to center again
        newCenter = self.center;
        subMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2);
        
    } else {
        subMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
        
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
        
        if (subMenu.isClosed) {
            newCenter = [self subMenuCenterWithIndex:theIndex maxIndex:theMaxIndex subMenuContainerView:self.subMenuContainerView];
            subMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
        }
    }
    
    if (!subMenu.isClosed) {
        // user opened this submenu -> take over screen
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.8f animations:^{
                subMenu.menuView.frame = self.frame;
            }];
        });
        
//    } else if (subMenu.isClosed && self.flipMenu.superMenu) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0.8f animations:^{
//                subMenu.menuView.width = kRGFlipSubMenuWidth;
//                subMenu.menuView.height = kRGFlipSubMenuHeight;
//                subMenu.menuView.center = newCenter;
//            }];
//        });

    } else {
        
        subMenu.menuView.width = kRGFlipSubMenuWidth;
        subMenu.menuView.height = kRGFlipSubMenuHeight;
        subMenu.menuView.center = newCenter;
        
    }
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
