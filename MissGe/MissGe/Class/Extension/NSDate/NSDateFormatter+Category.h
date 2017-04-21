//
//  NSDate+Current.h
//  DateTest
//
//  Created by chengxianghe on 15/11/4.
//  Copyright © 2015年 CXH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Category)

+ (NSDateFormatter *)dateFormatter;
+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)dateFormat;

/**yyyy-MM-dd HH:mm:ss*/
+ (NSDateFormatter *)defaultDateFormatter;

/**yyyy年MM月dd日*/
+ (NSDateFormatter *)defaultChinaDateFormatter;
@end
