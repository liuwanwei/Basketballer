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


// 根据URL提取图片，只在get时做缓存
- (UIImage *)imageWithName:(NSString *)name{
    UIImage * image = nil;
    if (nil == name) {
        return nil;
    }
    
    image = [sImageCache objectForKey:name];
    if (image) {
        return image;
    }else{
        NSURL * url = [NSURL URLWithString:[self localPathForImageName:name]];
        NSData * data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data];
        if (image == nil) {
            NSLog(@"加载图片失败: %@", url);
            return nil;
        }
        
        // 更新缓存(做线程安全处理)
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
           [sImageCache setObject:image forKey:name];
        });
    }
    
    return image;
}

// 对外封装接口，参数path实际上是存储的文件名。
- (UIImage *)imageForPath:(NSString *)path{
    return [self imageWithName:path];
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
    if([data writeToURL:url atomically:NO]){
        NSLog(@"保存图片到：%@", url);
    }
}

// 根据类型和对象id保存对象图片：返回图片保存路径
- (NSString *)saveImage:(UIImage *)image withProfileType:(NSString*)type withObjectId:(NSNumber *)objectId{
    // 根据Team.id生成图片保存路径。
    NSURL * imageURL = [self makeImageUrlWithProfileType:type withObjectId:objectId];
    
    // 保存图片到文件系统。
    [self saveProfileImage:image toURL:imageURL];
    
    return [self imageNameForLocalPath:[imageURL absoluteString]];
}

-(NSURL*)localDocumentsDirectoryURL {
    static NSURL *localDocumentsDirectoryURL = nil;
    if (localDocumentsDirectoryURL == nil) {
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
                                                                                NSUserDomainMask, YES ) objectAtIndex:0];
        localDocumentsDirectoryURL = [NSURL fileURLWithPath:documentsDirectoryPath];
    }
    return localDocumentsDirectoryURL;
}

// 从文件路径中提取文件名
- (NSString *)imageNameForLocalPath:(NSString *)path{
    return [path lastPathComponent];
}

// 根据文件名生成文件在沙盒根目录下的路径
- (NSString *)localPathForImageName:(NSString *)name{
    NSURL * url = [self localDocumentsDirectoryURL];
    return [[url URLByAppendingPathComponent:name isDirectory:NO] absoluteString];
}

@end
