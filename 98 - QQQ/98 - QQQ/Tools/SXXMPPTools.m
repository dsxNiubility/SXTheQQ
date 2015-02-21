//
//  SXXMPPTools.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/21.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXXMPPTools.h"

@implementation SXXMPPTools

+ (instancetype)sharedXMPPTools {
    static SXXMPPTools *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
