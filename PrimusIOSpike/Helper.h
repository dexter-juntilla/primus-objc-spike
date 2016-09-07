//
//  Helper.h
//  PrimusIOSpike
//
//  Created by DNA on 9/6/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (CGFloat) getScreenWidth;
+ (CGFloat) getScreenHeight;
+ (void) showLoader:(UIView *)view;
+ (void) hideLoader:(UIView *)view;
+ (NSString *) dateToISO8601:(NSDate *)date;
+ (NSDate *) ISO8601ToDate:(NSString *)dateString;
+ (NSString *) dictionaryToString:(NSDictionary *)dictionary;
+ (NSDictionary *) stringToDictionary:(NSString *)string;

@end
