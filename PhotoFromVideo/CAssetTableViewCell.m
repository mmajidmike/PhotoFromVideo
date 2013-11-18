//
//  CAssetTableViewCell.m
//  VideoEdit
//
//  Created by mike majid on 2013-01-03.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CAssetTableViewCell.h"

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


@implementation CAssetTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    PRLog(@"");
    
    // NSArray* subViewArray = [self subviews];
    // int subViewArrayCount = [subViewArray count];
    // PRLog(@"subViewArrayCount=%d", subViewArrayCount);
}

@end
