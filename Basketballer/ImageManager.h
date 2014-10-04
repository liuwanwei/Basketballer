//
//  ImageManager.h
//  Basketballer
//
//  Created by sungeo on 14-10-4.
//
//

#import <Foundation/Foundation.h>

#define kProfileTypeTeam      @"TeamProfile_"
#define kProfileTypePlayer    @"PlayerProfile_"

@interface ImageManager : NSObject

+ (ImageManager *)defaultInstance;

// 创建对象图片
- (NSString *)saveImage:(UIImage *)image withProfileType:(NSString*)type withObjectId:(NSNumber *)objectId;

// 更新图片内容
- (void)saveProfileImage:(UIImage *)image toURL:(NSURL *) url;

// 获取球队图片对象。
// 注意：由于球队可能使用默认图片，而默认图片保存在资源而非文件系统中，这两种方式的图片加载方式也有不同。
// 为便于使用，请调用者通过下面的接口获取球队图片在内存中的对象，而不要直接访问Team.profileURL。
- (UIImage *)imageForPath:(NSString *)path;
//- (UIImage *)imageForUrl:(NSURL *)url;

@end
