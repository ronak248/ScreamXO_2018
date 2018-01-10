//
//  WebServiceWapper.h
//  Twizz
//
//  Created by Tejas Ardeshna on 25/12/14.
//  Copyright (c) 2014 Twizz Ltd All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM (NSInteger, WebServiceResult)
{
    WebServiceResultSuccess = 0,
    WebServiceResultFail,
    WebServiceResultError
};

typedef void(^myCompletion)(NSDictionary *data,WebServiceResult result);
typedef void(^myCompletionA)(NSDictionary *data,WebServiceResult result);
typedef void(^myimg)(UIImage *);
typedef void(^Prograss)(float);


@interface WebServiceWapper : NSObject<NSURLSessionDelegate,NSURLSessionDataDelegate>


+(WebServiceWapper *)getInstance;

+(void)PostDataDict:(NSDictionary *)dict andMultiPartImage:(UIImage *)image andMehod:(NSString *)strUrl imageName:(NSString *)imgName isLoading:(BOOL)loading andToken:(NSString *)token withBlock:(myCompletionA)compileBlock;
+(void)PatchDataDict:(NSDictionary *)dict andMultiPartImage:(UIImage *)image andMehod:(NSString *)strUrl imageName:(NSString *)imgName isLoading:(BOOL)loading andToken:(NSString *)token withBlock:(myCompletionA)compileBlock;
@end
