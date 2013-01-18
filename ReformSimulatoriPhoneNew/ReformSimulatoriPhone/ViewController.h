//
//  ViewController.h
//  ReformSimulatoriPhone
//
//  Created by 山田 慶 on 2013/01/17.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "V8HorizontalPickerView.h"

@class V8HorizontalPickerView;

@interface ViewController : UIViewController <V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *session;
}
@property (strong, nonatomic) UIImageView *rsImageView;

@property (nonatomic) V8HorizontalPickerView *pickerView;
@property (nonatomic) UIButton *nextButton;
@property (nonatomic) UIButton *reloadButton;


@end
