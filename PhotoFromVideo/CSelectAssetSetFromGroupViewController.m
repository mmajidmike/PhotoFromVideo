//
//  CSelectAssetSetFromGroupViewController.m
//  VideoEdit
//
//  Created by mike majid on 2013-01-02.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CSelectAssetSetFromGroupViewController.h"
#import "CAssetTableViewCell.h"
#import "PRP3BtnAlertView.h"
// #import "CReOrderAssetsTableViewController.h"
#import "CExtractImageFromVideoViewController.h"
#import "CEditShareImageViewController.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

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

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define THMBNAIL_IMAGE_VIEW_TAG 123456
#define THUMBNAIL_IMAGE_HEIGHT 72
#define THUMBNAIL_IMAGE_SEPARATION 4
#define CELL_HEIGHT (THUMBNAIL_IMAGE_HEIGHT + THUMBNAIL_IMAGE_SEPARATION)

// strings
#define SELECT_TEXT NSLocalizedString(@"Select ", nil)

@interface CSelectAssetSetFromGroupViewController ()

@end

@implementation CSelectAssetSetFromGroupViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.allowsMultipleSelection = false;
    }
    return self;
}

- (void) dealloc {
    PRLog(@"");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    NSString* navigationItemTitle = @"";
    if (self.assetGroup) {
        navigationItemTitle = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
    }
    self.navigationItem.title = navigationItemTitle;
    
    // assetImageViewArray
    assetImageViewArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    // UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonHandler)];
    CGFloat main = 200; // 221.0;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonHandler)];
    cancelButton.tintColor = [UIColor colorWithRed:main/255.0 green:7.0/255.0 blue:29.0/255.0 alpha:1];
    NSMutableArray* leftSideButtonArray = [[NSMutableArray alloc] initWithCapacity:2];
    [leftSideButtonArray addObject:cancelButton];
    self.navigationItem.leftBarButtonItems = leftSideButtonArray;
    
    int screenWidth = [UIScreen mainScreen].bounds.size.width; // self.view.bounds.size.width;
    int screenHeight = [UIScreen mainScreen].bounds.size.height; // self.view.bounds.size.height; // self.view.frame.size.height; //
    // if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) screenHeight -= 88;
    PRLog(@"screen wh=(%d,%d)", screenWidth, screenHeight);
    numImagesPerRowLandscape = (screenHeight - THUMBNAIL_IMAGE_SEPARATION)/(THUMBNAIL_IMAGE_HEIGHT + THUMBNAIL_IMAGE_SEPARATION);
    numImagesPerRowPortrait = (screenWidth - THUMBNAIL_IMAGE_SEPARATION)/(THUMBNAIL_IMAGE_HEIGHT + THUMBNAIL_IMAGE_SEPARATION);
    PRLog(@"numImages pl = (%d,%d)", numImagesPerRowPortrait, numImagesPerRowLandscape);
    self.view.userInteractionEnabled = YES;
    
    alreadyScrolledToBottomOfTableView = false;
}

- (void) scrollToBottomOfTableView {
    // / scroll to bottom of table view
    
    CGSize contentSize = self.tableView.contentSize;
    PRLog(@"contentSize=(%g,%g)", contentSize.width, contentSize.height);
    double displayHeight = self.view.frame.size.height;
    double totalNavBarHeight = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) totalNavBarHeight = 44 + 24;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) totalNavBarHeight = 44 + 12;
    }
    else {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) totalNavBarHeight = 2; // 0; // 44; //  + 24;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) totalNavBarHeight = 2; // 0; // 44; //  + 12;
    }
    displayHeight -= totalNavBarHeight;
    double contentYOffset = contentSize.height - displayHeight; // (numRows-numRowsDisplayed)*CELL_HEIGHT;
    PRLog(@"contentYOffset=%g", contentYOffset);
    if (contentYOffset > 0) {
        [self.tableView setContentOffset:CGPointMake(0, contentYOffset)];
    }
    
    alreadyScrolledToBottomOfTableView = true;
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    if (!alreadyScrolledToBottomOfTableView) [self scrollToBottomOfTableView];
}

- (void) cancelButtonHandler {
    PRLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) mainThreadPopViewControllerAnimated {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) mainThreadPopToRootViewControllerAnimated {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) doneButtonHandler {
    int ALAssetArrayCount = [ALAssetArray count];
    PRLog(@"ALAssetArrayCount=%d", ALAssetArrayCount);
    
    // first, extract a list of the selected assets
    NSMutableArray* selectedAssetArray = [[NSMutableArray alloc] initWithCapacity:2];
    for (int i=0 ; i<ALAssetArrayCount ; i++) {
        if ([[selectedAssetIndexArray objectAtIndex:i] boolValue]) {
            [selectedAssetArray addObject:[ALAssetArray objectAtIndex:i]];
        }
    }
    int selectedAssetArrayCount = [selectedAssetArray count];
    PRLog(@"selectedAssetArrayCount=%d", selectedAssetArrayCount);
    
    if (selectedAssetArrayCount == 0) {
        PRLog(@"selectedAssetArrayCount=%d aborting ...", selectedAssetArrayCount);
        // [self.navigationController popToRootViewControllerAnimated:YES];
        // return;
        
        __weak __block CSelectAssetSetFromGroupViewController* selfRef = self;
        NSDictionary *infoDictionary=[ [NSBundle mainBundle]infoDictionary];
        NSString *title = [infoDictionary objectForKey:@"CFBundleName"];
        NSString* message = @"Nothing selected"; // TEXT_CONFIRM_EDIT_CHANGES;
        NSString* cancelTitle = @"Cancel";
        NSString* otherTitle = @"Ok"; // @"107.22.16.33";
        NSString* btn3Title = nil; // @"50.17.66.29";
        PRP3BtnAlertView* alertView = [[PRP3BtnAlertView alloc] initWithTitle:title
                                                                      message:message
                                                                  cancelTitle:cancelTitle
                                                                  cancelBlock:^(void) {
                                                                      PRLog(@"Cancel");
                                                                      // return;
                                                                  }
                                                                   otherTitle:otherTitle
                                                                   otherBlock:^(void) {
                                                                       PRLog(@"Ok");
                                                                       // return;
                                                                       [selfRef performSelectorOnMainThread:@selector(mainThreadPopToRootViewControllerAnimated) withObject:nil waitUntilDone:NO];
                                                                   }
                                                                    btn3Title:btn3Title
                                                                    btn3Block:^(void) {
                                                                        PRLog(@"btn3Block");
                                                                    }
                                       ];
        [alertView show];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) set_assetGroup:(ALAssetsGroup*)assetGroup {
    PRLog(@"");
    _assetGroup = assetGroup;
    
    void (^assetsEnumerator)(ALAsset *,NSUInteger,BOOL*) = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        if (result !=nil) {
            // PRLog(@"number of assets in group: %d", [group numb]);
            // PRLog(@"Asset index=%d", index);
            // [ALAssetArray insertObject:result atIndex:0];
            // NSString* propertyType = [result valueForProperty:ALAssetPropertyType];
            // if ([propertyType isEqualToString:ALAssetTypeVideo]) {
            [ALAssetArray addObject:result];
            [selectedAssetIndexArray setObject:[NSNumber numberWithBool:false] atIndexedSubscript:index];
            // }
        }
        else {
            // PRLog(@"Assets enumeration terminated");
        }
    };
    
    ALAssetArray = [[NSMutableArray alloc] initWithCapacity:[assetGroup numberOfAssets]];
    selectedAssetIndexArray = [[NSMutableArray alloc] initWithCapacity:[assetGroup numberOfAssets]];
    [assetGroup enumerateAssetsUsingBlock:assetsEnumerator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    // int numberOfAssets = [_assetGroup numberOfAssets];
    // return numberOfAssets;
    
    int ALAssetArrayCount = [ALAssetArray count];
    PRLog(@"ALAssetArrayCount=%d", ALAssetArrayCount);
    
    int numImagesPerRow = numImagesPerRowPortrait;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) numImagesPerRow =  numImagesPerRowLandscape;
    int numRows = (ALAssetArrayCount + (numImagesPerRow-1))/numImagesPerRow;
    
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    static NSString *CellIdentifier = @"AssetReUseCell";
    
    int tableCellWidth = [UIScreen mainScreen].bounds.size.width; // self.view.bounds.size.width;
    int numImagesPerRow = numImagesPerRowPortrait;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        numImagesPerRow =  numImagesPerRowLandscape;
        tableCellWidth = [UIScreen mainScreen].bounds.size.height;
    }
    int totalImagesWidth = (numImagesPerRow * (THUMBNAIL_IMAGE_HEIGHT + THUMBNAIL_IMAGE_SEPARATION));

    CAssetTableViewCell *cell = (CAssetTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CAssetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        int x = (tableCellWidth - totalImagesWidth)/2;
        for (int i=0 ; i<numImagesPerRowLandscape ; i++) {
            CAssetImageView* thmbNailImageView = [[CAssetImageView alloc] initWithFrame:CGRectMake(x,THUMBNAIL_IMAGE_SEPARATION, THUMBNAIL_IMAGE_HEIGHT, THUMBNAIL_IMAGE_HEIGHT)];
            [assetImageViewArray addObject:thmbNailImageView];
            thmbNailImageView.delegate = self;
            thmbNailImageView.backgroundColor = [UIColor clearColor]; // [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            [cell addSubview:thmbNailImageView];
            x += THUMBNAIL_IMAGE_HEIGHT + THUMBNAIL_IMAGE_SEPARATION;
            thmbNailImageView.tag = THMBNAIL_IMAGE_VIEW_TAG + i;
        }
    }
    
    int x = (tableCellWidth - totalImagesWidth)/2;
    int ALAssetArrayCount = [ALAssetArray count];
    int assetIndexStart = numImagesPerRow * row;
    int numValidImages = 0;
    for (int imageIndex=0 ; imageIndex<numImagesPerRow ; imageIndex++) {
        int tag = THMBNAIL_IMAGE_VIEW_TAG + imageIndex;
        CAssetImageView* thmbNailImageView = (CAssetImageView*)[cell viewWithTag:tag];
        thmbNailImageView.userInteractionEnabled = YES;
        CGRect thmbNailImageViewFrame = thmbNailImageView.frame;
        thmbNailImageViewFrame.origin.x = x;
        thmbNailImageView.frame = thmbNailImageViewFrame;
        int assetIndex = assetIndexStart + imageIndex;
        if (assetIndex < ALAssetArrayCount) {
            ALAsset* asset = [ALAssetArray objectAtIndex:assetIndex];
            NSString* propertyType = [asset valueForProperty:ALAssetPropertyType];
            CGImageRef thumbNailImageRef = asset.thumbnail;
            UIImage* thumbNailImage = [UIImage imageWithCGImage:thumbNailImageRef];
            thmbNailImageView.image = thumbNailImage;
            thmbNailImageView.assetIndex = assetIndex;
            [thmbNailImageView setSelected:[[selectedAssetIndexArray objectAtIndex:assetIndex] boolValue]];
            if ([propertyType isEqualToString:ALAssetTypeVideo]) { // ([asset valueForProperty:ALAssetPropertyDuration] != ALErrorInvalidProperty) {
                NSNumber* nsDuration = [asset valueForProperty:ALAssetPropertyDuration];
                double fDuration = [nsDuration doubleValue];
                NSString* videoDurationString = [self timeFormatted:(fDuration + 0.5)];
                [thmbNailImageView setVideoDuration:videoDurationString];
            }
            else {
                [thmbNailImageView setVideoDuration:nil];
            }
            numValidImages++;
        }
        else {
            thmbNailImageView.image = nil;
        }
        x += THUMBNAIL_IMAGE_HEIGHT + THUMBNAIL_IMAGE_SEPARATION;
    }
    
    // double animationDuration = 0.3;
    int i=0;
    for (; i<numValidImages ; i++) {
        int tag = THMBNAIL_IMAGE_VIEW_TAG + i;
        CAssetImageView* thmbNailImageView = (CAssetImageView*)[cell viewWithTag:tag];
        if (thmbNailImageView.alpha == 0) {
            [self performSelectorOnMainThread:@selector(fadeInImageView:) withObject:thmbNailImageView waitUntilDone:NO];
        }
    }
    
    for (; i<numImagesPerRowLandscape ; i++) {
        int tag = THMBNAIL_IMAGE_VIEW_TAG + i;
        CAssetImageView* thmbNailImageView = (CAssetImageView*)[cell viewWithTag:tag];
        if (thmbNailImageView.alpha == 1) {
            [self performSelectorOnMainThread:@selector(fadeOutImageView:) withObject:thmbNailImageView waitUntilDone:NO];
        }
    }
    
    return cell;
}

- (void) fadeInImageView:(UIImageView*) imageView {
    // PRLog(@"");
    double animationDuration = 0.3;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         imageView.alpha = 1;
                     }
     ];
}

- (void) fadeOutImageView:(UIImageView*) imageView {
    // PRLog(@"");
    double animationDuration = 0.3;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         imageView.alpha = 0;
                     }
     ];
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    NSString* formattedString;
    if (hours == 0) {
        if (minutes == 0) {
            formattedString = [NSString stringWithFormat:@"0:%02d", seconds];
        }
        else {
            if (minutes < 10) formattedString = [NSString stringWithFormat:@"%01d:%02d", minutes, seconds];
            else formattedString = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        }
    }
    else {
        if (hours < 10) formattedString = [NSString stringWithFormat:@"%01d:%02d:%02d",hours, minutes, seconds];
        else formattedString = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
    return formattedString;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//     int row = [indexPath row];
//     PRLog(@"row=%d", row);
//     return nil;
// }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // int row = [indexPath row];
    // PRLog(@"row=%d", row);
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    PRLog(@"");
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [(UITableView*)self.view reloadData];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    PRLog(@"");
}

#pragma mark-CAssetImageViewDelegate <NSObject>
- (void) assetImageViewTapped:(id) sender {
    CAssetImageView* assetImageView = (CAssetImageView*)sender;
    int assetIndex = assetImageView.assetIndex;
    BOOL selected = [[selectedAssetIndexArray objectAtIndex:assetIndex] boolValue];
    PRLog(@"assetIndex=%d selected=%d", assetIndex, selected);
    ALAsset* alasset = [ALAssetArray objectAtIndex:assetIndex];
    
    if (!self.allowsMultipleSelection) {
        for (CAssetImageView* av in assetImageViewArray) {
            if ([av isSelected]) {
                [av setSelected:false];
            }
        }
        int selectedAssetIndexArrayCount = [selectedAssetIndexArray count];
        for (int i=0 ; i<selectedAssetIndexArrayCount ; i++) [selectedAssetIndexArray setObject:[NSNumber numberWithBool:false] atIndexedSubscript:i];
        selected = false;
    }
    
    selected = !selected;
    [assetImageView setSelected:selected];
    [selectedAssetIndexArray setObject:[NSNumber numberWithBool:selected] atIndexedSubscript:assetIndex];
    
    NSString* propertyType = [alasset valueForProperty:ALAssetPropertyType];
    PRLog(@"assetSelectedCallBack propertyType=%@", propertyType);
    if ([propertyType isEqualToString:ALAssetTypePhoto]) {
        ALAssetRepresentation* defaultRepresentation = alasset.defaultRepresentation;
        CGImageRef fullScreenImageRef = defaultRepresentation.fullScreenImage;
        UIImage *fullScreenImage = [[UIImage alloc]initWithCGImage:fullScreenImageRef];
        [self launchEditShareImageViewController:fullScreenImage];
    }
    if ([propertyType isEqualToString:ALAssetTypeVideo]) {
        [self extractAndDisplayVideoFrame:alasset];
    }
}

- (void) extractAndDisplayVideoFrame:(ALAsset*)alasset;
{
    UIStoryboard *storyboard = self.storyboard;
    CExtractImageFromVideoViewController* extractImageFromVideoVC = [storyboard instantiateViewControllerWithIdentifier:@"CExtractImageFromVideoViewController"];
    extractImageFromVideoVC.videoURL = alasset.defaultRepresentation.url;
    [self.navigationController pushViewController:extractImageFromVideoVC animated:YES];
}

- (void) launchEditShareImageViewController:(UIImage*)image;
{
    UIStoryboard *storyboard = self.storyboard;
    CEditShareImageViewController* editShareImageVC = [storyboard instantiateViewControllerWithIdentifier:@"CEditShareImageViewController"];
    editShareImageVC.image = image;
    [self.navigationController pushViewController:editShareImageVC animated:YES];
}

@end
