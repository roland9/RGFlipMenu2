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
        
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
        _flipMenu = theFlipMenu;
        
        _subMenuContainerView = [UIView new];
        _subMenuContainerView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.2f];
        _subMenuContainerView.userInteractionEnabled = NO;
        [self addSubview:_subMenuContainerView];

        [theFlipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            RGFlipMenuView *subMenuView = subMenu.menuView;
            [_subMenuContainerView addSubview:subMenuView];
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
        _menuBackLabel.text = NSLocalizedString(@"Back in menu", @"Back in card backside menu");
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
    }
    return self;
}


- (void)didMoveToSuperview {
    if (self.superview) {
        
        // add the tap gesture recognizer only for the root menu
        // we have to add it to the superview because it will be moved aside when a menu is tapped, thus blocking taps on outside menus
        if (!_flipMenu.superMenu) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMenu:)];
            [self.superview addGestureRecognizer:tap];
        }

    }
}


- (void)didTapMenu:(id)sender {
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"inconsistent");
    
    UITapGestureRecognizer *tap = sender;
    CGPoint tapPoint = [tap locationInView:self.menuWrapperView];
    if (CGRectContainsPoint(self.menuFrontLabel.frame, tapPoint)) {
        [self.flipMenu didTapMenu:self];
        return;
    }
    
    [self performTapOnSubMenusWithTapPoint:tapPoint];
}


- (void)performTapOnSubMenusWithTapPoint:(CGPoint)tapPoint {
    __block BOOL found = NO;
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        
        CGPoint tapPointConverted = [self.menuWrapperView convertPoint:tapPoint toView:subMenu.menuView.menuWrapperView];
        
        if (CGRectContainsPoint(subMenu.menuView.menuFrontLabel.frame, tapPointConverted)) {
            
            [self.flipMenu didTapSubMenu:subMenu];
            found = YES;
            *stop = YES;
        }
    }];
    
    if (!found) {
        [self.flipMenu popToRoot];
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


# pragma mark - Private

- (Class)colorClass {
    return [self.flipMenu.rgFlipMenuColorClass class] ?: [self.flipMenu.superMenu.rgFlipMenuColorClass class];
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

        subMenu.menuView.frame = CGRectMake(0, 0, kRGFlipSubMenuWidth, kRGFlipSubMenuHeight);
        newCenter = [self.subMenuContainerView convertPoint:self.middlePoint fromView:self];
        subMenu.menuView.center = newCenter;
        subMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2);


    } else {
        
        subMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;

        if (subMenu.isClosed) {
            newCenter = [self subMenuCenterWithIndex:theIndex maxIndex:theMaxIndex subMenuContainerView:self.subMenuContainerView];
            subMenu.menuView.center = newCenter;
            subMenu.menuView.width = kRGFlipSubMenuWidth;
            subMenu.menuView.height = kRGFlipSubMenuHeight;
            subMenu.menuView.menuWrapperView.frame = CGRectMake(0, 0, 100, 100);
            subMenu.menuView.menuFrontLabel.frame = CGRectMake(0, 0, kRGFlipSubMenuWidth, kRGFlipSubMenuHeight);
            subMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
            
        } else {
            subMenu.menuView.frame = CGRectMake(0, 0, self.flipMenu.menuView.width, self.flipMenu.menuView.height);

        }
    }
}


- (CGPoint)subMenuCenterWithIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex subMenuContainerView:(UIView *)subMenuContainerView {
    NSUInteger maxIndex;
    if (theMaxIndex%2 == 1)
        maxIndex = theMaxIndex+1;
    else
        maxIndex = theMaxIndex;
    
    if (isLandscape) {
        
        CGPoint subMenuCenter = CGPointMake(0 + subMenuContainerView.width/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.width/maxIndex*2.f),
                                            subMenuContainerView.height*0.25f + subMenuContainerView.height*0.5f * (theIndex%2));
        return subMenuCenter;
        
    } else {
        
        CGPoint subMenuCenter = CGPointMake(subMenuContainerView.width*0.25f + subMenuContainerView.width*0.5f * (theIndex%2),
                                            subMenuContainerView.height/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.height/maxIndex*2.f));
        return subMenuCenter;
    }
}


- (void)showSubMenu:(RGFlipMenu *)theSubMenu {
    theSubMenu.menuView.frame = CGRectMake(0, 0, CGRectGetWidth(self.subMenuContainerView.frame), CGRectGetHeight(self.subMenuContainerView.frame));
    
    theSubMenu.closed = NO;
    [theSubMenu.menuView repositionViews];
}


- (void)repositionViews {
    
    self.menuWrapperView.frame = CGRectInset(self.frame, 20, 20);

    if (!self.flipMenu.superMenu) {
        
        // root menu
        self.menuFrontLabel.width = kRGFlipMenuWidth;
        self.menuFrontLabel.height = kRGFlipMenuHeight;
        self.menuBackLabel.width = kRGFlipMenuWidth;
        self.menuBackLabel.height = kRGFlipMenuHeight;
        
    } else {
        
        // sub menu
        self.menuFrontLabel.width = kRGFlipSubMenuWidth;
        self.menuFrontLabel.height = kRGFlipSubMenuHeight;
        self.menuBackLabel.width = kRGFlipSubMenuWidth;
        self.menuBackLabel.height = kRGFlipSubMenuHeight;
    }
    
    CGPoint newCenter;
    
    if (self.flipMenu.isClosed) {
        // menu was opened when user tapped -> move to center again
        newCenter = self.middlePoint;
        
    } else {
        // menu is opening now -> depending on device orientation, move menuView up or left
        if (isLandscape) {
            // landscape -> move left
            newCenter = CGPointMake(CGRectGetWidth(self.menuFrontLabel.frame)/2.f+kRGFlipMenuPadding, self.centerY/2.f);
            
        } else {
            // portrait -> move up
            newCenter = CGPointMake(self.centerX/2.f, CGRectGetHeight(self.menuFrontLabel.frame)/2.f+kRGFlipMenuPadding);
        }
        
    }
    
    self.center = newCenter;
    
//    self.menuWrapperView.backgroundColor = [UIColor magentaColor];
    self.menuWrapperView.center = self.middlePoint;
    
    self.menuFrontLabel.center = [self.menuWrapperView convertPoint:self.middlePoint fromView:self];
    self.menuBackLabel.frame = self.menuFrontLabel.frame;


    // reposition subMenuContainerView
    if (self.flipMenu.isClosed) {
        self.subMenuContainerView.frame = CGRectMake(0, 0, kRGFlipMenuWidth+40, kRGFlipMenuHeight+40);;
        self.subMenuContainerView.center = [self.superview convertPoint:self.superview.center toView:self.subMenuContainerView];
        
    } else {
        // menu is opening now -> depending on device orientation, the subMenuContainerView fills out rest of space
        if (isLandscape) {
            CGFloat x = CGRectGetWidth(self.menuFrontLabel.frame);
            self.subMenuContainerView.frame = CGRectMake(x, 0, self.width-x-20, self.height-20);
            if (!self.flipMenu.superMenu) {
                self.subMenuContainerView.center = [self.superview convertPoint:self.superview.center toView:self];
            } else {
                // inception - move to superview superview??
#warning WIP
                self.subMenuContainerView.center = [self.flipMenu.superMenu.menuView.superview convertPoint:self.flipMenu.superMenu.menuView.superview.center toView:self];
            }
            self.subMenuContainerView.centerX += x/2.f;
        } else {
            
            CGFloat y = CGRectGetHeight(self.menuFrontLabel.frame);
            self.subMenuContainerView.frame = CGRectMake(10, y, self.width-20, self.height-y-20);
            if (!self.flipMenu.superMenu) {
                self.subMenuContainerView.center = [self.superview convertPoint:self.superview.center toView:self];
            } else {
                // inception - move to superview superview??
                self.subMenuContainerView.center = [self.flipMenu.superMenu.menuView.superview convertPoint:self.flipMenu.superMenu.menuView.superview.center toView:self];
            }
            self.subMenuContainerView.centerY += y/2.f;
        }
    }

    // reposition subMenus
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        [self repositionSubMenu:subMenu subMenuIndex:idx maxIndex:[self.flipMenu.subMenus count]];
    }];
}

@end
