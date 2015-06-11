//
//  ViewController.m
//  02-上传多个文件
//
//  Created by cxc on 15/6/9.
//  Copyright (c) 2015年 china. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSString *path1 = [[NSBundle mainBundle]pathForResource:@"001.png" ofType:nil];
    NSData *data1 = [NSData dataWithContentsOfFile:path1];
    
    NSString *path2 = [[NSBundle mainBundle]pathForResource:@"demo.jpg" ofType:nil];
    NSData *data2 = [NSData dataWithContentsOfFile:path2];
    
    NSDictionary *fileDict = @{@"abc.png":data1};
    NSDictionary *params = @{@"status":@"嘚瑟"};
    
    
    [self uploadFile:fileDict fieldName:@"userfile[]" params:params];
}
#define boundary @"cxc-upload"
- (void)uploadFile:(NSDictionary *)fileDict fieldName:(NSString *)fieldName params:(NSDictionary *)params{
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/post/upload.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *type = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
     
    request.HTTPBody = [self formData:fileDict fieldName:fieldName params:params];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]);
    }];
}

- (NSData *)formData:(NSDictionary *)fileDict fieldName:(NSString *)fieldName params:(NSDictionary *)params{
    
    NSMutableData *dataM = [NSMutableData data];
    
    
    
    [fileDict enumerateKeysAndObjectsUsingBlock:^(NSString *fileName, NSData *fileData, BOOL *stop) {
    
        NSMutableString *stringM = [NSMutableString string];
        
        [stringM appendFormat:@"--%@\r\n",boundary];
        [stringM appendFormat:@"Content-Disposition: form-data; name=\"%@\";filename=\"%@\"\r\n",fieldName,fileName];
        [stringM appendFormat:@"Content-Type:application/octet-stream\r\n\r\n"];
        
        [dataM appendData:[stringM dataUsingEncoding:NSUTF8StringEncoding]];
        [dataM appendData:fileData];
        [dataM appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableString *strM = [NSMutableString string];
        
        [strM appendFormat:@"--%@\r\n", boundary];
        [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
        [strM appendFormat:@"%@\r\n", obj];
        
        // 添加到 dataM
        [dataM appendData:[strM dataUsingEncoding:NSUTF8StringEncoding]];
    }];
  
    
    
    NSString *tail = [NSString stringWithFormat:@"--%@--",boundary];
    [dataM appendData:[tail dataUsingEncoding:NSUTF8StringEncoding]];
    
    return dataM.copy;
}
@end
