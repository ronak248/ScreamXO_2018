//
//  CustomeFontLabel.m
//  Sigwine
//
//  Created by Macintosh on 8/4/15.
//  Copyright (c) 2015 Credencys. All rights reserved.
//

#import "CustomeFontLabel.h"

@implementation CustomeFontLabel
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0f)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)layoutSubviews
{
    [super layoutSubviews];
    // Implement font logic depending on screen size
    self.font = [UIFont fontWithName:@"ProximaNova-Regular" size:self.font.pointSize];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self)
    {
        [self setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:self.font.pointSize]];

        [self setFontStyle];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setFontStyle];
    }
    return self;
}
- (void)setFontStyle {
    
    CGFloat fontSize = self.font.pointSize;    
    [self setFont:[UIFont systemFontOfSize:fontSize]];
  //  if IS_IPHONE_6PLUS  {
        
     //   [self setFont:[UIFont systemFontOfSize:fontSize+5]];

        
   // }
  //  else if IS_IPHONE_6 {
        
    //    [self setFont:[UIFont systemFontOfSize:fontSize+3]];
        
    //}
}

@end
