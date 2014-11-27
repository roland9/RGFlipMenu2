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
@property (nonatomic, assign, getter=isClosed) BOOL closed;
@property (nonatomic, weak) RGFlipMenu *superMenu;
@property (nonatomic, copy) RGFlipMenuActionBlock actionBlock;
@property (nonatomic, assign) CGRect menuBounds;
@property (nonatomic, strong) RGFlipMenuView *menuView;

@end

#define kRGAnimationDuration 0.5f


@implementation RGFlipMenu

# pragma mark - Public Factories

// instance with sub menus
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {

    return [[RGFlipMenu alloc] initWithSubMenus:theSubMenus superMenu:theSuperMenu actionBlock:nil menuText:theMenuText menuBounds:theMenuBounds];
}

// instance as leaf (no submenus) but action block instead
+ (instancetype)createWithActionBlock:(RGFlipMenuActionBlock)theActionBlock superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {
    
    return [[RGFlipMenu alloc] initWithSubMenus:nil superMenu:theSuperMenu actionBlock:theActionBlock menuText:theMenuText menuBounds:theMenuBounds];
}


# pragma mark - Accessors 

- (RGFlipMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[RGFlipMenuView alloc] initWithFlipMenu:self];
        _menuView.frame = self.menuBounds;
    }
    return _menuView;
}


# pragma mark - User Action

- (void)didTapMenu:(id)sender {
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

    // flip menu ...
    [UIView transitionWithView:self.menuView
                      duration:0.5f
                       options: (isLandscape ?
                                 (self.isClosed ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight) :
                                 (self.isClosed ? UIViewAnimationOptionTransitionFlipFromBottom : UIViewAnimationOptionTransitionFlipFromTop)
                                 ) | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction
                    animations:^{
                        [self positionMenuView:self.menuView wasClosed:self.isClosed];
                    } completion:^(BOOL finished) {
                        self.closed = !self.isClosed;
                    }];

    // ... move up and hide or show submenus
    [UIView animateWithDuration:kRGAnimationDuration delay:0.f usingSpringWithDamping:0.1f initialSpringVelocity:0.4f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self positionSubviewsWithMenuClosed:YES];
    } completion:nil];
    

}


# pragma mark - Private

- (void)positionMenuView:(RGFlipMenuView *)theMenuView wasClosed:(BOOL)wasClosed {
    if (wasClosed) {
        theMenuView.transform = CGAffineTransformMakeTranslation(0, -300);
    } else {
        theMenuView.transform = CGAffineTransformIdentity;
    }
}

- (void)positionSubviewsWithMenuClosed:(BOOL)wasMenuClosed {
    
    if (wasMenuClosed) {
        // menu was close whan user tapped -> show submenus
        
    } else {
        
        // hide submenus
        [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            NSLog(@"subMenuView=%@", subMenu.menuView);
        }];
    }
}


# pragma mark - Initializer - Private

- (instancetype)initWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu actionBlock:(RGFlipMenuActionBlock)theActionBlock menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {

    self = [super init];
    if (self) {
        _subMenus = theSubMenus;
        _superMenu = theSuperMenu;
        _actionBlock = theActionBlock;
        _menuText =theMenuText;
        _menuBounds = theMenuBounds;
        _closed = YES;
    }
    return self;
}


@end
