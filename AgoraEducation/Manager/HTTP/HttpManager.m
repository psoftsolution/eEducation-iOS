//
//  CYXHttpRequest.m
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import "HttpManager.h"
#import <AFNetworking/AFNetworking.h>
#import "KeyCenter.h"

@interface HttpManager ()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

static HttpManager *manager = nil;

@implementation HttpManager
+ (instancetype)shareManager{
    @synchronized(self){
        if (!manager) {
            manager = [[self alloc]init];
            [manager initSessionManager];
        }
        return manager;
    }
}

- (void)initSessionManager {
    self.sessionManager = [AFHTTPSessionManager manager];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = 30;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure {

    [manager.sessionManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];

}

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {

    [manager.sessionManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
                   success(responseObject);
               }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
          failure(error);
        }
    }];
}

+ (void)POSTWhiteBoardRoomWithUuid:(NSString *)uuid token:(void (^)(NSString *token))token failure:(void (^)(NSString *msg))failure{
    
    NSString *urlString = @"https://cloudcapiv4.herewhite.com/room/join";
    NSString *url = [NSString stringWithFormat:@"%@?uuid=%@&token=%@",urlString, uuid, [KeyCenter whiteBoardToken]];
    [HttpManager post:url params:nil success:^(id responseObj) {
        if ([responseObj[@"code"] integerValue] == 200) {
            if (token) {
                token(responseObj[@"msg"][@"roomToken"]);
            }
        }else {
            if (failure) {
                failure(@"Get roomToken error");
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(@"Get roomToken error");
        }
    }];
}
@end
