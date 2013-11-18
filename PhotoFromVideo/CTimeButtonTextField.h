//
//  CTimeButtonTextField.h
//  VideoEdit
//
//  Created by mike majid on 2013-03-01.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTimeButtonTextFieldDelegate <NSObject>
- (void)timeButtonTextField_actionHandler:(id) sender;
@end

@interface CTimeButtonTextField : UIView

@property (nonatomic, retain) UITextField* textField;
@property (nonatomic, assign) id<CTimeButtonTextFieldDelegate> delegate;

- (void) setText:(NSString*) text;
- (void) setEnabled:(BOOL)bEnable;

@end
