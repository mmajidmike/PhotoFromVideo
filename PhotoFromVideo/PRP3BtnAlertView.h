/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  PRP3BtnAlertView.h
//  PRP3BtnAlertView
//
//  Created by Matt Drance on 1/24/11.
//  Copyright 2011 Bookhouse Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PRP3BtnAlertBlock)(void);

@interface PRP3BtnAlertView : UIAlertView {}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
        cancelTitle:(NSString *)cancelTitle
        cancelBlock:(PRP3BtnAlertBlock)cancelBlk
         otherTitle:(NSString *)otherTitle
         otherBlock:(PRP3BtnAlertBlock)otherBlk
          btn3Title:(NSString *)_btn3Title
          btn3Block:(PRP3BtnAlertBlock)_btn3Block;

@end
