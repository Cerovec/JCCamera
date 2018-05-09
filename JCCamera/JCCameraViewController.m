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

@interface JCCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet JCCameraView *cameraView;

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic) dispatch_queue_t sessionQueue;

@property (nonatomic) dispatch_queue_t processingQueue;

- (IBAction)closeCamera:(id)sender;

@end

@implementation JCCameraViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.processingQueue = dispatch_queue_create("processing queue", DISPATCH_QUEUE_SERIAL);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNotificationObserver];
}

- (void)viewDidAppear:(BOOL)animate {
    [super viewDidAppear:animate];
    [self startCaptureSession];
};

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCaptureSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeNotificationObserver];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // Note that the app delegate controls the device orientation notifications required to use the device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.cameraView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

#pragma mark - Notifications

- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appplicationWillEnterForeground:(NSNotification*)note {
    NSLog(@"appplicationWillEnterForeground!");
    [self startCaptureSession];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)note {
    NSLog(@"applicationDidEnterBackgroundNotification!");
    [self stopCaptureSession];
}

#pragma mark - Button handlers

- (IBAction)closeCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Status bar appearance

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)startCaptureSession {

    dispatch_async(self.sessionQueue, ^{

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
        [videoDataOutput setSampleBufferDelegate:self queue:self.processingQueue];
        videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        [self.captureSession addOutput:videoDataOutput];

        [self.captureSession startRunning];

        dispatch_async(dispatch_get_main_queue(), ^{
            // Setup the preview view.
            self.cameraView.session = self.captureSession;
        });
    });
}

- (void)stopCaptureSession {
    dispatch_async(self.sessionQueue, ^{
        [self.captureSession stopRunning];
        self.captureSession = nil;
    });
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                                                                                            mediaType:AVMediaTypeVideo
                                                                                                                             position:position];
    NSArray *devices = [captureDeviceDiscoverySession devices];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    NSLog(@"Frame!");
}

@end
