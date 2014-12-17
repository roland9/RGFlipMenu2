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

@property (nonatomic, copy) RGFlipMenuActionBlock actionBlock;
@property (nonatomic, strong) RGFlipMenuView *menuView;

@end

#define kRGAnimationDuration 0.7f


@implementation RGFlipMenu

# pragma mark - Public Factories

// create instance with sub menus
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText {
    
    return [[RGFlipMenu alloc] initWithSubMenus:theSubMenus superMenu:theSuperMenu actionBlock:nil menuText:theMenuText];
}

// create instance as leaf (no submenus) but action block instead
+ (instancetype)createWithActionBlock:(RGFlipMenuActionBlock)theActionBlock superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText {
    
    return [[RGFlipMenu alloc] initWithSubMenus:nil superMenu:theSuperMenu actionBlock:theActionBlock menuText:theMenuText];
}


# pragma mark - Accessors

- (RGFlipMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[RGFlipMenuView alloc] initWithFlipMenu:self];
    }
    return _menuView;
}

- (void)setHideToShowSibling:(BOOL)hideToShowSibling {
    _hideToShowSibling = hideToShowSibling;
    self.menuView.alpha = hideToShowSibling ? 0.f : 1.f;
    
#warning todoRG maybe here I should move it off the screen - so we can animate them in again when closing the submenu?
    if (hideToShowSibling) {
        self.menuView.layer.transform = CATransform3DMakeScale(0.1f, 0.1f, 0.1f);
    } else {
        self.menuView.layer.transform = CATransform3DIdentity;
    }
}


- (void)popToRoot {
    if (!self.isClosed) {
        [self didTapMenu:nil];
    }
}

#define isLandscape  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
#define kRGFlipMenuBackScale 0.6f


# pragma mark - User Action

- (void)didTapMenu:(id)sender {
    
    [self flipMenuView:self];

    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.menuView repositionViews];
    } completion:nil];

    if (self.actionBlock) {
        self.actionBlock(self);
    }
}


- (void)didTapSubMenu:(RGFlipMenu *)theSubMenu {
    
    // if no submenus to show: shrink and unshrink
    if (!theSubMenu.subMenus) {
        [UIView animateWithDuration:0.1f animations:^{
            theSubMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1f animations:^{
                theSubMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                if (theSubMenu.actionBlock) {
                    theSubMenu.actionBlock(self);
                }
            }];
        }];
        
    } else {
        
        // handle repositioning of main menu
        if (!self.isClosed) {
            
            [self hideSubMenusToShowSubMenu:theSubMenu];
            
        } else {
            
            [self showAndResizeWithSubMenuToBeClosed:theSubMenu];
        }
        
//        // move up and hide or show submenus
//        [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//            [self closeAllSubMenus];
//            
//            [self.menuView repositionSubViews];
//            
//        } completion:^(BOOL finished) {
//        }];
        
    }
}


- (void)flipMenuView:(RGFlipMenu *)theMenu {
    
    // toggle status
    theMenu.closed = !theMenu.isClosed;
    
    // hide label -> once the 'backside' of the view is shown, it will be hidden
    if (theMenu.closed) {
        [theMenu.menuView showMenuLabel];
    } else {
        [theMenu.menuView hideMenuLabel];
    }
    
    // flip menu
    [UIView transitionWithView:theMenu.menuView.menuWrapperView
                      duration:kRGAnimationDuration/3.f
                       options: (isLandscape ?
                                 (theMenu.isClosed ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight) :
                                 (theMenu.isClosed ? UIViewAnimationOptionTransitionFlipFromBottom : UIViewAnimationOptionTransitionFlipFromTop)
                                 ) | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        
                        if (theMenu.closed)
                            theMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
                        else
                            theMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(kRGFlipMenuBackScale, kRGFlipMenuBackScale, kRGFlipMenuBackScale);
                        
                    } completion:nil];

}


- (void)hideSubMenusToShowSubMenu:(RGFlipMenu *)theSubMenuToShow {
    
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{

        // hide the back button from main menu
        self.menuView.menuWrapperView.alpha = 0.f;
        
        // hide & shrink other submenus
        for (RGFlipMenu *subMenu in self.subMenus) {
            if (subMenu != theSubMenuToShow) {
                subMenu.menuView.alpha = 0.f;
                subMenu.menuView.layer.transform = CATransform3DMakeScale(kRGFlipMenuBackScale, kRGFlipMenuBackScale, kRGFlipMenuBackScale);
                subMenu.hideToShowSibling = YES;
            }
        }
        
        // show selected subMenu
        [self.menuView showSubMenu:theSubMenuToShow];
        
//        [self flipMenuView:theSubMenuToShow];
        
//        [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//            [theSubMenuToShow.menuView repositionViews];
//        } completion:nil];
        
    } completion:nil];
}


- (void)showAndResizeWithSubMenuToBeClosed:(RGFlipMenu *)theSubMenuToBeClosed {
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{

        [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            subMenu.hideToShowSibling = NO;
        }];
        
        // show the back button from parent menu
        self.menuView.menuWrapperView.alpha = 1.f;
        [theSubMenuToBeClosed.menuView repositionViews];
        
    } completion:nil];
}

# pragma mark - Private

- (void)closeAllSubMenus {
    [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        if (!subMenu.isClosed) {
            [subMenu didTapMenu:self];
        }
        if (subMenu.isHiddenToShowSibling) {
            subMenu.hideToShowSibling = NO;
        }
    }];
}

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
