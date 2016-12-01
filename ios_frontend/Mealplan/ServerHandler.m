//
//  ServerHandler.m
//  Mealplan
//
//  Created by Mao on 7/3/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "ServerHandler.h"

#define SERVER_IP_ADDRESS @"173.255.118.8"
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchPath        = @"/v2/search/";
static int const kSearchLimit              = 10;

@implementation ServerHandler

@synthesize m_oDelegate;

- (void)makeRequest:(NSString *)sUrl postData:(NSString *)sPostData action:(NSString *)sAction {
    NSURL *oUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", SERVER_IP_ADDRESS, sUrl]];
    NSURLSessionConfiguration *oConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *oSession = [NSURLSession sessionWithConfiguration:oConfig];
    NSMutableURLRequest *oRequest = [[NSMutableURLRequest alloc] initWithURL:oUrl];
    
    if(sPostData != nil)
    {
        oRequest.HTTPMethod = @"POST";
        oRequest.HTTPBody = [sPostData dataUsingEncoding:NSUTF8StringEncoding];
    }

    NSURLSessionDataTask *oRequestTask =
    [oSession dataTaskWithRequest:oRequest completionHandler:^(NSData *oResponseData, NSURLResponse *oResponse, NSError *oError) {
        if (oError) {
            NSLog(@"connection error: %@", oError);
            if ([m_oDelegate respondsToSelector:@selector(processServerResponseError:)])
                [m_oDelegate processServerResponseError:oError];
            return;
        }
    
        NSHTTPURLResponse *oHttpResponse = (NSHTTPURLResponse*) oResponse;
        NSArray *oCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[oHttpResponse allHeaderFields] forURL:[oHttpResponse URL]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:oCookies forURL:[oHttpResponse URL] mainDocumentURL:nil];
    
        /*NSString* sData = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", sData);*/
        
        NSError *oJsonError;
        ServerResponseModel *oServerResponseModel = [[ServerResponseModel alloc] initWithData:oResponseData error:&oJsonError];
        
        if (oJsonError) {
            NSLog(@"json error: %@", oJsonError.localizedDescription);
            if ([m_oDelegate respondsToSelector:@selector(processJsonError:)])
                [m_oDelegate processJsonError:oError];
            return;
        }
        
        if([oServerResponseModel.m_sError isEqualToString:@"Session expired"])
        {
            NSLog(@"Session expired. Attempting to relog...");
            NSString *sSavedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"];
            NSString *sSavedPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
            NSString *sPostData = [NSString stringWithFormat:@"user_name=%@&password=%@", sSavedUsername, sSavedPassword];
            [self makeRequest:@"/user_action.php?action=Login" postData:sPostData action:@"Login"];
        }
        
        if ([m_oDelegate respondsToSelector:@selector(processServerResponseModel:action:)])
            [m_oDelegate processServerResponseModel:oServerResponseModel action:sAction];
    }];
    
    [oRequestTask resume];
    return;
}

+ (NSString *)getServerIp{
    return SERVER_IP_ADDRESS;
}

- (void)uploadImage:(NSString *)sUrl postData:(NSData *)oPostData action:(NSString *)sAction {
    if(oPostData == nil)
        return;
        
    NSMutableURLRequest *oRequest = [[NSMutableURLRequest alloc] init];
    [oRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", SERVER_IP_ADDRESS, sUrl]]];
    [oRequest setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [oRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedimage\"; filename=\"test.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:oPostData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [oRequest setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:oRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *oResponse, NSData *oResponseData, NSError *oError) {
        if (oError) {
            NSLog(@"connection error: %@", oError);
            if ([m_oDelegate respondsToSelector:@selector(processServerResponseError:)])
                [m_oDelegate processServerResponseError:oError];
            return;
        }
        
        NSHTTPURLResponse *oHttpResponse = (NSHTTPURLResponse*) oResponse;
        NSArray *oCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[oHttpResponse allHeaderFields] forURL:[oHttpResponse URL]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:oCookies forURL:[oHttpResponse URL] mainDocumentURL:nil];
        
        /*NSString* sData = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", sData);*/
        
        NSError *oJsonError;
        ServerResponseModel *oServerResponseModel = [[ServerResponseModel alloc] initWithData:oResponseData error:&oJsonError];
        
        if (oJsonError) {
            NSLog(@"json error: %@", oJsonError.localizedDescription);
            if ([m_oDelegate respondsToSelector:@selector(processJsonError:)])
                [m_oDelegate processJsonError:oError];
            return;
        }
        
        if ([m_oDelegate respondsToSelector:@selector(processServerResponseModel:action:)])
            [m_oDelegate processServerResponseModel:oServerResponseModel action:sAction];
    }];
    return;
}

#pragma mark Yelp Search methods

- (void)queryBusinessInfoForBusinessId:(NSString *)sBusinessID action:(NSString *)sAction {
    NSURLSession *oSession = [NSURLSession sharedSession];
    NSURLRequest *oBusinessInfoRequest = [self _businessInfoRequestForID:sBusinessID];
    [[oSession dataTaskWithRequest:oBusinessInfoRequest completionHandler:^(NSData *oResponseData, NSURLResponse *oResponse, NSError *oError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)oResponse;
        if (!oError && httpResponse.statusCode == 200) {
            if (oError) {
                NSLog(@"connection error: %@", oError);
                [m_oDelegate processServerResponseError:oError];
                return;
            }
            
            if ([m_oDelegate respondsToSelector:@selector(processYelpResponseModel:action:)])
                [m_oDelegate processYelpResponseModel:oResponseData action:sAction];
            
        }
    }] resume];
    
}

- (void)queryTopBusinessInfoForTerm:(NSString *)sTerm location:(NSString *)sLocation action:(NSString *)sAction offset:(int) iOffset{
    NSURLSession *oSession = [NSURLSession sharedSession];
    NSURLRequest *oSearchRequest = [self _searchRequestWithTerm:sTerm location:sLocation offset:iOffset];
    [[oSession dataTaskWithRequest:oSearchRequest completionHandler:^(NSData *oResponseData, NSURLResponse *oResponse, NSError *oError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)oResponse;
        if (!oError && httpResponse.statusCode == 200) {
            if (oError) {
                NSLog(@"connection error: %@", oError);
                [m_oDelegate processServerResponseError:oError];
                return;
            }
            
            if ([m_oDelegate respondsToSelector:@selector(processYelpResponseModel:action:)])
                [m_oDelegate processYelpResponseModel:oResponseData action:sAction];
        }
    }] resume];
}

- (NSURLRequest *)_businessInfoRequestForID:(NSString *)sBusinessID {
    
    NSString *businessPath = [NSString stringWithFormat:@"%@%@", kBusinessPath, sBusinessID];
    return [NSURLRequest requestWithHost:kAPIHost path:businessPath];
}

- (NSURLRequest *)_searchRequestWithTerm:(NSString *)sTerm location:(NSString *)sLocation offset:(int) iOffset{
    NSDictionary *params = @{
                             @"term": sTerm,
                             @"location": sLocation,
                             @"limit": [NSString stringWithFormat:@"%d", kSearchLimit],
                             @"offset": [NSString stringWithFormat:@"%d", iOffset*kSearchLimit]
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}
@end
