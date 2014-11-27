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
    
    NSArray *subMenus = @[
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:nil menuText:@"Option 1" menuBounds:self.view.bounds],

                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:nil menuText:@"Option 2" menuBounds:self.view.bounds],
                          
                          [RGFlipMenu createWithActionBlock:^(id me) {
                              //
                          } superMenu:nil menuText:@"Option 3" menuBounds:self.view.bounds],
                          
                          ];
    
    self.flipMenu = [RGFlipMenu createWithSubMenus:subMenus superMenu:nil menuText:@"Main Menu" menuBounds:self.view.bounds];
    
    RGFlipMenuView *flipMenuView = self.flipMenu.menuView;
    
    [self.view addSubview:flipMenuView];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.flipMenu.menuView.frame = self.view.frame;
    [self.flipMenu.menuView setNeedsLayout];
}

@end
