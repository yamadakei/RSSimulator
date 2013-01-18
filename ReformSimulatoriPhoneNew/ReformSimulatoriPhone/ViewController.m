//
//  ViewController.m
//  ReformSimulatoriPhone
//
//  Created by 山田 慶 on 2013/01/17.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize pickerView;
@synthesize nextButton, shutterButton;

#pragma mark - iVars
NSMutableArray *titleArray;
int indexCount;

#pragma mark - Init
- (id)init {
	self = [super init];
	if (self) {
        NSLog(@"tomagittest");//gitの使用確認の為(一時的な確認のため、後削除します)
		titleArray = [NSMutableArray arrayWithObjects:@"1.JPG", @"2.JPG", @"3.JPG", @"4.JPG", @"5.JPG", @"6.JPG", @"7.JPG", @"8.JPG", @"9.JPG", @"10.JPG", @"11.JPG", @"12.JPG", @"13.JPG", @"14.JPG", @"15.JPG", nil];
		indexCount = 0;
	}
	return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    titleArray = [NSMutableArray arrayWithObjects:@"1.JPG", @"2.JPG", @"3.JPG", @"4.JPG", @"5.JPG", @"6.JPG", @"7.JPG", @"8.JPG", @"9.JPG", @"10.JPG", @"11.JPG", @"12.JPG", @"13.JPG", @"14.JPG", @"15.JPG", nil];
    indexCount = 0;
    
    // ビデオキャプチャデバイスの取得
    AVCaptureDevice* device;
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // デバイス入力の取得
    AVCaptureDeviceInput* deviceInput;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
    // ビデオデータ出力の作成
    NSMutableDictionary* settings;
//    AVCaptureVideoDataOutput* dataOutput;
//    settings = [NSMutableDictionary dictionary];
//    [settings setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
//                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//    dataOutput = [[AVCaptureVideoDataOutput alloc] init];
//    dataOutput.videoSettings = settings;
//    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    // セッションの作成
    session = [[AVCaptureSession alloc] init];
    
    // 入力の作成
    [session addInput:deviceInput];
    
    // AVCaptureStillImageOutputで静止画出力を作る
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey, nil];
    stillImageOutput.outputSettings = outputSettings;

    // 出力の作成
    [session addOutput:stillImageOutput];
    
    // プレビューレイヤーを作成
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    // リサイズ形式を設定
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // フレームサイズを設定
    videoPreviewLayer.frame = self.view.bounds;
    // ビューのサブレイヤーにビデオ出力レイヤーを追加
    [self.view.layer addSublayer:videoPreviewLayer];

    
    if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        session.sessionPreset = AVCaptureSessionPresetMedium;
    }
    
    // セッションの開始
    [session startRunning];
    
    CGFloat margin = 0.0f;
	CGFloat width = (self.view.bounds.size.width - (margin * 2.0f));
	CGFloat pickerHeight = 240.0f;
	CGFloat x = margin;
	CGFloat y = 0.0f;
	CGFloat spacing = 50.0f;
	CGRect tmpFrame = CGRectMake(x, y, width, pickerHeight);
    
	pickerView = [[V8HorizontalPickerView alloc] initWithFrame:tmpFrame];
	pickerView.backgroundColor   = [UIColor clearColor];
	pickerView.delegate    = self;
	pickerView.dataSource  = self;
	pickerView.selectionPoint = CGPointMake(self.view.frame.size.width/2, 0);
    [self.view addSubview:pickerView];
    
	self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = CGRectMake(x, y, width, 50.0f);
	nextButton.frame = tmpFrame;
	[nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[nextButton	setTitle:@"Center Element 0" forState:UIControlStateNormal];
	nextButton.titleLabel.textColor = [UIColor blackColor];
	[self.view addSubview:nextButton];
    
    self.shutterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = CGRectMake(x, y, width, 50.0f);
	shutterButton.frame = tmpFrame;
	[shutterButton addTarget:self action:@selector(shutterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[shutterButton	setTitle:@"Take Photo" forState:UIControlStateNormal];
	shutterButton.titleLabel.textColor = [UIColor blackColor];
	[self.view addSubview:shutterButton];


    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[pickerView scrollToElement:0 animated:NO];
}

#pragma mark - Button Tap Handlers
- (void)nextButtonTapped:(id)sender {
	[pickerView scrollToElement:indexCount animated:YES];
	indexCount += 3;
	if ([titleArray count] <= indexCount) {
		indexCount = 0;
	}
	[nextButton	setTitle:[NSString stringWithFormat:@"Center Element %d", indexCount]
				forState:UIControlStateNormal];
}

- (void)shutterButtonTapped:(id)sender {
	// change our title array so we can see a change
	if ([titleArray count] > 1) {
		[titleArray removeLastObject];
	}
    
	[pickerView reloadData];
}

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [titleArray count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (UIImage *)horizontalPickerView:(V8HorizontalPickerView *)picker imageForElementAtIndex:(NSInteger)index {
    return [titleArray objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[titleArray objectAtIndex:index]]];
    NSLog(@"%f",img.size.width);
	return img.size.width;
}



@end
