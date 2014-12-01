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
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {
    
    return [[RGFlipMenu alloc] initWithSubMenus:theSubMenus superMenu:theSuperMenu actionBlock:nil menuText:theMenuText];
}

// create instance as leaf (no submenus) but action block instead
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


#define isLandscape  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
#define kRGFlipMenuBackScale 0.6f


# pragma mark - User Action

- (void)didTapMenu:(id)sender {
    
    if (self.actionBlock) {
        self.actionBlock(self);
    }
    
    if (!self.subMenus) {
        [UIView animateWithDuration:0.2f animations:^{
            self.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f animations:^{
                self.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
            }];
        }];
        return;
    }
    
    self.closed = !self.isClosed;
    
    if (self.superMenu) {
        if (!self.isClosed) {
            [self.superMenu hideAndResizeToShowSubMenu:self];
        } else {
            [self.superMenu showAndResizeWithSubMenuToBeClosed:self];
        }
    }
    
    // move up and hide or show submenus
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self closeAllSubMenus];
        
        [self.menuView repositionSubViews];
        
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
                            self.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
                        else
                            self.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(kRGFlipMenuBackScale, kRGFlipMenuBackScale, kRGFlipMenuBackScale);
                        
                    } completion:nil];
}


- (void)hideAndResizeToShowSubMenu:(RGFlipMenu *)theSubMenuToShow {
    
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{

        [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            subMenu.hideToShowSibling = (subMenu!=theSubMenuToShow);
        }];
        
        // hide the back button from parent menu
        self.menuView.menuWrapperView.alpha = 0.f;
        
//        [theSubMenuToShow.menuView setNeedsLayout];
        // set frame to force layout again - why does setneedslayout not work here?
        theSubMenuToShow.menuView.frame = CGRectMake(0, 0, 320, 320);
        
    } completion:nil];
}


- (void)showAndResizeWithSubMenuToBeClosed:(RGFlipMenu *)theSubMenuToBeClosed {
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{

        [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            subMenu.hideToShowSibling = NO;
        }];
        
        // show the back button from parent menu
        self.menuView.menuWrapperView.alpha = 1.f;

        theSubMenuToBeClosed.menuView.frame = CGRectMake(0, 0, 320, 320);
        
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
