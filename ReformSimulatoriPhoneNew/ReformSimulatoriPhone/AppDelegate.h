//
//  AppDelegate.h
//  ReformSimulatoriPhone
//
//  Created by 山田 慶 on 2013/01/17.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSItem.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *imageItems;
@property (strong, nonatomic) NSMutableArray *logoItems;
@property (strong, nonatomic) NSMutableArray *descriptionItems;

@end
