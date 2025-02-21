//
//  Smartconfig.m
//  Smartconfig
//
//  Created by Tuan PM on 1/30/16.
//  Copyright © 2016 Tuan PM. All rights reserved.
//

#import "Smartconfig.h"


@interface EspTouchDelegateImpl1 : NSObject<ESPTouchDelegate>

@end


@implementation EspTouchDelegateImpl1
-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl1 onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self showAlertWithResult:result];
    });
}

@end


@interface Smartconfig : NSObject<RCTBridgeModule>


@property (nonatomic, strong) NSDictionary *defaultOptions;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, strong) EspTouchDelegateImpl1 *_esptouchDelegate;
@property (nonatomic, strong) NSCondition *_condition;

@property (atomic, strong) ESPTouchTask *_esptouchTask;
@end



@implementation Smartconfig
{
    
    
}

RCT_EXPORT_MODULE();

- (instancetype)init
{
    if (self = [super init]) {
        self.defaultOptions = @{
                                @"type": @"esptouch",
                                @"ssid": @"ssid",
                                @"password": @"password",
                                @"hidden": @NO,
                                @"bssid": @"",
                                @"timeout": @150000,
                                @"taskCount": @1
                                };
        self._esptouchDelegate = [[EspTouchDelegateImpl1 alloc]init];
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_METHOD(stop) {
    [self cancel];
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    self.options = [NSMutableDictionary dictionaryWithDictionary:self.defaultOptions]; // Set default options
    for (NSString *key in options.keyEnumerator) { // Replace default options
        [self.options setValue:options[key] forKey:key];
    }
    
    
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSArray *esptouchResultArray = [self executeForResults];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL resolved = false;
            NSMutableArray *ret = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [esptouchResultArray count]; ++i)
            {
                ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                
                if (![resultInArray isCancelled] && [resultInArray bssid] != nil) {
                    
                    unsigned char *ipBytes = (unsigned char *)[[resultInArray ipAddrData] bytes];
                    
                    NSString *ipv4String = [NSString stringWithFormat:@"%d.%d.%d.%d", ipBytes[0], ipBytes[1], ipBytes [2], ipBytes [3]];
                    
                    NSDictionary *respData = @{@"bssid": [resultInArray bssid], @"ipv4": ipv4String};
                    
                    [ret addObject: respData];
                    resolved = true;
                    if (![resultInArray isSuc])
                    break;
                }
                
                
            }
            if(resolved)
            resolve(ret);
            else
            reject(RCTErrorUnspecified, nil, RCTErrorWithMessage(@"Timeoutout or not Found"));
            
            
        });
        
    });
    
    
}

- (void) cancel
{
    RCTLogInfo(@"Cancel last task before begin new task");
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}


#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResults
{
    [self cancel];
    [self._condition lock];
    NSString *ssid = [self.options valueForKey:@"ssid"];
    NSString *password = [self.options valueForKey:@"password"];
    NSString *bssid = [self.options valueForKey:@"bssid"];
    int timeoutMillisecond = [[self.options valueForKey:@"timeout"] intValue];
    int taskCount = [[self.options valueForKey:@"taskCount"] intValue];
    BOOL hidden = [self.options valueForKey:@"hidden"];
    // Decode the SSID, BSSID and PASSWORD from B64 to NSString

    RCTLogInfo(@"executeForResults");
    RCTLogInfo(@"ssid %@ pass %@ bssid %@ timeout %d", ssid, password, bssid,timeoutMillisecond);
    self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:ssid andApBssid:bssid andApPwd:password andIsSsidHiden:hidden andTimeoutMillisecond:timeoutMillisecond];
    
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    // Potential fix for ios14.6 and xcode12.5
    [self._esptouchTask setPackageBroadcast:true];
    
    [self._condition unlock];
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    
    return esptouchResults;
}

@end

