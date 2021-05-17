//
//  ViuNofound.m
//  SwiftDemo
//
//  Created by JNWHYJ on 2021/5/16.
//  Copyright © 2021 JNWHYJ. All rights reserved.
//

#import "ViuNofound.h"
#import "ViuMiddleware.h"
//#import "SwiftDemo-Swift.h"
@implementation ViuNofound

-(id)actionNofoud:(NSDictionary*)values{
//    NSLog(@"--actionTemp->%@",values);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificationNameMethodNofound
     object:values];
    return @"actionNofoud";
}
@end
