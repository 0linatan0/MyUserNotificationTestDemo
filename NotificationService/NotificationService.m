//
//  NotificationService.m
//  NotificationService
//
//  Created by 谭丽 on 16/8/8.
//  Copyright © 2016年 linatan. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    NSDictionary *apsDic = [request.content.userInfo objectForKey:@"aps"];
    NSString *attachUrl = [apsDic objectForKey:@"image"];
    NSLog(@"%@",attachUrl);
    
    //    //下载图片，放到本地
    //    UIImage * imageFromURL = [self getImageFromURL:attachUrl];
    //
    //    //获取document目录
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES );
    //    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    //    NSLog(@"document path: %@",documentsDirectoryPath);
    //
    //    NSString *localPath = [self saveImage:imageFromURL withFileName:@"MyImage" ofType:@"png" inDirectory:documentsDirectoryPath];
    //    if (localPath && ![localPath  isEqualToString: @""])
    //    {
    //        UNNotificationAttachment *attch= [UNNotificationAttachment attachmentWithIdentifier:@"photo"
    //                                                                                        URL:[NSURL URLWithString:[@"file://" stringByAppendingString:localPath]]
    //                                                                                    options:nil
    //                                                                                      error:nil];
    //        if(attch)
    //        {
    //            self.bestAttemptContent.attachments = @[attch];
    //        }
    //    }
    //    self.contentHandler(self.bestAttemptContent);
    
    
    
    //另一种方式
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:attachUrl];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url
                                                        completionHandler:^(NSURL * _Nullable location,
                                                                            NSURLResponse * _Nullable response,
                                                                            NSError * _Nullable error) {
                                                            NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                                                            // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
                                                            NSString *file = [caches stringByAppendingPathComponent:response.suggestedFilename];
                                                            
                                                            // 将临时文件剪切或者复制Caches文件夹
                                                            NSFileManager *mgr = [NSFileManager defaultManager];
                                                            
                                                            // AtPath : 剪切前的文件路径
                                                            // ToPath : 剪切后的文件路径
                                                            [mgr moveItemAtPath:location.path toPath:file error:nil];
                                                            
                                                            if (file && ![file  isEqualToString: @""])
                                                            {
                                                                UNNotificationAttachment *attch= [UNNotificationAttachment attachmentWithIdentifier:@"photo"
                                                                                                                                                URL:[NSURL URLWithString:[@"file://" stringByAppendingString:file]]
                                                                                                                                            options:nil
                                                                                                                                              error:nil];
                                                                if(attch)
                                                                {
                                                                    self.bestAttemptContent.attachments = @[attch];
                                                                }
                                                            }
                                                            self.contentHandler(self.bestAttemptContent);
                                                        }];
    [downloadTask resume];
    
}

- (UIImage *) getImageFromURL:(NSString *)fileURL {
    //    NSString *mockUrl = @"http://upload-images.jianshu.io/upload_images/1290592-0bb04aa98649aecf.png";
    //    NSString *mockUrl = @"https://picjumbo.imgix.net/HNCK8461.jpg?q=40&w=200&sharp=30";
    NSLog(@"执行图片下载函数");
    UIImage * result;
    //dataWithContentsOfURL方法需要https连接
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}


//将所下载的图片保存到本地
-(NSString *) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    NSString *urlStr = @"";
    if ([[extension lowercaseString] isEqualToString:@"png"])
    {
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [UIImagePNGRepresentation(image) writeToFile:urlStr options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] ||
               [[extension lowercaseString] isEqualToString:@"jpeg"])
    {
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:urlStr options:NSAtomicWrite error:nil];
    } else
    {
        NSLog(@"extension error");
    }
    return urlStr;
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}


@end
