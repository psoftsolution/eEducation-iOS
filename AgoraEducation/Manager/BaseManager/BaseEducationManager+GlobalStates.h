//
//  BaseEducationManager+GlobalStates.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager.h"
#import "RoomAllModel.h"
#import "WhiteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseEducationManager (GlobalStates)

+ (void)getConfigWithSuccessBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;
+ (void)enterRoomWithUserName:(NSString *)userName password:(NSString *)password successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;

+ (void)leftRoomWithSuccessBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;

- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;
- (void)updateEnableVideoWithValue:(BOOL)enableVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;
- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;
- (void)updateUserInfoWithParams:(NSDictionary*)params completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;

- (void)getRoomInfoCompleteSuccessBlock:(void (^ _Nullable) (RoomInfoModel * roomInfoModel))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;
- (void)getWhiteInfoCompleteSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;

@end

NS_ASSUME_NONNULL_END
