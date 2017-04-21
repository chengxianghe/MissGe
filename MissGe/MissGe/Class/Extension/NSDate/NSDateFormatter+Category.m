//
//  NSDate+Current.h
//  DateTest
//
//  Created by chengxianghe on 15/11/4.
//  Copyright © 2015年 CXH. All rights reserved.
//


#import "NSDateFormatter+Category.h"

@implementation NSDateFormatter (Category)

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[self alloc] init];
    });
    return dateFormatter;
}


+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [self dateFormatter];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (NSDateFormatter *)defaultDateFormatter
{
    return [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSDateFormatter *)defaultChinaDateFormatter
{
    return [self dateFormatterWithFormat:@"yyyy年MM月dd日"];
}


@end
