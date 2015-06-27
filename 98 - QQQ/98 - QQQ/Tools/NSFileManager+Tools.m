#import "NSFileManager+Tools.h"

@implementation NSFileManager(Tools)

+ (NSString *)createDirInCachePathWithName:(NSString *)name {
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [cachePath stringByAppendingPathComponent:name];
    
    /**
     参数：
     1. 要创建目录的完整路径名称字符串
     2. Intermediate: 如果指定多级目录都不存在，会一次性全部创建
     */
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    return path;
}

@end
