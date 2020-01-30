//
//  BaseEducationManager+GlobalStates.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "BaseEducationManager+GlobalStates.h"
#import "HttpManager.h"
#import "ConfigModel.h"
#import "EnterRoomAllModel.h"
#import "CommonModel.h"

static char kAssociatedConfig;

@implementation BaseEducationManager (GlobalStates)

- (void)getConfigWithSuccessBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [HttpManager get:HTTP_GET_CONFIG params:nil headers:nil success:^(id responseObj) {
        
        ConfigModel *model = [ConfigModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            
            weakself.eduConfigModel.appId = model.data.appId;
            weakself.eduConfigModel.oneToOneStudentLimit = model.data.oneToOneStudentLimit.integerValue;
            weakself.eduConfigModel.smallClassStudentLimit = model.data.smallClassStudentLimit.integerValue;
            weakself.eduConfigModel.largeClassStudentLimit = model.data.largeClassStudentLimit.integerValue;
            
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                if(model.msg != nil) {
                    failBlock(model.msg);
                } else {
                    failBlock(@"get config failed");
                }
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil){
            failBlock(@"get config request failed");
        }
        NSLog(@"HTTP get config error:%@", error.description);
    }];
}

- (void)enterRoomWithUserName:(NSString *)userName roomName:(NSString *)roomName sceneType:(SceneType)sceneType successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_POST_ENTER_ROOM, self.eduConfigModel.appId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userName"] = userName;
    params[@"roomName"] = roomName;
    params[@"type"] = @(sceneType);
    // student
    params[@"role"] = @(2);
    
    WEAK(self);
    [HttpManager post:url params:params headers:nil success:^(id responseObj) {
        
        EnterRoomAllModel *model = [EnterRoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            
            weakself.eduConfigModel.uid = model.data.user.uid;
            weakself.eduConfigModel.userToken = model.data.user.userToken;
            weakself.eduConfigModel.roomId = model.data.room.roomId;
            weakself.eduConfigModel.channelName = model.data.room.channelName;
            
            weakself.eduConfigModel.rtcToken = model.data.user.rtcToken;
            weakself.eduConfigModel.rtmToken = model.data.user.rtmToken;
            weakself.eduConfigModel.boardId = model.data.room.boardId;
            weakself.eduConfigModel.boardToken = model.data.room.boardToken;
            
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                if(model.msg != nil) {
                    failBlock(model.msg);
                } else {
                    failBlock(@"enter room failed");
                }
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil){
            failBlock(@"enter room request failed");
        }
        NSLog(@"HTTP enter room error:%@", error.description);
    }];
}

- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *userParams = [NSMutableDictionary dictionary];
    userParams[@"userId"] = @(self.eduConfigModel.uid);
    userParams[@"enableChat"] = @(enableChat ? 1 : 0);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"users"] = @[userParams];
    
    [self updateRoomInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)updateEnableVideoWithValue:(BOOL)enableVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *userParams = [NSMutableDictionary dictionary];
    userParams[@"userId"] = @(self.eduConfigModel.uid);
    userParams[@"enableVideo"] = @(enableVideo ? 1 : 0);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"users"] = @[userParams];
    
    [self updateRoomInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *userParams = [NSMutableDictionary dictionary];
    userParams[@"userId"] = @(self.eduConfigModel.uid);
    userParams[@"enableAudio"] = @(enableAudio ? 1 : 0);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"users"] = @[userParams];
    [self updateRoomInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)getRoomInfoCompleteSuccessBlock:(void (^ _Nullable) (RoomInfoModel * roomInfoModel))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
 
    NSString *url = [NSString stringWithFormat:HTTP_GET_ROOM_INFO, self.eduConfigModel.appId, @(self.eduConfigModel.roomId)];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = self.eduConfigModel.userToken;
    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        RoomAllModel *model = [RoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            if(successBlock != nil){
                successBlock(model.data);
            }
        } else {
            if(failBlock != nil){
                if(model.msg != nil) {
                    failBlock(model.msg);
                } else {
                    failBlock(@"get room info failed");
                }
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil){
            failBlock(@"get room info request failed");
        }
        NSLog(@"HTTP get room info error:%@", error.description);
    }];
}

- (void)updateRoomInfoWithParams:(NSDictionary*)params completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_GET_ROOM_INFO, self.eduConfigModel.appId, @(self.eduConfigModel.roomId)];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = self.eduConfigModel.userToken;
    
    [HttpManager post:url params:params headers:headers success:^(id responseObj) {
        
        CommonModel *model = [CommonModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                if(model.msg != nil) {
                    failBlock(model.msg);
                } else {
                    failBlock(@"update room failed");
                }
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil){
            failBlock(@"update room request failed");
        }
        NSLog(@"HTTP update room error:%@", error.description);
    }];
}

- (void)setEduConfigModel:(EduConfigModel *)eduConfigModel {
    objc_setAssociatedObject(self, &kAssociatedConfig, eduConfigModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EduConfigModel *)eduConfigModel {
    EduConfigModel *model = objc_getAssociatedObject(self, &kAssociatedConfig);
    if(model == nil) {
        model = [EduConfigModel new];
        [self setEduConfigModel:model];
    }
    return model;
}

@end
