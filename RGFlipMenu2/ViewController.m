//
//  ViewController.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "ViewController.h"
#import "RGFlipMenu.h"
#import "RGFlipMenuView.h"
#import <FrameAccessor/FrameAccessor.h>

@interface ViewController ()
@property (nonatomic, strong) RGFlipMenu *flipMenu;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create main menu
    self.flipMenu = [RGFlipMenu createWithActionBlock:^(id me) {
        NSLog(@"tapped main menu");
        NSLog(@"main menu closed=%@", self.flipMenu.isClosed ? @"YES" : @"NO");

    } menuText:@"Main Menu"];
    
    // create sub menus
    NSArray *subSubMenus2 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Radio Button 1");
                              }  menuText:@"Radio\nButton 1"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Radio Button 2");
                              }  menuText:@"Radio\nButton 2"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Radio Button 3");
                              }  menuText:@"Radio\nButton 3"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Radio Button 4");
                              }  menuText:@"Radio\nButton 4"],
                              ];
    NSArray *subSubMenus3 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 3-1");
                              }  menuText:@"Suboption 3-1"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 3-2");
                              }  menuText:@"Suboption 3-2"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 3-3");
                              }  menuText:@"Suboption 3-3"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 3-4");
                              }  menuText:@"Suboption 3-4"],
                              ];
    NSArray *subSubMenus4 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 4-1");
                              } menuText:@"Suboption 4-1"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 4-2");
                              } menuText:@"Suboption 4-2"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 4-3");
                              } menuText:@"Suboption 4-3"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  NSLog(@"Suboption 4-4");
                              }  menuText:@"Suboption 4-4"],
                              ];
    
    NSArray *subMenus = @[
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 1");
                          } menuText:@"Tap\nOnly"],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 2");
                          } menuText:@"Radio\nButtons"],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 3");
                          } menuText:@"Option 3"],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 4");
                          } menuText:@"Option 4"],
                          
                          ];
    
    // assign sub menus to main menu
    self.flipMenu.subMenus = subMenus;
    
    // assign sub-sub menus
    ((RGFlipMenu *)self.flipMenu.subMenus[1]).subMenus = subSubMenus2;
    ((RGFlipMenu *)self.flipMenu.subMenus[2]).subMenus = subSubMenus3;
    ((RGFlipMenu *)self.flipMenu.subMenus[3]).subMenus = subSubMenus4;

    // assign colour classes to all menus to determine what colours are used (note BE and AE spelling here...)
    self.flipMenu.flipMenuColorClass = NSClassFromString(@"RGFlipMenuColors");
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        subMenu.flipMenuColorClass = NSClassFromString(@"RGFlipMenuColors");
    }];
    
    // need to change the menuType AFTER we set the colorClasses for this menu; or even better: have a appropriate fallback colorClass
    ((RGFlipMenu *)self.flipMenu.subMenus[1]).menuType = RGFlipMenuTypeRadioButtons;

    // finally add the menu to the view hierarchy
    [self.view insertSubview:self.flipMenu.menuView atIndex:0];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (isIPad) {
        self.flipMenu.menuView.frame = CGRectInset(self.view.frame, 200, 200);
    } else {
        self.flipMenu.menuView.frame = self.view.frame;
    }
    [self.flipMenu.menuView repositionViews];
}

@end