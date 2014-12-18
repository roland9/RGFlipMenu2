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


- (void)popToRoot {
    if (!self.isClosed) {
        [self handleTapMenu:nil];
    }
}


# pragma mark - RGFlipMenuTapProtocol

- (void)handleTapMenu:(id)sender {
    
    // toggle status
    self.closed = !self.isClosed;
    
    [self.menuView flipMenu:self];

    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
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

        [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.menuView repositionViews];
        } completion:nil];
        
    }
}


# pragma mark - Private

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
            if (theSubMenu.actionBlock) {
                theSubMenu.actionBlock(self);
            }
        }];
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
