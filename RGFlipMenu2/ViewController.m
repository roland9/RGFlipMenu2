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

@interface ViewController ()
@property (nonatomic, strong) RGFlipMenu *flipMenu;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.flipMenu = [RGFlipMenu createWithSubMenus:nil superMenu:nil menuText:@"Main Menu" menuBounds:self.view.bounds];
    self.flipMenu.rgFlipMenuColorClass = NSClassFromString(@"RGFlipMenuColors");

    NSArray *subSubMenus2 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 1" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 2" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 3" menuBounds:self.view.bounds],
                              ];
    NSArray *subSubMenus3 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 1" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 2" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 3" menuBounds:self.view.bounds],
                              ];
    NSArray *subSubMenus4 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 1" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 2" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 3" menuBounds:self.view.bounds],
                              ];
    NSArray *subSubMenus5 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 1" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 2" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 3" menuBounds:self.view.bounds],
                              ];
    NSArray *subSubMenus6 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 1" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 2" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 3" menuBounds:self.view.bounds],
                              ];
    NSArray *subSubMenus7 = @[
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 1" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 2" menuBounds:self.view.bounds],
                              [RGFlipMenu createWithActionBlock:^(id me) {
                                  //
                              } superMenu:self.flipMenu menuText:@"Suboption 3" menuBounds:self.view.bounds],
                              ];

    
    NSArray *subMenus = @[
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              NSLog(@"ping");
                          } superMenu:self.flipMenu menuText:@"Tap\nOnly" menuBounds:self.view.bounds],

                          [RGFlipMenu createWithSubMenus:subSubMenus2 superMenu:self.flipMenu menuText:@"Options 2" menuBounds:self.view.bounds],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:self.flipMenu menuText:@"Option 3" menuBounds:self.view.bounds],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:self.flipMenu menuText:@"Option 4" menuBounds:self.view.bounds],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:self.flipMenu menuText:@"Option 5" menuBounds:self.view.bounds],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:self.flipMenu menuText:@"Option 6" menuBounds:self.view.bounds],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:self.flipMenu menuText:@"Option 7" menuBounds:self.view.bounds],
                          ];
    
    self.flipMenu.subMenus = subMenus;
    ((RGFlipMenu *)self.flipMenu.subMenus[1]).subMenus = subSubMenus2;
    ((RGFlipMenu *)self.flipMenu.subMenus[2]).subMenus = subSubMenus3;
    ((RGFlipMenu *)self.flipMenu.subMenus[3]).subMenus = subSubMenus4;
    ((RGFlipMenu *)self.flipMenu.subMenus[4]).subMenus = subSubMenus5;
    ((RGFlipMenu *)self.flipMenu.subMenus[5]).subMenus = subSubMenus6;
    ((RGFlipMenu *)self.flipMenu.subMenus[6]).subMenus = subSubMenus7;
    
    RGFlipMenuView *flipMenuView = self.flipMenu.menuView;
//    flipMenuView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2f];
    
    [self.view addSubview:flipMenuView];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.flipMenu.menuView.frame = self.view.frame;
}

@end
