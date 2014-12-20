//
//  RGFlipMenu.h
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define isLandscape  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
#define isIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kRGFlipMenuBackScale 0.7f
#define kRGAnimationDuration 0.6f
#define kRGAnimationDamping  0.5f

#define kRGFlipMenuWidth        150
#define kRGFlipMenuHeight       150
#define kRGFlipSubMenuWidth     120
#define kRGFlipSubMenuHeight    120

#define kRGFlipMenuPadding      (isIPad ? 200.f : 30.f)

typedef void (^RGFlipMenuActionBlock)(id me);

@class RGFlipMenuView, RGFlipMenu;

@protocol RGFlipMenuTapProtocol <NSObject>
- (void)handleTapMenu:(id)sender;
- (void)handleTapSubMenu:(RGFlipMenu *)theSubMenu;
@end


@interface RGFlipMenu : NSObject <RGFlipMenuTapProtocol>

@property (nonatomic, weak) RGFlipMenu *superMenu;
@property (nonatomic, strong) NSArray *subMenus;
@property (nonatomic, readonly) RGFlipMenuView *menuView;
@property (nonatomic, copy) NSString *menuText;
@property (nonatomic, assign, getter=isClosed) BOOL closed;
@property (nonatomic, assign, getter=isHiddenToShowSibling) BOOL hideToShowSibling;
@property (nonatomic, copy) Class rgFlipMenuColorClass;

// instance with sub menus
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus menuText:(NSString *)theMenuText;

// instance as leaf (no submenus) but action block instead
+ (instancetype)createWithActionBlock:(RGFlipMenuActionBlock)theActionBlock menuText:(NSString *)theMenuText;

- (BOOL)isSubMenuOpen;
- (void)popToRoot;

@end
