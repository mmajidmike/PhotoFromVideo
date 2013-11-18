/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  PRP3BtnAlertView.m
//  PRP3BtnAlertView
//
//  Created by Matt Drance on 1/24/11.
//  Copyright 2011 Bookhouse Software LLC. All rights reserved.
//

#import "PRP3BtnAlertView.h"

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


@interface PRP3BtnAlertView ()

@property (nonatomic, copy) PRP3BtnAlertBlock cancelBlock;
@property (nonatomic, copy) PRP3BtnAlertBlock otherBlock;
@property (nonatomic, copy) PRP3BtnAlertBlock btn3Block;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *otherButtonTitle;
@property (nonatomic, copy) NSString *btn3Title;

@end

@implementation PRP3BtnAlertView

@synthesize cancelBlock;
@synthesize otherBlock;
@synthesize btn3Block;
@synthesize cancelButtonTitle;
@synthesize otherButtonTitle;
@synthesize btn3Title;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(PRP3BtnAlertBlock)cancelBlk
         otherTitle:(NSString *)otherTitle
         otherBlock:(PRP3BtnAlertBlock)otherBlk
         btn3Title:(NSString *)_btn3Title
         btn3Block:(PRP3BtnAlertBlock)_btn3Block
{
		 
    if ((self = [super initWithTitle:title 
                             message:message
                            delegate:self
                   cancelButtonTitle:cancelTitle 
                   otherButtonTitles:otherTitle, _btn3Title, nil])) {
				   
        if (cancelBlk == nil && otherBlk == nil) {
            self.delegate = nil;
        }
        self.cancelButtonTitle = cancelTitle;
        self.otherButtonTitle = otherTitle;
        self.btn3Title = _btn3Title;
        self.cancelBlock = cancelBlk;
        self.otherBlock = otherBlk;
        self.btn3Block = _btn3Block;
    }
    return self;
}

- (void) dealloc {
    PRLog(@"");
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView
willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:self.cancelButtonTitle]) {
        if (self.cancelBlock) self.cancelBlock();
    } 
    else if ([buttonTitle isEqualToString:self.otherButtonTitle]) {
        if (self.otherBlock) self.otherBlock();
    }
    else if ([buttonTitle isEqualToString:self.btn3Title]) {
        if (self.btn3Block) self.btn3Block();
    }
}

@end