//
//  RGFlipMenu.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "RGFlipMenu.h"
#import "RGFlipMenuView.h"

@interface RGFlipMenu ()

@property (nonatomic, strong) NSArray *subMenus;
@property (nonatomic, weak) RGFlipMenu *superMenu;
@property (nonatomic, copy) RGFlipMenuActionBlock actionBlock;
@property (nonatomic, strong) RGFlipMenuView *menuView;

@end

#define kRGAnimationDuration 0.9f


@implementation RGFlipMenu

# pragma mark - Public Factories

// instance with sub menus
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {
    
    return [[RGFlipMenu alloc] initWithSubMenus:theSubMenus superMenu:theSuperMenu actionBlock:nil menuText:theMenuText];
}

// instance as leaf (no submenus) but action block instead
+ (instancetype)createWithActionBlock:(RGFlipMenuActionBlock)theActionBlock superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {
    
    return [[RGFlipMenu alloc] initWithSubMenus:nil superMenu:theSuperMenu actionBlock:theActionBlock menuText:theMenuText];
}


# pragma mark - Accessors

- (RGFlipMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[RGFlipMenuView alloc] initWithFlipMenu:self];
    }
    return _menuView;
}

#define isLandscape  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
#define kRGFlipMenuBackScale 0.6f


# pragma mark - User Action

- (void)didTapMenu:(id)sender {
    
    self.closed = !self.isClosed;
    
    
    // move up and hide or show submenus
    [self.menuView setNeedsLayout];
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.menuView repositionSubviews];
        
    } completion:^(BOOL finished) {
    }];
    
    // hide label -> once the 'backside' of the view is shown, it will be hidden
    if (self.closed) {
        [self.menuView showMenuLabel];
    } else {
        [self.menuView hideMenuLabel];
    }

    // flip menu
    [UIView transitionWithView:self.menuView.menuWrapperView
                      duration:kRGAnimationDuration/3.f
                       options: (isLandscape ?
                                 (self.isClosed ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight) :
                                 (self.isClosed ? UIViewAnimationOptionTransitionFlipFromBottom : UIViewAnimationOptionTransitionFlipFromTop)
                                 ) | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        
                        if (self.closed)
                            self.menuView.menuWrapperView.transform = CGAffineTransformIdentity;
                        else
                            self.menuView.menuWrapperView.transform = CGAffineTransformMakeScale(kRGFlipMenuBackScale, kRGFlipMenuBackScale);
                        
                    } completion:nil];
}


# pragma mark - Private

# pragma mark - Initializer - Private

- (instancetype)initWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu actionBlock:(RGFlipMenuActionBlock)theActionBlock menuText:(NSString *)theMenuText {
    
    self = [super init];
    if (self) {
        _subMenus = theSubMenus;
        _superMenu = theSuperMenu;
        _actionBlock = theActionBlock;
        _menuText =theMenuText;
        _closed = YES;
    }
    return self;
}


@end
