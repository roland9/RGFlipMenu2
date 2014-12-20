//
//  RGFlipSubMenuColors.m
//  RGFlipMenu2
//
//  Created by Roland Gröpmair on 01/12/2014.
//  Copyright (c) 2014 Roland Gröpmair. All rights reserved.
//

#import "RGFlipSubMenuColors.h"

@implementation RGFlipSubMenuColors

+ (UIColor *)frontColor {
    CGFloat hue, saturation, brightness, alpha;
    [[UIColor blueColor] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.8f alpha:alpha];
}

+ (UIColor *)backColor {
    CGFloat hue, saturation, brightness, alpha;
    [[UIColor blueColor] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.8f alpha:alpha];
}

+ (UIColor *)frontTextColor {
    CGFloat hue, saturation, brightness, alpha;
    [[UIColor whiteColor] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.8f alpha:alpha];
}

+ (UIColor *)backTextColor {
    CGFloat hue, saturation, brightness, alpha;
    [[UIColor yellowColor] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.8f alpha:alpha];
}

@end
