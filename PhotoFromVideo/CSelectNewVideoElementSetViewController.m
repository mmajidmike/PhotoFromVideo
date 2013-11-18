//
//  CSelectNewVideoElementSetViewController.m
//  VideoEdit
//
//  Created by mike majid on 2013-01-01.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CSelectNewVideoElementSetViewController.h"
#import "CSelectAssetSetFromGroupViewController.h"
#import "CALAssetsLibraryContainer.h"
#import "CEditShareImageViewController.h"
#import "CExtractImageFromVideoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


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

#define THMBNAIL_IMAGE_VIEW_TAG 123456
#define THUMBNAIL_IMAGE_HEIGHT 64
#define CELL_HEIGHT 70

// strings
#define NAVIGATION_ITEM_TITLE NSLocalizedString(@"Groups", nil)
#define CAMERA_TITLE NSLocalizedString(@"Camera", nil)
#define ERROR_TEXT_CAMERA_NOT_SUPPORTED NSLocalizedString(@"Camera not supported", nil)


@interface CSelectNewVideoElementSetViewController ()

@end

@implementation CSelectNewVideoElementSetViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.allowsMultipleSelection = true; // false;
    }
    return self;
}

- (void) awakeFromNib;
{
    self.allowsMultipleSelection = true; // false;
}

- (void) dealloc {
    PRLog(@"");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PRLog(@"bundleIdentifier=%@", [[NSBundle mainBundle] bundleIdentifier]);
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationItem.title = NAVIGATION_ITEM_TITLE;
    
    CGFloat main = 200; // 221.0;
    UIBarButtonItem* cameraButton = [[UIBarButtonItem alloc] initWithTitle:CAMERA_TITLE style:UIBarButtonItemStyleBordered target:self action:@selector(cameraButtonHandler)];
    cameraButton.tintColor = [UIColor colorWithRed:0.0/255.0 green:main/255.0 blue:0.0/255.0 alpha:1];
    NSMutableArray* rightSideButtonArray = [[NSMutableArray alloc] initWithCapacity:2];
    [rightSideButtonArray addObject:cameraButton];
    self.navigationItem.rightBarButtonItems = rightSideButtonArray;
        
}

- (void) cameraButtonHandler;
{
    PRLog(@"");
    [self launchCamera];
}

- (void) cancelButtonHandler {
    PRLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    PRLog(@"");
    if (!self.assetGroupArray) [self getAssetGroupArray];
}

- (void) getAssetGroupArray {
    self.assetGroupArray = [[NSMutableArray alloc] initWithCapacity:10];
    void (^assetGroupEnumerator)(ALAssetsGroup *,BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if (group != nil) {
            [self.assetGroupArray addObject:group];
        }
        else {
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    ALAssetsLibrary *library = [CALAssetsLibraryContainer defaultAssetsLibrary]; // [[ALAssetsLibrary alloc] init];
    NSUInteger groupTypes = ALAssetsGroupAll;
    [library enumerateGroupsWithTypes:groupTypes usingBlock:assetGroupEnumerator failureBlock:^(NSError* error){
        PRLog(@"an error occured");
        PRLog(@"localized description = %@", [error localizedDescription]);
        PRLog(@"localized failure reason = %@", [error localizedFailureReason]);
        PRLog(@"localized recovery suggestion = %@", [error localizedRecoveryOptions]);
    }
     ];
}

+ (NSMutableArray*) ExtractAssetGroupArray {
    NSMutableArray* assetGroupArray = [[NSMutableArray alloc] initWithCapacity:10];
    void (^assetGroupEnumerator)(ALAssetsGroup *,BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if (group != nil) {
            [assetGroupArray addObject:group];
        }
        else {
            // int assetGroupArrayCount = [assetGroupArray count];
            // PRLog(@"group enumeration terminated assetGroupArrayCount=%d", assetGroupArrayCount);
        }
    };
    ALAssetsLibrary *library = [CALAssetsLibraryContainer defaultAssetsLibrary]; // [[ALAssetsLibrary alloc] init];
    NSUInteger groupTypes = ALAssetsGroupAll;
    [library enumerateGroupsWithTypes:groupTypes usingBlock:assetGroupEnumerator failureBlock:^(NSError* error){
        PRLog(@"an error occured");
        PRLog(@"localized description = %@", [error localizedDescription]);
        PRLog(@"localized failure reason = %@", [error localizedFailureReason]);
        PRLog(@"localized recovery suggestion = %@", [error localizedRecoveryOptions]);
    }
    ];
    
    return assetGroupArray;
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
    int assetGroupArrayCount = [self.assetGroupArray count];
    PRLog(@"assetGroupArrayCount=%d", assetGroupArrayCount);
    return assetGroupArrayCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    static NSString *CellIdentifier = @"ReUsableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; 
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImageView* thmbNailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, THUMBNAIL_IMAGE_HEIGHT, THUMBNAIL_IMAGE_HEIGHT)];
        thmbNailImageView.tag = THMBNAIL_IMAGE_VIEW_TAG;
        thmbNailImageView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        [cell addSubview:thmbNailImageView];
    }
    
    // Configure the cell...
    ALAssetsGroup* assetGroup = [self.assetGroupArray objectAtIndex:row];
    int numberOfAssets = [assetGroup numberOfAssets];
    NSString* assetsGroupPorpertyName = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
    NSString* labelText = [NSString stringWithFormat:@"            %@ (%d)", assetsGroupPorpertyName, numberOfAssets];
    CGImageRef posterImageRef = assetGroup.posterImage;
    cell.textLabel.text = labelText; // assetsGroupPorpertyName;
    UIImage* posterImage = [UIImage imageWithCGImage:posterImageRef];
    UIImageView* thmbNailImageView = (UIImageView*)[cell viewWithTag:THMBNAIL_IMAGE_VIEW_TAG];
    thmbNailImageView.image = posterImage;
    
    posterImage = nil;
    posterImageRef = nil;
    assetGroup = nil;
    
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    PRLog(@"row=%d", row);
    
    ALAssetsGroup* assetGroup = [self.assetGroupArray objectAtIndex:row];
    UIStoryboard *storyboard = self.storyboard;
    CSelectAssetSetFromGroupViewController* selectAssetSetVC = [storyboard instantiateViewControllerWithIdentifier:@"CSelectAssetSetFromGroupViewController"];
    selectAssetSetVC.allowsMultipleSelection = self.allowsMultipleSelection;
    selectAssetSetVC.assetGroup = assetGroup;
    selectAssetSetVC.videoElementsSelectedCallBack = _videoElementsSelectedCallBack;
    selectAssetSetVC.assetSelectedCallBack = _assetSelectedCallBack;
    selectAssetSetVC.allowsMultipleSelection = false;
    [self.navigationController pushViewController:selectAssetSetVC animated:YES];
    
    // Navigation logic may go here. Create and push another view controller.
    /*
    *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    PRLog(@"");
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    PRLog(@"");
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - laucnh camera methods
- (void) launchCamera;
{
    // check if this device supports camera
    BOOL cameraIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!cameraIsAvailable) {
        NSString* title = NAVIGATION_ITEM_TITLE;
        NSString* message = ERROR_TEXT_CAMERA_NOT_SUPPORTED;
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        alertView = nil;
        return;
    }
    PRLog(@"camera is available");
    
    double dispatchDelay = 0.3; // 0.8; // 0.2; // 1.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, dispatchDelay * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.allowsEditing = false; // true;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage,(NSString *) kUTTypeMovie, nil];
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        imagePickerController.cameraViewTransform = CGAffineTransformIdentity;
        imagePickerController.delegate = self;
        // void(^completionCallback)() = ^() {
        //     PRLog(@"completionCallback()");
        // };
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            // [self presentViewController:imagePickerController animated:YES completion:completionCallback];
            [self presentViewController:imagePickerController animated:YES completion:nil];
        });
    });
}


#pragma mark - UIImagePickerControllerDelegate method implementations

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        PRLog(@"kUTTypeImage");
        UIImage* image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
        void(^dismissCompletionHandler)() = ^() {
            PRLog(@"dismissCompletionHandler()");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self launchEditShareImageViewController:image];
            });
        };
        [self dismissViewControllerAnimated:YES completion:dismissCompletionHandler];
    }
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        PRLog(@"kUTTypeImage");
        NSURL *videoURL= [info objectForKey:UIImagePickerControllerMediaURL];
        void(^dismissCompletionHandler)() = ^() {
            PRLog(@"dismissCompletionHandler()");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self extractAndDisplayVideoFrame:videoURL];
            });
        };
        [self dismissViewControllerAnimated:YES completion:dismissCompletionHandler];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    PRLog(@"");
    void(^dismissCompletionHandler)() = ^() {
        PRLog(@"dismissCompletionHandler()");
    };
    [self dismissViewControllerAnimated:YES completion:dismissCompletionHandler];
}

#pragma mark-launch image editor
- (void) launchEditShareImageViewController:(UIImage*)image;
{
    UIStoryboard *storyboard = self.storyboard;
    CEditShareImageViewController* editShareImageVC = [storyboard instantiateViewControllerWithIdentifier:@"CEditShareImageViewController"];
    editShareImageVC.image = image;
    [self.navigationController pushViewController:editShareImageVC animated:YES];
}

- (void) extractAndDisplayVideoFrame:(NSURL*)videoURL;
{
    UIStoryboard *storyboard = self.storyboard;
    CExtractImageFromVideoViewController* extractImageFromVideoVC = [storyboard instantiateViewControllerWithIdentifier:@"CExtractImageFromVideoViewController"];
    extractImageFromVideoVC.videoURL = videoURL;
    [self.navigationController pushViewController:extractImageFromVideoVC animated:YES];
}



@end
