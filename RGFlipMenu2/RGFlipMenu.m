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


@implementation RGFlipMenu

# pragma mark - Public Factories

// create instance with sub menus
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus menuText:(NSString *)theMenuText {
    
    return [[RGFlipMenu alloc] initWithSubMenus:theSubMenus actionBlock:nil menuText:theMenuText];
}

// create instance as leaf (no submenus) but action block instead
+ (instancetype)createWithActionBlock:(RGFlipMenuActionBlock)theActionBlock menuText:(NSString *)theMenuText {
    
    return [[RGFlipMenu alloc] initWithSubMenus:nil actionBlock:theActionBlock menuText:theMenuText];
}


#pragma - Public

- (BOOL)isSubMenuOpen {
    return [self.subMenus indexOfObjectPassingTest:^BOOL(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        return !subMenu.isClosed;
    }] != NSNotFound;
}

# pragma mark - Accessors

- (RGFlipMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[RGFlipMenuView alloc] initWithFlipMenu:self];
    }
    return _menuView;
}

- (void)setClosed:(BOOL)closed {
    _closed = closed;
    if (closed) {
        [self.menuView showMenuLabel];
    } else
        [self.menuView hideMenuLabel];
}

// when we set the subMenus, ensure we set the superMenu to self
- (void)setSubMenus:(NSArray *)subMenus {
    _subMenus = subMenus;
    [_subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        subMenu.superMenu = self;
    }];
}

- (void)popToRoot {
    if (!self.isClosed) {
        [self handleTapMenu:nil];
    }
}


# pragma mark - RGFlipMenuTapProtocol

- (void)handleTapMenu:(id)sender {
    
    // toggle status
    self.closed = !self.isClosed;
    NSLog(@"main menu closed=%@", self.closed ? @"YES" : @"NO");
    
    [self updateSubMenus:self.subMenus closed:self.closed];
    
    [self.menuView flipMenu:self];

    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:kRGAnimationDamping initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.menuView repositionViews];
    } completion:nil];

    if (self.actionBlock) {
        self.actionBlock(self);
    }
}


- (void)handleTapSubMenu:(RGFlipMenu *)theSubMenu {
    
    // if no submenus to show: shrink and unshrink
    if (!theSubMenu.subMenus) {
        
        [self animateTapWithSubmenu:theSubMenu];
        // because this does not toggle, execute the action block every time
        if (theSubMenu.actionBlock) {
            theSubMenu.actionBlock(self);
        }
        
    } else {
        
        // we have submenus to show:
        
        // toggle status
        theSubMenu.closed = !theSubMenu.isClosed;
        
        [self updateSubMenus:theSubMenu.subMenus closed:theSubMenu.isClosed];

        if (!theSubMenu.isClosed) {
            [self hideOtherSubMenusToShow:theSubMenu];
        } else {
            [self showAllSubMenus];
        }
        
        [self.menuView flipMenu:theSubMenu];

        // this subMenu toggles -> execute the action block only when opening
        if (!theSubMenu.isClosed && theSubMenu.actionBlock) {
            theSubMenu.actionBlock(self);
        }

        [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:kRGAnimationDamping initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.menuView repositionViews];
        } completion:nil];
        
    }
}


# pragma mark - Private

- (void)updateSubMenus:(NSArray *)theSubMenus closed:(BOOL)isClosed {
    [theSubMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        // if menu is closed, close all the subMenus as well
        if (isClosed) {
            subMenu.closed = YES;
            subMenu.hideToShowSibling = NO;
            [subMenu showAllSubMenus];
            
            [self updateSubMenus:subMenu.subMenus closed:isClosed];
        }
    }];
}


- (void)showAllSubMenus {
    
    [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        subMenu.closed = YES;
        subMenu.hideToShowSibling = NO;
    }];
}


- (void)hideOtherSubMenusToShow:(RGFlipMenu *)theSubMenuToShow {

    [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        if (subMenu != theSubMenuToShow) {
            subMenu.closed = YES;
            subMenu.hideToShowSibling = YES;
        }
    }];
}


- (void)animateTapWithSubmenu:(RGFlipMenu *)theSubMenu {
    [UIView animateWithDuration:0.1f animations:^{
        theSubMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f animations:^{
            theSubMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
        }];
    }];
}


# pragma mark - Initializer - Private

- (instancetype)initWithSubMenus:(NSArray *)theSubMenus actionBlock:(RGFlipMenuActionBlock)theActionBlock menuText:(NSString *)theMenuText {
    
    self = [super init];
    if (self) {
        _subMenus = theSubMenus;
        [_subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            subMenu.superMenu = self;
        }];
        _actionBlock = theActionBlock;
        _menuText =theMenuText;
        _closed = YES;
    }
    return self;
}


@end
