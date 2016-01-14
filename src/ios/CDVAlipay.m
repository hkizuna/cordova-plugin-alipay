//
//  CDVAlipay.m
//
//  Created by xwang on 01/11/16.
//
//

#import "CDVAlipay.h"
#import <AlipaySDK/AlipaySDK.h>

@implementation CDVAlipay:CDVPlugin

- (void)pluginInitialize
{
	NSString *pid = [[self.commandDelegate settings] objectForKey:@"partnerid"];
	if (pid)
	{
		self.partnerId = pid;
	}
}

- (void)pay:(CDVInvokedUrlCommand *)command
{
	NSArray *arguments = [command arguments];
	self.currentCallbackId = command.callbackId;

	if ([arguments count] != 1)
	{
		[self failWithCallbackId:self.currentCallbackId withMessage:@"参数错误"];
		return;
	}

	[[AlipaySDK defaultService] payOrder:[arguments objectAtIndex:0] fromScheme:self.partnerId callback:^(NSDictionary *resultDic) {
	            if ([[resultDic objectForKey:@"resultStatus"] isEqual:@"9000"])
	            {
	            	[self successWithCallbackId:self.currentCallbackId withDictionary:resultDic];
	            }
	            else
	            {
	            	[self failWithCallbackId:self.currentCallbackId withDictionary:resultDic];
	            }
	            NSLog(@"reslut = %@", resultDic);
	        }];
}

- (void)handleOpenURL:(NSNotification *)notification
{
    NSURL *url = [notification object];
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:self.partnerId])
    {
    	[[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
    		    if ([[resultDic objectForKey:@"resultStatus"] isEqual:@"9000"])
    		    {
    		    	[self successWithCallbackId:self.currentCallbackId withDictionary:resultDic];
    		    }
    		    else
    		    {
    		    	[self failWithCallbackId:self.currentCallbackId withDictionary:resultDic];
    		    }
    		    NSLog(@"reslut = %@", resultDic);
    		}];
    }
}

- (void)successWithCallbackId:(NSString *)callbackId withDictionary:(NSDictionary *)message
{
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
												  messageAsDictionary:message];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)failWithCallbackId:(NSString *)callbackId withDictionary:(NSDictionary *)message
{
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
											      messageAsDictionary:message];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)failWithCallbackId:(NSString *)callbackId withMessage:(NSString *)message
{
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
											      	  messageAsString:message];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

@end