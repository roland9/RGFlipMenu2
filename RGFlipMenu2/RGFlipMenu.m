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


@implementation RGFlipMenu

// instance with sub menus
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {

    return [[RGFlipMenu alloc] initWithSubMenus:theSubMenus superMenu:theSuperMenu actionBlock:nil menuText:theMenuText menuBounds:theMenuBounds];
}

// instance as leaf (no submenus) but action block instead
+ (instancetype)createWithActionBlock:(RGFlipMenuActionBlock)theActionBlock superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {
    
    return [[RGFlipMenu alloc] initWithSubMenus:nil superMenu:theSuperMenu actionBlock:theActionBlock menuText:theMenuText menuBounds:theMenuBounds];
}


- (RGFlipMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[RGFlipMenuView alloc] initWithFlipMenu:self];
        _menuView.frame = self.menuBounds;
    }
    return _menuView;
}


- (void)didTapMenu:(id)sender {
    
    // flip
    [UIView transitionWithView:self.menuView
                      duration:0.5f
                       options: //(isLandscape ?
                                (self.isClosed ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight) // :
//                                (mainMenu.isMenuClosed ? UIViewAnimationOptionTransitionFlipFromBottom : UIViewAnimationOptionTransitionFlipFromTop)
//                                ) | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction
                    animations:^{
                    } completion:^(BOOL finished) {
                        self.closed = !self.isClosed;
                    }];

    if (self.isClosed) {
        // hide submenus
        
    } else {
        
        // show submenus
        [self.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            NSLog(@"subMenuView=%@", subMenu.menuView);
        }];
    }
}


# pragma mark - Private

- (instancetype)initWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu actionBlock:(RGFlipMenuActionBlock)theActionBlock menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds {

    self = [super init];
    if (self) {
        _subMenus = theSubMenus;
        _superMenu = theSuperMenu;
        _actionBlock = theActionBlock;
        _menuText =theMenuText;
        _menuBounds = theMenuBounds;
    }
    return self;
}


@end
