//
//  Macro.h
//  BD Foundation
//
//  Created by Liu Wanwei 2014 12 9
//  Copyright (c) 2014年 yuteng. All rights reserved.
//

#ifndef __MACRO_H__
#define __MACRO_H__

/* 预定义宏*/


#ifdef DEBUG
//Debug模式
//...

#else
//发布模式
//...

#endif

//区分模拟器和真机
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//ARC
#if __has_feature(objc_arc)
//compiling with ARC
#else
// compiling without ARC
#endif

//StoryBoard
#define STORYBOARD(name) (UIStoryboard *)[UIStoryboard storyboardWithName:name bundle:nil]
#define STORYBOARDVC(name, identifier) [(STORYBOARD(name)) instantiateViewControllerWithIdentifier:identifier]

//System
#define PasteString(string)   [[UIPasteboard generalPasteboard] setString:string];
#define PasteImage(image)     [[UIPasteboard generalPasteboard] setImage:image];

//Image
//可拉伸的图片

#define ResizableImage(name,top,left,bottom,right) [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom,right)]
#define ResizableImageWithMode(name,top,left,bottom,right,mode) [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom,right) resizingMode:mode]

//file
//读取文件的文本内容,默认编码为UTF-8
#define FileString(name,ext)            [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(name) ofType:(ext)] encoding:NSUTF8StringEncoding error:nil]
#define FileDictionary(name,ext)        [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(name) ofType:(ext)]]
#define FileArray(name,ext)             [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(name) ofType:(ext)]]

//数学
#define PI 3.14159

#define kYes        @"yes"
#define kNo         @"no"

//输出frame(frame是结构体，没法%@)
//#define LOGFRAME(f) NSLog(@"\nx:%f\ny:%f\nwidth:%f\nheight:%f\n",f.origin.x,f.origin.y,f.size.width,f.size.height)
// 使用：NSStringFromCGRect()
//#define LOGBOOL(b)  NSLog(@"%@",b?@"YES":@"NO");
// 使用：NSStringFromBool()

//弹出信息
#define ALERT(msg) [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show]

//App
#define kApp ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define kNav ((AppDelegate *)[UIApplication sharedApplication].delegate.navigationController)
#define kWindow [UIApplication sharedApplication].keyWindow
#define LastWindow [[[UIApplication sharedApplication] windows] lastObject]
//color
#define RGB(r, g, b)             [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define RGBAlpha(r, g, b, a)     [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

//font
#define CUSTOMFONT(a)    [UIFont fontWithName:@"Heiti SC" size:a]
#define CUSTOMNUMBERFONT(a)    [UIFont fontWithName:@"Arial" size:a]
#define SYSFONT_30       [UIFont fontWithName:@"Helvetica" size:15]
#define SYSFONT_33       [UIFont fontWithName:@"Helvetica" size:16.5]
#define SYSFONT_33_B     [UIFont fontWithName:@"Helvetica-Bold" size:16.5]
#define SYSFONT_37_B     [UIFont fontWithName:@"Helvetica-Bold" size:18.5]
#define SYSFONT_37       [UIFont fontWithName:@"Helvetica" size:18.5]

//转换
#define I2S(number) [NSString stringWithFormat:@"%d",number]
#define F2S(number) [NSString stringWithFormat:@"%f",number]
#define DATE(stamp) [NSDate dateWithTimeIntervalSince1970:[stamp intValue]];

//设备屏幕尺寸
#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Frame    (CGRectMake(0, 0 ,kScreen_Width,kScreen_Height))
#define kScreen_CenterX  kScreen_Width/2
#define kScreen_CenterY  kScreen_Height/2

//应用尺寸(不包括状态栏,通话时状态栏高度不是20，所以需要知道具体尺寸)
#define kContent_Height   ([UIScreen mainScreen].applicationFrame.size.height)
#define kContent_Width    ([UIScreen mainScreen].applicationFrame.size.width)
#define kContent_Frame    (CGRectMake(0, 0 ,kContent_Width,kContent_Height))
#define kContent_CenterX  kContent_Width/2
#define kContent_CenterY  kContent_Height/2

//GCD
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

//Device
#define CurrentVersion [[[UIDevice currentDevice] systemVersion] intValue]

#define isIOS4 ([[[UIDevice currentDevice] systemVersion] intValue]==4)
#define isIOS5 ([[[UIDevice currentDevice] systemVersion] intValue]==5)
#define isIOS6 ([[[UIDevice currentDevice] systemVersion] intValue]==6)
#define isAfterIOS4 ([[[UIDevice currentDevice] systemVersion] intValue]>4)
#define isAfterIOS5 ([[[UIDevice currentDevice] systemVersion] intValue]>5)
#define isAfterIOS6 ([[[UIDevice currentDevice] systemVersion] intValue]>6)

#define iOS ([[[UIDevice currentDevice] systemVersion] floatValue])

#define isRetina ([[UIScreen mainScreen] scale]==2)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//拨打电话
#define canTel                 ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]])
#define tel(phoneNumber)       ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]]])
#define telprompt(phoneNumber) ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",phoneNumber]]])

//打开URL
#define canOpenURL(appScheme) ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appScheme]])
#define openURL(appScheme) ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:appScheme]])

//
#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
static className *shared##className = nil; \
+ (className *)shared##className { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
@synchronized(self){ \
shared##className = [[self alloc] init]; \
} \
}); \
return shared##className; \
}


#endif
