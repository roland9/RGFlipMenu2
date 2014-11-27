//
//  RGFlipMenuView.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "RGFlipMenuView.h"

#define kRGFlipMenuWidth    180
#define kRGFlipMenuHeight   180

@interface RGFlipMenuView ()

@property (nonatomic, weak) RGFlipMenu *flipMenu;
@property (nonatomic, strong) UIView *menuBackground;
@property (nonatomic, strong) UILabel *menuLabel;

@end


@implementation RGFlipMenuView

- (instancetype)initWithFlipMenu:(RGFlipMenu *)theFlipMenu {
    self = [super init];
    if (self) {
        _flipMenu = theFlipMenu;
        _menuBackground = [[UIView alloc] init];
        _menuBackground.backgroundColor = [UIColor blueColor];
        _menuLabel = [[UILabel alloc] init];
        _menuLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuLabel.textAlignment = NSTextAlignmentCenter;
        _menuLabel.text = theFlipMenu.menuText;
        [self addSubview:_menuBackground];
        [self addSubview:_menuLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMenu:)];
        [_menuBackground addGestureRecognizer:tap];

    }
    return self;
}


- (void)didTapMenu:(id)sender {
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"inconsistent");
    NSLog(@"bla");

    [self.flipMenu didTapMenu:self];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.menuBackground.center = self.center;
    self.menuBackground.bounds = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
    self.menuLabel.bounds = self.menuBackground.bounds;
    self.menuLabel.center = self.center;
}

@end
