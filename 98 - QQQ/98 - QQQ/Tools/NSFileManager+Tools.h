#import <Foundation/Foundation.h>

@interface NSFileManager(Tools)

// 在缓存目录创建指定名称的文件夹
// 提示：如果文件夹不存在，往文件夹中写入文件，没有提示，不会报错，也没有写入
+ (NSString *)createDirInCachePathWithName:(NSString *)name;

@end
