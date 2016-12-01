//
//  ServerHandler.h
//  Mealplan
//
//  Created by Mao on 7/3/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSURLRequest+OAuth.h"
#import "ServerResponseModel.h"
#import "YelpListModel.h"

@protocol ServerHandlerDelegate;

@interface ServerHandler : NSObject

@property (weak, nonatomic) id<ServerHandlerDelegate> m_oDelegate;

- (void)makeRequest:(NSString *)sURL postData:(NSString *)sPostData action:(NSString *)sAction;
- (void)uploadImage:(NSString *)sUrl postData:(NSData *)oPostData action:(NSString *)sAction;
- (void)queryBusinessInfoForBusinessId:(NSString *)sBusinessID action:(NSString *)sAction;
- (void)queryTopBusinessInfoForTerm:(NSString *)sTerm location:(NSString *)sLocation action:(NSString *)sAction offset:(int) iOffset;
+ (NSString *)getServerIp;

@end

@protocol ServerHandlerDelegate <NSObject>

@optional
- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction;
- (void)processServerResponseError:(NSError *)oError;
- (void)processJsonError:(NSError *)oError;
- (void)processYelpResponseModel:(NSData *)oResponseData action:(NSString *)sAction;

@end
