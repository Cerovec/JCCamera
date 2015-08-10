//
//  JCRootViewController.m
//  JCCamera
//
//  Created by Jura on 09/08/15.
//  Copyright © 2015 MicroBlink. All rights reserved.
//

#import "JCRootViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface JCRootViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation JCRootViewController

- (IBAction)openImagePicker:(id)sender {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;

    // Displays a control that allows the user to choose only photos
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];

    // Hides the controls for moving & scaling pictures, or for trimming movies.
    imagePicker.allowsEditing = NO;

    // Shows default camera control overlay over camera preview.
    imagePicker.showsCameraControls = YES;

    // set delegate
    imagePicker.delegate = self;

    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
