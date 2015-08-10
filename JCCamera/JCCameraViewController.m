//
//  ViewController.m
//  Camera-Sample
//
//  Created by Jura on 09/08/15.
//  Copyright © 2015 MicroBlink. All rights reserved.
//

#import "JCCameraViewController.h"
#import "JCCameraView.h"
#import <AVFoundation/AVFoundation.h>

@interface JCCameraViewController () <AVCaptureAudioDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet JCCameraView *cameraView;

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation JCCameraViewController

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // Note that the app delegate controls the device orientation notifications required to use the device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.cameraView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

- (IBAction)closeCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animate {
    [super viewDidAppear:animate];
    [self startCaptureSession];
};

- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminateNotification:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureSessionDidStartRunningNotification:)
                                                 name:AVCaptureSessionDidStartRunningNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureSessionDidStopRunningNotification:)
                                                 name:AVCaptureSessionDidStopRunningNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureSessionRuntimeErrorNotification:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNotificationObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCaptureSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeNotificationObserver];
}

- (void)appplicationWillResignActive:(NSNotification*)note {
    NSLog(@"Will resign active!");
}

- (void)appplicationWillEnterForeground:(NSNotification*)note {
    NSLog(@"appplicationWillEnterForeground!");
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)note {
    NSLog(@"applicationDidEnterBackgroundNotification!");
}

- (void)applicationWillTerminateNotification:(NSNotification*)note {
    NSLog(@"applicationWillTerminateNotification!");
}

- (void)captureSessionDidStartRunningNotification:(NSNotification*)note {
    NSLog(@"captureSessionDidStartRunningNotification!");

    [UIView animateWithDuration:0.3 animations:^{
        self.cameraPausedLabel.alpha = 0.0;
    }];
}

- (void)captureSessionDidStopRunningNotification:(NSNotification*)note {
    NSLog(@"captureSessionDidStopRunningNotification!");

    [UIView animateWithDuration:0.3 animations:^{
        self.cameraPausedLabel.alpha = 1.0;
    }];
}

- (void)captureSessionRuntimeErrorNotification:(NSNotification*)note {
    NSLog(@"captureSessionRuntimeErrorNotification!");
}


- (void)startCaptureSession {

    // Create session
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;

    // Init the device inputs
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack]
                                                                              error:nil];
    [self.captureSession addInput:videoInput];

    // setup video data output
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.captureSession addOutput:videoDataOutput];

    // Setup the preview view.
    self.cameraView.session = self.captureSession;

    [self.captureSession startRunning];
}

- (void)stopCaptureSession {
    [self.captureSession stopRunning];
    self.captureSession = nil;
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

@end
