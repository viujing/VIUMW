//
//  ViuMiddleware.m
//
//  Created by JNWHYJ on 2021/5/16.
//  Copyright © 2021 JNWHYJ. All rights reserved.
//

#import "ViuMiddleware.h"

#import <objc/runtime.h>

#import <CoreGraphics/CoreGraphics.h>

NSString * const kSwiftTargetModuleName = @"kSwiftTargetModuleName";
NSString * const kNotificationNameMethodNofound = @"kNotificationNameMethodNofound";

@interface ViuMiddleware ()

@property (nonatomic, strong) NSMutableDictionary *cachedTarget;//缓存集

@end

@implementation ViuMiddleware

#pragma mark - public methods
+ (instancetype)shared
{
    static ViuMiddleware *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ViuMiddleware alloc] init];
        [instance cachedTarget];
    });
    return instance;
}
- (void)mwLog:(NSString*)msg{
#ifdef DEBUG
    NSLog(@"mwLog-->(%@)",msg);
#endif
}
/**
 target and action with params
 */
- (id)performTarget:(NSString *)targetName
             action:(NSString *)actionName
             params:(NSDictionary *)params
  shouldCacheTarget:(BOOL)shouldCacheTarget
{
    if (targetName == nil || actionName == nil) {
        return nil;
    }
    //Swift module name
    NSString *swiftModuleName = params[kSwiftTargetModuleName];
    
    // 生成指定对象
    NSString *classString_ = nil;
    if (swiftModuleName.length > 0) {
        classString_ = [NSString stringWithFormat:@"%@.%@", swiftModuleName, targetName];
    } else {
        classString_ = [NSString stringWithFormat:@"%@", targetName];
    }
    NSObject *target = [self get_CachedTarget:classString_];
    if (target == nil) {
        Class class_ = NSClassFromString(classString_);
        target = [[class_ alloc] init];
    }
    
    // 生成指定方法
    NSString *actionString_ = [NSString stringWithFormat:@"%@", actionName];
    SEL action = NSSelectorFromString(actionString_);
    
    if (target == nil) {
        //去指定的页面 或 调用者自行处理
        [self noFoundResponseWithClassString:classString_ selectorString:actionString_ originParams:params];
        return nil;
    }
    
    if (shouldCacheTarget) {
        [self set_CachedTarget:target key:classString_];
    }
    
    if ([target respondsToSelector:action]) {
        return [self doPerformAction:action target:target params:params];
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
            return [self doPerformAction:action target:target params:params];
        } else {
            //去指定的页面 或 调用者自行处理
            [self noFoundResponseWithClassString:classString_ selectorString:actionString_ originParams:params];
            @synchronized (self) {
                [self.cachedTarget removeObjectForKey:classString_];
            }
            return nil;
        }
    }
}

- (void)cleanupCachedTarget:(NSString *)fullTargetName
{
    if (fullTargetName == nil) {
        return;
    }
    @synchronized (self) {
        [self.cachedTarget removeObjectForKey:fullTargetName];
    }
}

#pragma mark - private methods
- (void)noFoundResponseWithClassString:(NSString *)targetString
                        selectorString:(NSString *)selectorString
                          originParams:(NSDictionary *)originParams
{
    SEL action = NSSelectorFromString(@"actionNofoud:");
    NSObject *target = [[NSClassFromString(@"ViuNofound") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    
    [self doPerformAction:action target:target params:params];
}

- (id)doPerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    NSMethodSignature* method_ = [target methodSignatureForSelector:action];
    if(method_ == nil) {
        [self mwLog:@"method-nil-action"];
        return nil;
    }
    const char* retType = [method_ methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0) {
        [self mwLog:@"void-action"];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method_];
        //        [invocation setArgument:&params atIndex:0];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }
    
    if (strcmp(retType, @encode(NSInteger)) == 0) {
        [self mwLog:@"NSInteger-action"];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method_];
        //        [invocation setArgument:&params atIndex:1];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(BOOL)) == 0) {
        [self mwLog:@"BOOL-action"];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method_];
        //        [invocation setArgument:&params atIndex:1];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(CGFloat)) == 0) {
        [self mwLog:@"CGFloat-action"];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method_];
        //        [invocation setArgument:&params atIndex:1];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(float)) == 0) {
        [self mwLog:@"float-action"];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method_];
        //        [invocation setArgument:&params atIndex:1];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        float result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        [self mwLog:@"NSUInteger-action"];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method_];
        //        [invocation setArgument:&params atIndex:1];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self mwLog:@"default-action"];
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

#pragma mark - getters and setters
- (NSMutableDictionary *)cachedTarget
{
    if (_cachedTarget == nil) {
        _cachedTarget = [[NSMutableDictionary alloc] init];
    }
    return _cachedTarget;
}

- (NSObject *)get_CachedTarget:(NSString *)key {
    @synchronized (self) {
        return self.cachedTarget[key];
    }
}

- (void)set_CachedTarget:(NSObject *)target key:(NSString *)key {
    @synchronized (self) {
        self.cachedTarget[key] = target;
    }
}

@end

ViuMiddleware* _Nonnull MW(void){
    return [ViuMiddleware shared];
};
