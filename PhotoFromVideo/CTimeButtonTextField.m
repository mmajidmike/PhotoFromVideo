//
//  CTimeButtonTextField.m
//  VideoEdit
//
//  Created by mike majid on 2013-03-01.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CTimeButtonTextField.h"

#import "GlobalDebug.h"
#ifdef GLOBAL_DEBUG
#define LOCAL_DEBUG
#ifdef LOCAL_DEBUG
#define PRLog(...) NSLog(@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define PRLog(...) do { } while (0)
#endif
#else
#define PRLog(...) do { } while (0)
#endif


@implementation CTimeButtonTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self postAllocInitialization];
    }
    return self;
}

- (void) awakeFromNib;
{
    [self postAllocInitialization];
}

- (void) postAllocInitialization;
{
    self.backgroundColor = [UIColor clearColor];
    // self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
    
    CGRect frame = self.frame;
    double fontSize = 16.0; // 20.0; // 25.0; // 18.0;
    UIFont* font = [UIFont fontWithName:@"Arial" size:fontSize];
    CGRect textFieldFrame = frame;
    textFieldFrame.origin.x = 0;
    textFieldFrame.origin.y = 0;
    self.textField = [[UITextField alloc] initWithFrame:textFieldFrame];
    self.textField.font = font;
    self.textField.userInteractionEnabled = false;
    self.textField.textColor = [UIColor whiteColor];
    self.textField.text = @"0.00";
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.textAlignment = NSTextAlignmentRight;
    // self.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    // self.textField.returnKeyType = UIReturnKeyDone;
    
    [self addSubview:self.textField];
}

- (void) setText:(NSString*) text {
    self.textField.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setEnabled:(BOOL)bEnable {
    if (bEnable) {
        self.textField.textColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
    }
    else {
        double intensity = 0.4;
        self.textField.textColor = [UIColor colorWithRed:intensity green:intensity blue:intensity alpha:1.0];
        self.userInteractionEnabled = NO;
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    PRLog(@"");
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    PRLog(@"");
    [self.delegate timeButtonTextField_actionHandler:self];
}

@end
