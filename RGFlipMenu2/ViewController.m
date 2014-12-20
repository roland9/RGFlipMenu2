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
    // Do any additional setup after loading the view, typically from a nib.
    
    self.flipMenu = [RGFlipMenu createWithActionBlock:^(id me) {
        NSLog(@"tapped main menu");
    } menuText:@"Main Menu"];
    self.flipMenu.rgFlipMenuColorClass = NSClassFromString(@"RGFlipMenuColors");
    
    NSArray *subSubMenus2 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 2-1"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 2-2"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 2-3"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 2-4"],
                              ];
    NSArray *subSubMenus3 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 3-1"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 3-2"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 3-3"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 3-4"],
                              ];
    NSArray *subSubMenus4 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } menuText:@"Suboption 4-1"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } menuText:@"Suboption 4-2"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } menuText:@"Suboption 4-3"],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              }  menuText:@"Suboption 4-4"],
                              ];
    
    NSArray *subMenus = @[
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 1");
                          } menuText:@"Tap\nOnly"],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 2");
                          } menuText:@"Options 2"],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 3");
                          } menuText:@"Option 3"],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"tapped menu 4");
                          } menuText:@"Option 4"],
                          
                          ];
    
    self.flipMenu.subMenus = subMenus;
    ((RGFlipMenu *)self.flipMenu.subMenus[1]).subMenus = subSubMenus2;
    ((RGFlipMenu *)self.flipMenu.subMenus[2]).subMenus = subSubMenus3;
    ((RGFlipMenu *)self.flipMenu.subMenus[3]).subMenus = subSubMenus4;

    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        [subMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            subMenu.rgFlipMenuColorClass = NSClassFromString(@"RGFlipSubMenuColors");
        }];
    }];
    

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
