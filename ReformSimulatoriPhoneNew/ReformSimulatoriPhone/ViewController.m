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
{
    NSMutableArray *resultImageArray;
    int *savedPhotoCount;
}

@end

@implementation ViewController
@synthesize pickerView;
@synthesize nextButton, shutterButton;

#pragma mark - iVars
NSMutableArray *titleArray;
int indexCount;

//#pragma mark - Init
//- (id)init {
//	self = [super init];
//	if (self) {
//		titleArray = [NSMutableArray arrayWithObjects:@"1.JPG", @"2.JPG", @"3.JPG", @"4.JPG", @"5.JPG", @"6.JPG", @"7.JPG", @"8.JPG", @"9.JPG", @"10.JPG", @"11.JPG", @"12.JPG", @"13.JPG", @"14.JPG", @"15.JPG", nil];
//		indexCount = 0;
//	}
//	return self;
//}

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
    
    // 合成した写真を入れる配列を初期化
    resultImageArray = [[NSMutableArray alloc]init];
    
    // NSCachesDirectoryを引数に渡し、戻ってきた配列の
    // 一つ目の要素を取得するとCacheディレクトリを取得できます。
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirPath = [array objectAtIndex:0];
    
    // まずは、新規で作るディレクトリの絶対パスを作成します。
    
    NSString *newCacheDirPath = [cacheDirPath stringByAppendingPathComponent:@"sampleDirectory"];
    // 次にFileManagerを用いて、ディレクトリの作成を行います。
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL created = [fileManager createDirectoryAtPath:newCacheDirPath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    // 作成に失敗した場合は、原因をログに出します。
    if (!created) {
        NSLog(@"failed to create directory. reason is %@ - %@", error, error.userInfo);
    }
    
    // 保存するデータ。
    // 今回は、サーバー上のデータを直接取得して、NSData形式で保持します。
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.yoheim.net/image/108.png"]];
    
    // 保存する先のパス
    NSString *savedPath = [newCacheDirPath stringByAppendingPathComponent:@"110.png"];
    
    // 保存処理を行う。
    // 失敗した場合には、NSErrorのインスタンスを得られるので、
    // その情報を表示する。
    BOOL success1 = [fileManager createFileAtPath:savedPath contents:imgData attributes:nil];
    if (!success1) {
        NSLog(@"failed to save image. reason is %@ - %@", error, error.userInfo);
    }
    
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
    // コネクションを検索
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
            break;
    }
    
    // 静止画をキャプチャする
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                   completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             // キャプチャしたデータを取る
             NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             capturedImage = [UIImage imageWithData:data];
         }
     }];
    
    [self.view addSubview:self.previewImageView];
    UIImageView *overlayImageView = [self.pickerView.scrollView.subviews objectAtIndex:0];
    UIImage *overlayImage = overlayImageView.image;
//    NSLog(@"count:%d",[pickerView.scrollView.subviews count]);
    
    CGSize size = {self.view.frame.size.width,self.view.frame.size.height};
    UIGraphicsBeginImageContext(size);
    
    CGRect rect;
    rect.origin = CGPointZero;
    
    rect.size = size;
    [capturedImage drawInRect:rect];
    [overlayImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.5];
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [resultImageArray addObject:resultImage];

    // デバッグ用
    self.previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height/2)];
    self.previewImageView.image = resultImage;
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%d.png" , [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],[resultImageArray count]];
    
    [self CreatePngImageFile:filePath TargetImage:resultImage];
    
}

#pragma mark - Custom Methods
- (void)CreatePngImageFile:(NSString*)filePath TargetImage:(UIImage*)image
{
    //bool result = false;
    //
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filePath atomically:YES];
    
    savedPhotoCount++;
    //
    //return result;
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
	return img.size.width;
}



@end
