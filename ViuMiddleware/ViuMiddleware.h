//
//  ViuMiddleware.h
//
//  Created by JNWHYJ on 2021/5/17.
//  Copyright © 2021 JNWHYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//key for swift module name
extern NSString * _Nonnull const kSwiftTargetModuleName;
//key for method:no-found of Notifcation action
extern NSString * _Nonnull const kNotificationNameMethodNofound;

@interface ViuMiddleware : NSObject
//调用单例的函数
+ (instancetype _Nonnull)shared;

// 本地 调用入口
- (id _Nullable )performTarget:(NSString * _Nullable)targetName
                        action:(NSString * _Nullable)actionName
                        params:(NSDictionary * _Nullable)params
             shouldCacheTarget:(BOOL)shouldCacheTarget;

// 清除缓存
- (void)cleanupCachedTarget:(NSString * _Nullable)fullTargetName;

@end

// 简化调用单例的函数
ViuMiddleware* _Nonnull MW(void);

NS_ASSUME_NONNULL_END
