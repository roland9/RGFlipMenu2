//
//  RGFlipMenuView.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 26/11/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "RGFlipMenuView.h"
#import "FrameAccessor.h"
#import "RGFlipMenu.h"


@interface RGFlipMenuView ()

@property (nonatomic, weak) RGFlipMenu *flipMenu;
@property (nonatomic, strong) UILabel *menuFrontLabel;
@property (nonatomic, strong) UILabel *menuBackLabel;
@property (nonatomic, strong) UIView *subMenuContainerView;

@end


@implementation RGFlipMenuView

- (instancetype)initWithFlipMenu:(RGFlipMenu *)theFlipMenu {
    self = [super init];
    if (self) {
        
        _flipMenu = theFlipMenu;
        
        _subMenuContainerView = [UIView new];
        _subMenuContainerView.userInteractionEnabled = NO;
        [self addSubview:_subMenuContainerView];

        [theFlipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            RGFlipMenuView *subMenuView = subMenu.menuView;
            [_subMenuContainerView addSubview:subMenuView];
        }];
        
        _menuWrapperView = [[UIView alloc] init];
        [self addSubview:_menuWrapperView];
        
        
        _menuFrontLabel = [[UILabel alloc] init];
        _menuFrontLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuFrontLabel.textAlignment = NSTextAlignmentCenter;
        _menuFrontLabel.text = theFlipMenu.menuText;
        _menuFrontLabel.numberOfLines = 2;
        _menuFrontLabel.layer.cornerRadius = 5.f;
        _menuFrontLabel.layer.masksToBounds = YES;
        [_menuWrapperView addSubview:_menuFrontLabel];
        
        _menuBackLabel = [[UILabel alloc] init];
        _menuBackLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        _menuBackLabel.textAlignment = NSTextAlignmentCenter;
        _menuBackLabel.text = NSLocalizedString(@"Back\nin menu", @"Back in card backside menu");
        _menuBackLabel.numberOfLines = 2;
        _menuBackLabel.userInteractionEnabled = NO;
        _menuBackLabel.layer.cornerRadius = 5.f;
        _menuBackLabel.layer.masksToBounds = YES;
        [_menuWrapperView addSubview:_menuBackLabel];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _menuFrontLabel.backgroundColor = [[self colorClass] performSelector:@selector(frontColor)];
        _menuFrontLabel.textColor = [[self colorClass] performSelector:@selector(frontTextColor)];
        _menuBackLabel.backgroundColor = [[self colorClass] performSelector:@selector(backColor)];
        _menuBackLabel.textColor = [[self colorClass] performSelector:@selector(backTextColor)];
#pragma clang diagnostic pop
        
        _menuBackLabel.alpha = 0.f;
    }
    return self;
}


- (void)didMoveToSuperview {
    if (self.superview) {
        
        // add the tap gesture recognizer only for the root menu
        // we have to add it to the superview because it will be moved aside when a menu is tapped, thus blocking taps on outside menus
        if (!_flipMenu.superMenu) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMenu:)];
            [self.superview addGestureRecognizer:tap];
        }

    }
}


- (void)didTapMenu:(id)sender {
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"inconsistent");
    
    UITapGestureRecognizer *tap = sender;
    CGPoint tapPoint = [tap locationInView:self.menuWrapperView];
    if (CGRectContainsPoint(self.menuFrontLabel.frame, tapPoint) && !self.flipMenu.isSubMenuOpen) {
        [self.flipMenu handleTapMenu:self];
        return;
    }
    
    [self performTapOnSubMenusWithTapPoint:tapPoint];
}


- (void)performTapOnSubMenusWithTapPoint:(CGPoint)tapPoint {
    __block BOOL found = NO;
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        
        if (subMenu.isHiddenToShowSibling) {
            return;
        }

        CGPoint tapPointConverted = [self.menuWrapperView convertPoint:tapPoint toView:subMenu.menuView.menuWrapperView];
        
        if (CGRectContainsPoint(subMenu.menuView.menuFrontLabel.frame, tapPointConverted)) {
            
            found = YES;
            *stop = YES;
            [self.flipMenu handleTapSubMenu:subMenu];
        }
    }];
    
    if (!found) {
        [self performTapOnSubSubMenusWithTapPoint:tapPoint];
    }
}


- (void)performTapOnSubSubMenusWithTapPoint:(CGPoint)tapPoint {
    __block BOOL found = NO;
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
        
        [subMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx, BOOL *stop) {
            if (subMenu.isHiddenToShowSibling) {
                return;
            }
            CGPoint tapPointConverted = [self.menuWrapperView convertPoint:tapPoint toView:subMenu.menuView.menuWrapperView];
            
            if (CGRectContainsPoint(subMenu.menuView.menuFrontLabel.frame, tapPointConverted)) {
                
                found = YES;
                *stop = YES;
                [self.flipMenu handleTapSubMenu:subMenu];
            }
        }];
    }];
    
    if (!found) {
        [self.flipMenu popToRoot];
    }
}

- (void)hideMenuLabel {
    self.menuFrontLabel.alpha = 0.f;
    self.menuBackLabel.alpha = 1.f;
}


- (void)showMenuLabel {
    self.menuFrontLabel.alpha = 1.f;
    self.menuBackLabel.alpha = 0.f;
}


# pragma mark - Private

- (Class)colorClass {
    return [self.flipMenu.rgFlipMenuColorClass class] ?: [self.flipMenu.superMenu.rgFlipMenuColorClass class];
}


- (CGPoint)subSubMenuCenterWithIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex subMenuContainerView:(UIView *)subMenuContainerView {
    NSUInteger maxIndex;
    if (theMaxIndex%2 == 1)
        maxIndex = theMaxIndex+1;
    else
        maxIndex = theMaxIndex;
    
    if (isLandscape) {
        
        CGPoint subMenuCenter = CGPointMake(0 + subMenuContainerView.width/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.width/maxIndex*2.f),
                                            subMenuContainerView.height*0.25f + subMenuContainerView.height*0.5f * (theIndex%2));
        return subMenuCenter;
        
    } else {
        
        CGPoint subMenuCenter = CGPointMake(subMenuContainerView.width*0.25f + subMenuContainerView.width*0.5f * (theIndex%2),
                                            subMenuContainerView.height/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.height/maxIndex*2.f));
        return subMenuCenter;
    }
}


- (CGPoint)subMenuCenterWithIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex subMenuContainerView:(UIView *)subMenuContainerView {
    NSUInteger maxIndex;
    if (theMaxIndex%2 == 1)
        maxIndex = theMaxIndex+1;
    else
        maxIndex = theMaxIndex;
    
    if (isLandscape) {
        
        CGPoint subMenuCenter = CGPointMake(0 + subMenuContainerView.width/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.width/maxIndex*2.f),
                                            subMenuContainerView.height*0.25f + subMenuContainerView.height*0.5f * (theIndex%2));
        return subMenuCenter;
        
    } else {
        
        CGPoint subMenuCenter = CGPointMake(subMenuContainerView.width*0.25f + subMenuContainerView.width*0.5f * (theIndex%2),
                                            subMenuContainerView.height/maxIndex + floor(theIndex/2.f) * (subMenuContainerView.height/maxIndex*2.f));
        return subMenuCenter;
    }
}


- (void)flipMenu:(RGFlipMenu *)theFlipMenu {
    
    // hide label -> once the 'backside' of the view is shown, it will be hidden
    if (theFlipMenu.closed) {
        [theFlipMenu.menuView showMenuLabel];
    } else {
        [theFlipMenu.menuView hideMenuLabel];
    }
    
    [UIView transitionWithView:theFlipMenu.menuView.menuWrapperView
                      duration:kRGAnimationDuration/2.f
                       options: (isLandscape ?
                                 (theFlipMenu.isClosed ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight) :
                                 (theFlipMenu.isClosed ? UIViewAnimationOptionTransitionFlipFromBottom : UIViewAnimationOptionTransitionFlipFromTop)
                                 ) | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        
                        if (theFlipMenu.closed)
                            theFlipMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
                        else {
                            theFlipMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(kRGFlipMenuBackScale, kRGFlipMenuBackScale, kRGFlipMenuBackScale);
                        }
                        
                    } completion:nil];
}


# pragma mark - repositioning views; overwriting layoutSubviews() doesn't work because cannot control the animations properly

- (void)repositionSubSubMenu:(RGFlipMenu *)subSubMenu subSubMenuIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex {
    
    NSAssert(subSubMenu.superMenu, @"expected superMenu for every subMenu");
    
    if (subSubMenu.superMenu.isClosed) {
        
        // subMenu is closed -> move subSubMenu to parent's center again and shrink it/ fade it
        subSubMenu.closed = YES;
        
        subSubMenu.menuView.alpha = 0.f;
        subSubMenu.menuView.frame = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
        subSubMenu.menuView.center = [subSubMenu.superMenu.menuView convertPoint:subSubMenu.superMenu.menuView.menuWrapperView.center toView:subSubMenu.menuView];
        
        subSubMenu.menuView.menuWrapperView.frame = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
        subSubMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2);
        
        subSubMenu.menuView.menuFrontLabel.frame = CGRectMake(0, 0, kRGFlipSubMenuWidth, kRGFlipSubMenuHeight);
        subSubMenu.menuView.menuFrontLabel.center = [subSubMenu.menuView convertPoint:subSubMenu.menuView.menuWrapperView.center toView:subSubMenu.menuView.menuWrapperView];
        subSubMenu.menuView.menuBackLabel.frame = subSubMenu.menuView.menuFrontLabel.frame;
        
    } else {
        
        // subMenu is opened -> fan out subSubMenu and scale back to full size
        subSubMenu.menuView.alpha = 1.f;
        subSubMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
        
        subSubMenu.menuView.frame = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
        subSubMenu.menuView.center = [self subSubMenuCenterWithIndex:theIndex maxIndex:theMaxIndex subMenuContainerView:subSubMenu.superMenu.menuView.subMenuContainerView];;
        
    }
}


- (void)repositionSubMenu:(RGFlipMenu *)subMenu subMenuIndex:(NSUInteger)theIndex maxIndex:(NSUInteger)theMaxIndex {
    
    if (subMenu.superMenu.isClosed) {
        
        // main menu is closed -> move subMenu to center again and shrink it / fade it
        subMenu.closed = YES;
        
        subMenu.menuView.alpha = 0.f;
        subMenu.menuView.frame = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
        subMenu.menuView.center = [self.subMenuContainerView convertPoint:self.middlePoint fromView:self];
        
        subMenu.menuView.menuWrapperView.frame = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
        subMenu.menuView.menuWrapperView.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2);
        subMenu.menuView.subMenuContainerView.frame = subMenu.menuView.menuWrapperView.frame;
        
        subMenu.menuView.menuFrontLabel.frame = CGRectMake(0, 0, kRGFlipSubMenuWidth, kRGFlipSubMenuHeight);
        subMenu.menuView.menuFrontLabel.center = [subMenu.menuView convertPoint:subMenu.menuView.menuWrapperView.center toView:subMenu.menuView.menuWrapperView];
        subMenu.menuView.menuBackLabel.frame = subMenu.menuView.menuFrontLabel.frame;

    } else {
        
        // main menu is opened -> fan out subMenu and scale back to full size; if one of the subMenus is opened: hide others
        
        // if subMenu closed -> center in grid
        if (subMenu.isClosed) {
            subMenu.menuView.frame = CGRectMake(0, 0, kRGFlipMenuWidth, kRGFlipMenuHeight);
            subMenu.menuView.center = [self subMenuCenterWithIndex:theIndex maxIndex:theMaxIndex subMenuContainerView:subMenu.superMenu.menuView.subMenuContainerView];;
            subMenu.menuView.menuWrapperView.frame = CGRectMake(0, 0, subMenu.menuView.width, subMenu.menuView.height);
            subMenu.menuView.subMenuContainerView.frame = subMenu.menuView.menuWrapperView.frame;
            subMenu.menuView.menuWrapperView.layer.transform = CATransform3DIdentity;
            
        } else {
            subMenu.menuView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];

            if (isLandscape) {
                subMenu.menuView.frame = CGRectMake(-kRGFlipMenuWidth, subMenu.menuView.superview.middleY/2.f, kRGFlipMenuWidth, kRGFlipMenuHeight);
                subMenu.menuView.menuWrapperView.frame = CGRectMake(0, 0, subMenu.menuView.width, subMenu.menuView.height);
                subMenu.menuView.subMenuContainerView.frame = CGRectMake(kRGFlipMenuWidth, -kRGFlipMenuHeight/2.f, subMenu.superMenu.menuView.subMenuContainerView.width, subMenu.superMenu.menuView.subMenuContainerView.height);
            } else {
#warning that's wrong - see iPad
                subMenu.menuView.frame = CGRectMake(subMenu.menuView.superview.middleX/2.f, -kRGFlipMenuHeight, kRGFlipMenuWidth, kRGFlipMenuHeight);
                subMenu.menuView.menuWrapperView.frame = CGRectMake(0, 0, subMenu.menuView.width, subMenu.menuView.height);
                subMenu.menuView.subMenuContainerView.frame = CGRectMake(-kRGFlipMenuWidth/2.f, kRGFlipMenuHeight, subMenu.superMenu.menuView.subMenuContainerView.width, subMenu.superMenu.menuView.subMenuContainerView.height);
            }
            
        }
        
        if (subMenu.isHiddenToShowSibling) {
            subMenu.menuView.alpha = 0.f;
        } else {
            subMenu.menuView.alpha = 1.f;
        }
        
    }
}


- (void)repositionViews {
    
    self.menuWrapperView.frame = CGRectInset(self.frame, 20, 20);

    // root menu
    self.menuFrontLabel.width = kRGFlipMenuWidth;
    self.menuFrontLabel.height = kRGFlipMenuHeight;
    self.menuBackLabel.width = kRGFlipMenuWidth;
    self.menuBackLabel.height = kRGFlipMenuHeight;
    
    CGPoint newCenter;
    
    if (self.flipMenu.isClosed) {
        // menu was opened when user tapped -> move to center again
        newCenter = self.superview.center;
        
    } else {
        // menu is opening now -> depending on device orientation, move menuView up or left
        if (isLandscape) {
            // landscape -> move left
            newCenter = CGPointMake(CGRectGetWidth(self.menuFrontLabel.frame)/2.f+kRGFlipMenuPadding, self.superview.centerY);
            
        } else {
            // portrait -> move up
            newCenter = CGPointMake(self.superview.centerX, CGRectGetHeight(self.menuFrontLabel.frame)/2.f+kRGFlipMenuPadding);
        }
        
    }
    
    self.center = newCenter;
    
    self.menuWrapperView.center = self.middlePoint;
    
    self.menuFrontLabel.center = [self convertPoint:self.middlePoint toView:self.menuWrapperView];
    self.menuBackLabel.frame = self.menuFrontLabel.frame;

    // reposition subMenuContainerView
    if (self.flipMenu.isClosed) {
        self.menuWrapperView.alpha = 1.f;
        self.subMenuContainerView.frame = CGRectMake(0, 0, kRGFlipMenuWidth+40, kRGFlipMenuHeight+40);;
        self.subMenuContainerView.center = [self.superview convertPoint:self.superview.center toView:self.subMenuContainerView];
        
    } else {

        // hide mainMenu in case one of the subMenus is open
        if ([self.flipMenu isSubMenuOpen]) {
            self.menuWrapperView.alpha = 0.f;
        } else {
            self.menuWrapperView.alpha = 1.f;
        }
        
        // menu is opening now -> the subMenuContainerView fills out rest of space (take device orientation into account)
        if (isLandscape) {
            
            CGFloat x = CGRectGetWidth(self.menuFrontLabel.frame);
            self.subMenuContainerView.frame = CGRectMake(x, 0, self.width-x-20, self.height-20);
            self.subMenuContainerView.center = [self.superview convertPoint:self.superview.center toView:self];
            self.subMenuContainerView.centerX += x/2.f;
            
        } else {
            
            CGFloat y = CGRectGetHeight(self.menuFrontLabel.frame);
            self.subMenuContainerView.frame = CGRectMake(10, y, self.width-20, self.height-y-20);
            if (!self.flipMenu.superMenu) {
                self.subMenuContainerView.center = [self.superview convertPoint:self.superview.center toView:self];
            } else {
                // inception - move to superview superview??
                self.subMenuContainerView.center = [self.flipMenu.superMenu.menuView.superview convertPoint:self.flipMenu.superMenu.menuView.superview.center toView:self];
            }
            self.subMenuContainerView.centerY += y/2.f;
        }
    }

    // reposition subMenus
    [self.flipMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subMenu, NSUInteger idx1, BOOL *stop1) {
        [self repositionSubMenu:subMenu subMenuIndex:idx1 maxIndex:self.flipMenu.subMenus.count];
        
        [subMenu.subMenus enumerateObjectsUsingBlock:^(RGFlipMenu *subSubMenu, NSUInteger idx2, BOOL *stop2) {
            [self repositionSubSubMenu:subSubMenu subSubMenuIndex:idx2 maxIndex:subMenu.subMenus.count];
        }];
    }];
    
}

@end
