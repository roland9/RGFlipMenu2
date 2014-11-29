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

    NSArray *subMenus = @[
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:self.flipMenu menuText:@"Option 1" menuBounds:self.view.bounds],

                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:self.flipMenu menuText:@"Option 2" menuBounds:self.view.bounds],
                          
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
    
    RGFlipMenuView *flipMenuView = self.flipMenu.menuView;
//    flipMenuView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2f];
    
    [self.view addSubview:flipMenuView];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.flipMenu.menuView.frame = self.view.frame;
}

@end
