//
//  ImageManager.m
//  Basketballer
//
//  Created by sungeo on 14-10-4.
//
//

#import "ImageManager.h"
#import "Team.h"

static  NSMutableDictionary * sImageCache = nil;

@implementation ImageManager

+ (ImageManager *)defaultInstance{
    static ImageManager * sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sInstance == nil) {
            sInstance = [[ImageManager alloc] init];
            sImageCache = [NSMutableDictionary dictionaryWithCapacity:100];
        }
    });
    
    return sInstance;
}


// 根据URL提取图片
- (UIImage *)imageForUrl:(NSURL *)url{
    UIImage * image = nil;
    if (nil == url) {
        return nil;
    }
    
    image = [sImageCache objectForKey:url];
    if (image) {
        return image;
    }else{
        NSData * data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data];
        
        // TODO：做线程安全处理
        [sImageCache setObject:image forKey:url];
    }
    
    return image;
}

- (UIImage *)imageForPath:(NSString *)path{
    NSURL * url = [NSURL URLWithString:path];
    return [self imageForUrl:url];
}


// 根据球队id，生成形如“file://xxx//xxx//TeamProfile_22331.png”形式的球队Logo保存路径，无子目录。
// $name - string - 球队id
- (NSURL *)makeImageUrlWithProfileType:(NSString *)type withObjectId:(NSNumber *)objectId{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSArray * paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL * documentDirectory = [paths objectAtIndex:0];
    
    NSString * filename = [NSString stringWithFormat:@"%@%@.png", type, objectId];
    
    NSURL * profileUrl = [documentDirectory URLByAppendingPathComponent:filename isDirectory:NO];
    
    return profileUrl;
}

// 保存UIImage图片对象到文件系统
- (void)saveProfileImage:(UIImage *)image toURL:(NSURL *) url{
    // TODO 暂时制作本地存储，调通后再往iCloud里加。
    NSData * data = UIImagePNGRepresentation(image);
    [data writeToURL:url atomically:YES];
    
    // 更新图片缓存。
    [sImageCache setObject:image forKey:url];
}

// 根据类型和对象id保存对象图片：返回图片保存路径
- (NSString *)saveImage:(UIImage *)image withProfileType:(NSString*)type withObjectId:(NSNumber *)objectId{
    // 根据Team.id生成图片保存路径。
    NSURL * imageURL = [self makeImageUrlWithProfileType:type withObjectId:objectId];
    
    // 保存图片到文件系统。
    [self saveProfileImage:image toURL:imageURL];
    
    return [imageURL absoluteString];
}


@end
