//
//  CDVAlipay.h
//
//  Created by xwang on 01/11/16.
//
//

#import <Cordova/CDV.h>

@interface CDVAlipay:CDVPlugin

@property (nonatomic, strong) NSString *currentCallbackId;
@property (nonatomic, strong) NSString *partnerId;

- (void)pay:(CDVInvokedUrlCommand *)command;

@end