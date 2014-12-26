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

- (void)setMenuType:(RGFlipMenuType)menuType {
    _menuType = menuType;
    // if we change the type to radioButtons, the menu itself finds the initially selected subMenu -> the first one
    if (menuType == RGFlipMenuTypeRadioButtons) {
        NSAssert([self.subMenus count]>1, @"need at least two subMenus to work with radio button type");
        ((RGFlipMenu *)self.subMenus[0]).radioButtonSelected = YES;
    }
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
    
    self.closed = !self.isClosed;
    
    [self updateSubMenus:self.subMenus closed:self.closed];
    
    [self.menuView flipMenu:self];
    
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:kRGAnimationDamping initialSpringVelocity:kRGAnimationVelocity options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.menuView repositionViews];
    } completion:nil];
    
    if (self.actionBlock) {
        self.actionBlock(self);
    }
}


- (void)handleTapSubMenu:(RGFlipMenu *)theSubMenu {
    
    if (!theSubMenu.subMenus && theSubMenu.superMenu.menuType == RGFlipMenuTypeNormal) {
        
        // we have no subMenus to show && typeNormal: shrink and unshrink this menu to visualize tap
        [theSubMenu.menuView animateTap];

        // because this does not toggle, execute the action block every time
        if (theSubMenu.actionBlock) {
            theSubMenu.actionBlock(self);
        }

    } else if (!theSubMenu.subMenus && theSubMenu.superMenu.menuType == RGFlipMenuTypeRadioButtons) {

        // we have no subMenus to show && typeRadioButtons: all the menus on this level function as radio buttons: always one is active; selecting another subMenu unselects others
        if (!theSubMenu.isRadioButtonSelected) {
            theSubMenu.radioButtonSelected = YES;
            [self unselectOtherSubMenusWithSubMenuNowSelected:theSubMenu];
            [theSubMenu.menuView animateRadioButtonWithRadioButtonSelected:YES];
            if (theSubMenu.actionBlock) {
                theSubMenu.actionBlock(self);
            }
        }

    } else if (theSubMenu.subMenus && theSubMenu.superMenu.menuType == RGFlipMenuTypeNormal) {
        
        // we have submenus to show && superMenu is type normal: open submenus & toggle status
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
        
        [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:kRGAnimationDamping initialSpringVelocity:kRGAnimationVelocity options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.menuView repositionViews];
        } completion:nil];
        
    } else {
        NSAssert(NO, @"menuType / subMenus not implemented yet");
    }
    
}


# pragma mark - Private

- (void)unselectOtherSubMenusWithSubMenuNowSelected:(RGFlipMenu *)theSelectedMenu {
    NSArray *allSubMenus = [theSelectedMenu.superMenu subMenus];
    [allSubMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        if (subMenu != theSelectedMenu && subMenu.isRadioButtonSelected) {
            subMenu.radioButtonSelected = NO;
            [subMenu.menuView animateRadioButtonWithRadioButtonSelected:NO];
        }
    }];
}


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
