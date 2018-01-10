//
//  WebServiceWapper.m
//  AOV
//
//  Created by Tejas Ardeshna on 25/12/14.
//  Copyright (c) 2014 Twizz Ltd All rights reserved.
//

#import "WebServiceWapper.h"

static WebServiceWapper *instance;


@implementation WebServiceWapper

+(WebServiceWapper *)getInstance{
    if (instance==nil) {
        instance=[[WebServiceWapper alloc]init];
    }
    return instance;
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}
+(void)PostDataDict:(NSDictionary *)dict andMultiPartImage:(UIImage *)image andMehod:(NSString *)strUrl imageName:(NSString *)imgName isLoading:(BOOL)loading andToken:(NSString *)token withBlock:(myCompletionA)compileBlock
{
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *key in [dict allKeys])
    {
         //1
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[dict objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    if (image!=nil)
    {
       // [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData* imageData = UIImageJPEGRepresentation(image,0.8);
//        NSLog(@"%@",[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n",imgName,[self contentTypeForImageData:imageData]]);
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n",imgName,[self contentTypeForImageData:imageData]] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n"dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[NSData dataWithData:imageData]];
//        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=imageName.jpg\r\n", imgName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *imageData123 = body;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.HTTPMaximumConnectionsPerHost = 1;
    
    [config setTimeoutIntervalForRequest:300];
    
    NSURLSession *upLoadSession;
    NSURLSessionUploadTask *uploadTask;
    upLoadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

//    let url = "\(APIConstants.TwizzBaseUrl)/\(APIConstants.TwizzAPIVersion)/\(endpoint)/"
    NSString *baseUrl = @"http://staging.twizz.com/api/v1/";
    NSString *Insert_Question=[NSString stringWithFormat:@"%@%@",baseUrl,strUrl];
    NSURL *url = [NSURL URLWithString:Insert_Question];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"post"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    //[request addValue:token forHTTPHeaderField:@"Authorization"];
    [request setTimeoutInterval:300];
    [request setAllowsCellularAccess:YES];
    
    uploadTask=[upLoadSession uploadTaskWithRequest:request fromData:imageData123 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
            NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str);
            if (data != nil){
                dict1=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                NSLog(@"dict %@",dict1);
                // [SVProgressHUD showSuccessWithStatus:@"Sucdessfull created profile"];
                if ([[dict1 valueForKey:@"status"] isEqualToString:@"success"] || [[dict1 valueForKey:@"status"] isEqualToString:@"Success"])
                {
                    
                    //[SVProgressHUD showSuccessWithStatus:@"Profile created successfully!!!"];
                    compileBlock(dict1,WebServiceResultSuccess);
                }
                else
                {
                    
                    compileBlock(dict1,WebServiceResultFail);
                }
            }
            else{
                compileBlock(dict1,WebServiceResultFail);
            }
            
        });
    }];
    
    [uploadTask resume];


}
@end

