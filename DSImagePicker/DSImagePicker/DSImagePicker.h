//
//  DSImagePicker.h
//  DSImagePicker
//
//  Created by Dinesh Saini on 8/22/17.
//  Copyright © 2017 Dinesh Saini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DSImagePicker : NSObject<UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>


/**
 This method will reture Instance of DSImagePicker

 @return DSImagePicker
 */
+ (DSImagePicker *)shared;


/**
 Show options for image pick

 @param viewController UIViewController
 @param imageEditing Bool
 @param success returen UIImage
 @param failure return error
 */
- (void)imagePickerInViewController:(UIViewController *)viewController allowEditing:(BOOL )imageEditing WithSuccess:(void (^)(UIImage *image))success
                            failure:(void (^)(NSError *error))failure;

@end
