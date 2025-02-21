//
//  ESPTouchResult.m
//  EspTouchDemo
//
//  Created by fby on 4/14/15.
//  Copyright (c) 2015 fby. All rights reserved.
//

#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"

@implementation ESPTouchResult

- (id) initWithIsSuc: (BOOL) isSuc andBssid: (NSString *) bssid andInetAddrData: (NSData *) ipAddrData
{
    self = [super init];
    if (self)
    {
        self.isSuc = isSuc;
        self.bssid = bssid;
        self.isCancelled = NO;
        self.ipAddrData = ipAddrData;
    }
    return self;
}

- (NSString *)getAddressString {
    NSString *ipAddrDataStr = [ESP_NetUtil descriptionInetAddr4ByData:self.ipAddrData];
    if (ipAddrDataStr==nil) {
        ipAddrDataStr = [ESP_NetUtil descriptionInetAddr6ByData:self.ipAddrData];
    }
    return ipAddrDataStr;
}

- (NSString *)description
{
    NSString *ipAddrDataStr = [self getAddressString];
    return [[NSString alloc]initWithFormat:@"[isSuc: %@,isCancelled: %@,bssid: %@,inetAddress: %@]",self.isSuc? @"YES":@"NO",
            self.isCancelled? @"YES":@"NO"
            ,self.bssid
            ,ipAddrDataStr];
}

@end