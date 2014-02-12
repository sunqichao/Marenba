//
//  AppDelegate.m
//  Marenba
//
//  Created by sun qichao on 14-2-8.
//  Copyright (c) 2014年 sun qichao. All rights reserved.
//

#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#include "lame.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    [Parse setApplicationId:@"5B5AXcZNTmHmz1kQsKJvpp9oVe4rptc1auzNfDN6"
                  clientKey:@"Pwr43TSY5CfCksr9JP13aJHSL4NzV2hLCpWM3Xdp"];
        
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    
//    dispatch_queue_t queue = dispatch_queue_create("uploadImageToForbesServerWithImage", NULL);
//    
//    dispatch_async(queue, ^(){
//        [self audio_PCMtoMP3];
//        NSData* dataImage = [NSData dataWithContentsOfFile:DefaultCafPathMp3];
//        
//        NSString *URLString = [NSString stringWithFormat:@"http://www.peng.local/api/message/upload/"];
//        
//        NSURL *url = [NSURL URLWithString:URLString];
//        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//        
//        NSString *dataString = [self URLEncodedString:[dataImage base64Encoding]];
//        [request setPostValue:@"3" forKey:@"type"];
//        [request setPostValue:dataString forKey:@"data"];
//        [request startSynchronous];
//        
//        //同步请求，直接取数据
//        NSData *data=[request responseData];
//        NSString *outString  = [[NSString alloc] initWithData:data encoding:  NSUTF8StringEncoding];
//        
//       
//        
//        
//    });
    
    return YES;
}

- (void)audio_PCMtoMP3
{
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"background-music-aac" ofType:@"caf"];

    NSString *mp3FilePath = DefaultCafPathMp3;
    NSString *cafFilePath = backgroundMusicPath;
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功: %@",mp3FilePath);
    }
    
}

- (NSString *)URLEncodedString:(NSString *)huohuo
{
    __autoreleasing NSString *encodedString;
    
    NSString *originalString = (NSString *)huohuo;
    encodedString = (__bridge_transfer NSString * )
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (__bridge CFStringRef)originalString,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
    return encodedString;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
