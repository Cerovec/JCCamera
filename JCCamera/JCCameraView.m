//
//  JCCameraVIew.m
//  JCCamera
//
//  Created by Jura on 09/08/15.
//  Copyright © 2015 MicroBlink. All rights reserved.
//

#import "JCCameraView.h"

@implementation JCCameraView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.session = session;
}

@end
