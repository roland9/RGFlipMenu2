//
//  RGFlipMenu.h
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^RGFlipMenuActionBlock)(id me);

@class RGFlipMenuView;

@protocol RGFlipMenuTapProtocol <NSObject>
- (void)didTapMenu:(id)sender;
@end


@interface RGFlipMenu : NSObject <RGFlipMenuTapProtocol>

@property (nonatomic, weak) RGFlipMenu *superMenu;
@property (nonatomic, strong) NSArray *subMenus;
@property (nonatomic, readonly) RGFlipMenuView *menuView;
@property (nonatomic, copy) NSString *menuText;
@property (nonatomic, assign, getter=isClosed) BOOL closed;

// instance with sub menus
+ (instancetype)createWithSubMenus:(NSArray *)theSubMenus superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds;

// instance as leaf (no submenus) but action block instead
+ (instancetype)createWithActionBlock:(RGFlipMenuActionBlock)theActionBlock superMenu:(RGFlipMenu *)theSuperMenu menuText:(NSString *)theMenuText menuBounds:(CGRect)theMenuBounds;

@end
