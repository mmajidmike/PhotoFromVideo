//
//  CShareImageViewController.m
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-11.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CShareImageViewController.h"
#import "CServer.h"
#import "SHK.h"
#import "SHKMail.h"
#import "SHKFacebook.h"

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

// strings
#define TITLE NSLocalizedString(@"Share picture", nil)
#define SAVED_SUCCESFULLY NSLocalizedString(@"Successfully saved to Camera roll ", nil)
#define SAVED_FAILED NSLocalizedString(@"Unable to save to Camera roll ", nil)
#define OK_BUTTON NSLocalizedString(@"Ok ", nil)
#define DEFAULT_PICTURE_TITLE NSLocalizedString(@"My Picture ", nil)
#define EMAIL_SUBJECT NSLocalizedString(@"Check out this picture ! ", nil)
#define CREATED_USING NSLocalizedString(@"Created using:  ", nil)
#define UNABLE_TO_SEND_EMAIL NSLocalizedString(@"Unable to send email ", nil)
#define UNABLE_TO_SEND_IMESSAGE NSLocalizedString(@"Unable to send iMessage ", nil)

@interface CShareImageViewController ()

@property (nonatomic,retain) ACAccountStore* accountStore;

@end

@implementation CShareImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = TITLE;
    
    CGFloat main = 200; // 221.0;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonHandler)];
    cancelButton.tintColor = [UIColor colorWithRed:main/255.0 green:7.0/255.0 blue:29.0/255.0 alpha:1];
    NSMutableArray* leftSideButtonArray = [[NSMutableArray alloc] initWithCapacity:2];
    [leftSideButtonArray addObject:cancelButton];
    self.navigationItem.leftBarButtonItems = leftSideButtonArray;
}

- (void) cancelButtonHandler {
    PRLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) doneHandler;
{
    PRLog(@"");
    // [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButton_handler:(id)sender {
    // UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(finishedSavingImageToCameraRoll), nil);
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
}
- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    NSString* message;
    if (error) {
        PRLog(@"error");
        message = SAVED_FAILED;
    } else {
        PRLog(@"success");
        message = SAVED_SUCCESFULLY;
    }
    [[[UIAlertView alloc] initWithTitle:TITLE message:message delegate:nil cancelButtonTitle:OK_BUTTON otherButtonTitles:nil] show];
}

- (IBAction)mailButton_handler:(id)sender {
    [self sendEmail];
}

- (IBAction)iMessageButton_handler:(id)sender {
    [self sendIMessage];
}

- (IBAction)faceBookButton_handler:(id)sender {
    PRLog(@"");
    
    SHKItem *item; //  = [[SHKItem alloc] init];
    item = [SHKItem image:self.image title:DEFAULT_PICTURE_TITLE];
    [SHKFacebook shareItem:item];
}

#pragma mark-MFMailComposeViewControllerDelegate method implementations

- (void) sendEmail;
{
    if ([MFMailComposeViewController canSendMail]) {
        PRLog(@"MFMailComposeViewController can send");
        
        NSString* subject = EMAIL_SUBJECT;
        NSString* completPathToWebPage = [CServer getCompletPathToWebPage];
        NSString* appHref = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", completPathToWebPage, [CServer getAppName]];
        NSString* emailBody = [NSString stringWithFormat:@"%@ %@", CREATED_USING, appHref];
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:subject];
        
        NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
        [mailer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"Image.jpg"];
        
        [mailer setMessageBody:emailBody isHTML:YES];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        PRLog(@"MFMailComposeViewController unable to send");
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    PRLog(@"");
    void(^dismissControllerCompleteCallBack)() = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == MFMailComposeResultSent) {
                // [self doneHandler];
            }
            else if (result == MFMailComposeResultFailed) {
                NSString* message = UNABLE_TO_SEND_EMAIL;
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:TITLE message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                alert = nil;
            }
        });
    };
    [controller dismissViewControllerAnimated:YES completion:dismissControllerCompleteCallBack];
    
    
}

#pragma mark-MFMessageComposeViewControllerDelegate method implementations
- (void) sendIMessage;
{
    PRLog(@"");
    if ([MFMessageComposeViewController canSendAttachments]) {
        PRLog(@"MFMessageComposeViewController canSendAttachments");
        
        NSString* completPathToWebPage = [CServer getCompletPathToWebPage];
        NSString* iMessageBody = [NSString stringWithFormat:@"Created using \n%@", completPathToWebPage];
        MFMessageComposeViewController* iMessageVC = [[MFMessageComposeViewController alloc] init];
        iMessageVC.messageComposeDelegate = self;
        iMessageVC.body = iMessageBody;
        NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
        [iMessageVC addAttachmentData:imageData typeIdentifier:@"public.data" filename:@"Image.jpg"];
        
        [self presentViewController:iMessageVC animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
{    
    PRLog(@"");
    void(^dismissControllerCompleteCallBack)() = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == MessageComposeResultSent) {
                // [self doneHandler];
            }
            else if (result == MessageComposeResultFailed){
                NSString* message = UNABLE_TO_SEND_IMESSAGE;
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:TITLE message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                alert = nil;
            }
        });
    };
    [controller dismissViewControllerAnimated:YES completion:dismissControllerCompleteCallBack];
}



@end
