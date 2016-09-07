//
//  Helper.m
//  PrimusIOSpike
//
//  Created by DNA on 9/6/16.
//
//

#import "Helper.h"

@implementation Helper

+ (CGFloat) getScreenHeight {
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (CGFloat) getScreenWidth {
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (void) showLoader:(UIView *)view {
    UIView *screen = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    spinner.center = [screen center];
    spinner.hidesWhenStopped = YES;
    [screen addSubview:spinner];
    [spinner startAnimating];
    
    [view addSubview:screen];
}

+ (void) hideLoader:(UIView *)view {
    
}

+ (NSString *) dateToISO8601:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSString *ISO8601 = [formatter stringFromDate:date];
    return ISO8601;
}

+ (NSDate *) ISO8601ToDate:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

+ (NSString *) dictionaryToString:(NSDictionary *)dictionary {
    NSMutableString *result = [NSMutableString string];
    for (NSString *key in [dictionary allKeys]) {
        id value = dictionary[key];
        if (result.length) {
            [result appendString:@" "];
        }
        [result appendFormat:@"%@=%@", key, [value description]];
    }
    return result;
}

+ (NSDictionary *) stringToDictionary:(NSString *)string {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *array = [string componentsSeparatedByString:@" "];
    for (NSString *pair in array) {
        NSArray *parts = [pair componentsSeparatedByString:@"="];
        dict[parts[0]] = parts[1];
    }
    return dict;
}

@end
