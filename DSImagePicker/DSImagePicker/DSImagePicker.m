//
//  DSImagePicker.m
//  DSImagePicker
//
//  Created by Dinesh Saini on 8/22/17.
//  Copyright © 2017 Dinesh Saini. All rights reserved.
//

#import "DSImagePicker.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>

#define ErrorMessage @"You can’t update the picture without access to the camera or photos"
#define AlertTitle @"Pick photo from"
#define Camera @"Camera"
#define Photos @"Photo Library"
#define Cancel @"Cancel"
#define Setting @"Setting"
#define PermissionNeeded @"Permission Needed"
#define PermissionMessage @"Open Setting App and give us permission"
#define ApplicationName [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleDisplayName"]

@interface DSImagePicker(){
    UIViewController *presentingViewController;
    BOOL isAllowEditing;
    void (^successBlock)(UIImage *);

}
@end

@implementation DSImagePicker


/**
 *  This method will return Instance of DSImagePicker
 *
 *  @return DSImagePicker
 */
+ (DSImagePicker *)shared{
    static DSImagePicker *imagePicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imagePicker = [[DSImagePicker alloc] init];
    });
    
    return imagePicker;
}

/**
 *  Show options for image pick
 
 *  @param viewController UIViewController
 *  @param imageEditing Bool
 *  @param success returen UIImage
 *  @param failure return error
 */
- (void)imagePickerInViewController:(UIViewController *)viewController allowEditing:(BOOL)imageEditing WithSuccess:(void (^)(UIImage *))success failure:(void (^)(NSError *))failure{
    presentingViewController = viewController;
    successBlock = success;
    isAllowEditing = imageEditing;
    [self showActionSheetinView:viewController.view];
}

/*!
 *  Handle options and presentation of Image Picker
 *
 *  @param viewController presenting view controller
 *  @param success        provides selected image
 *  @param failure        failure block
 */
- (void)imagePickerInViewController:(UIViewController *)viewController
                        WithSuccess:(void (^)(UIImage *image))success
                            failure:(void (^)(NSError *error))failure{
    presentingViewController = viewController;
    successBlock = success;
    [self showActionSheetinView:viewController.view];
    
}

/*!
 *  Action sheet with options to choose photo
 *
 *  @param view presenting view
 */
- (void)showActionSheetinView:(UIView *)view{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:AlertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    actionSheet.popoverPresentationController.sourceView = view;
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:Camera style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusDenied){
            // denied
            [self showMessage:nil message:ErrorMessage];
        }
        else if(status == AVAuthorizationStatusRestricted){
            // restricted
            [self showMessage:nil message:ErrorMessage];
        }
        else if(status == AVAuthorizationStatusNotDetermined){
            // not determined
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(!granted){
                    [self showMessage:nil message:ErrorMessage];
                }
                else{
                    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
                        [self showAlertWithTitle:ApplicationName andMessage:@"Your device didn't have camera"];
                        return;
                    }
                    else
                    {
                        [self takePic:sourceType];
                    }
                }
            }];
        }
        else if (status == AVAuthorizationStatusAuthorized){
            [self takePic:sourceType];
        }
        else{
            
            if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
                [self showAlertWithTitle:ApplicationName andMessage:@"Your device didn't have camera"];
                return;
            }
            
            [self takePic:sourceType];
        }
        
    }];
    
    UIAlertAction *actionPhotos = [UIAlertAction actionWithTitle:Photos style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted){
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                    [self showMessage:nil message:ErrorMessage];
                }
                else{
                    [self takePic:UIImagePickerControllerSourceTypePhotoLibrary];
                }
            }];
        }
        else{
            [self takePic:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:Cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    [actionCancel setValue:[UIColor redColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionCamera];
    [actionSheet addAction:actionPhotos];
    [actionSheet addAction:actionCancel];
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [viewController presentViewController:actionSheet animated:YES completion:nil];
}


- (void)takePic:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *imagePC = [[UIImagePickerController alloc]init];
    imagePC.allowsEditing = isAllowEditing;
    [imagePC setSourceType:sourceType];
    [imagePC setDelegate:self];
    
    // Navigation bar customization
    [imagePC.navigationBar setTranslucent:false];
    [imagePC.navigationBar setTintColor:[UIColor whiteColor]];
    [imagePC.navigationBar setBarTintColor:[UIColor colorWithRed:0.07 green:0.21 blue:0.58 alpha:1.00]];
    [imagePC.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                    NSFontAttributeName: [UIFont fontWithName:@"GillSans-Bold" size:20.0]}];
    
    [presentingViewController presentViewController:imagePC animated:YES completion:^{
        
    }];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{

}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 800.0/400.0;
    
    //    if(imgRatio!=maxRatio)
    {
        if(imgRatio < maxRatio){
            imgRatio = 400.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 400.0;
        }
        else{
            imgRatio = 600.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 600.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    successBlock(img);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - AlertView

/*!
 *  Show alert view.
 *
 *  @param alertTitle   title for alertview
 *  @param alertMessage message for alertview
 */
- (void)showMessage:(NSString *)alertTitle message:(NSString *)alertMessage{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //update on main thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:PermissionNeeded message:PermissionMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:Cancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            UIAlertAction *actionSetting = [UIAlertAction actionWithTitle:Setting style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                #if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]]){
                        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    }
                #else
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]]){
                        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                #endif
            }];
            [alertController addAction:actionCancel];
            [alertController addAction:actionSetting];
            UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [viewController presentViewController:alertController animated:YES completion:nil];
        });
    });
}


/**
 This method is used to show alert

 @param title NSString  (Alert Controller title)
 @param msg NSString (Alert Controller Message)
 */
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)msg{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:actionOk];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}
@end
