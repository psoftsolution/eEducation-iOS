//
//  EducationManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhiteManager.h"

#import "SignalManager.h"
#import "RTCVideoCanvasModel.h"
#import "ReplayerModel.h"
#import "AEP2pMessageModel.h"

@protocol WhitePlayDelegate <NSObject>

@optional

/** 进度时间变化 */
- (void)whitePlayerTimeChanged:(NSTimeInterval)time;

/**
 进入缓冲状态，WhitePlayer，NativePlayer 任一进入缓冲，都会回调。
 */
- (void)whitePlayerStartBuffering;

/**
 结束缓冲状态，WhitePlayer，NativePlayer 全部完成缓冲，才会回调。
 */
- (void)whitePlayerEndBuffering;

/**
 播放结束
 */
- (void)whitePlayerDidFinish;

/**
 播放失败

 @param error 错误原因
 */
- (void)whitePlayerError:(NSError * _Nullable)error;

/**
 房间中RoomState属性，发生变化时，会触发该回调。
 @param modifyState 发生变化的 RoomState 内容
 */
- (void)whiteRoomStateChanged;

@end

@protocol RTCDelegate <NSObject>
@optional
- (void)rtcDidJoinedOfUid:(NSUInteger)uid;
- (void)rtcDidOfflineOfUid:(NSUInteger)uid;
- (void)rtcNetworkTypeGrade:(RTCNetworkGrade)grade;
@end

#define NOTICE_KEY_ON_MESSAGE_DISCONNECT @"NOTICE_KEY_ON_MESSAGE_DISCONNECT"
@protocol SignalDelegate <NSObject>
@optional
- (void)signalDidUpdateMessage:(AERoomMessageModel * _Nonnull)messageModel;
- (void)signalDidUpdateGlobalState:(RolesInfoModel * _Nullable)infoModel;
- (void)signalDidReceived:(AEP2pMessageModel * _Nonnull)signalModel;
@end

NS_ASSUME_NONNULL_BEGIN

@interface EducationManager : NSObject

/* ==================================>SignalManager<================================ */
@property (nonatomic, strong) AETeactherModel * _Nullable currentTeaModel;
@property (nonatomic, strong) AEStudentModel * _Nullable currentStuModel;
- (void)initSignalWithModel:(MessageModel*)model dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;
- (void)initStudentWithUserName:(NSString *)userName;
- (void)setSignalDelegate:(id<SignalDelegate>)delegate;
- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;

- (void)queryGlobalStateWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block;
- (void)updateGlobalStateWithValue:(NSString *)value completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;
- (void)queryOnlineStudentCountWithChannelName:(NSString *)channelName maxCount:(NSInteger)maxCount completeSuccessBlock:(void (^) (NSInteger count))successBlock completeFailBlock:(void (^) (void))failBlock;

- (void)sendMessageWithContent:(NSString *)text userName:(NSString *)name;
- (void)setSignalWithType:(RTMp2pType)type completeSuccessBlock:(void (^ _Nullable) (void))successBlock;

- (void)releaseSignalResources;


/* ==================================>RTCManager<================================ */
- (void)initRTCEngineKitWithAppid:(NSString *)appid clientRole:(RTCClientRole)role dataSourceDelegate:(id<RTCDelegate> _Nullable)rtcDelegate;
- (int)joinRTCChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;
- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *) model;
- (void)removeRTCVideoCanvas:(NSUInteger) uid;
- (void)setRTCClientRole:(RTCClientRole)role;
- (int)setRTCRemoteStreamWithUid:(NSUInteger)uid type:(RTCVideoStreamType)streamType;
- (int)enableRTCLocalVideo:(BOOL) enabled;
- (int)enableRTCLocalAudio:(BOOL) enabled;
- (void)releaseRTCResources;


/* ==================================>WhiteManager<================================ */
- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate;
- (void)joinWhiteRoomWithUuid:(NSString*)uuid completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
- (void)createWhiteReplayerWithModel:(ReplayerModel *)model completeSuccessBlock:(void (^) (WhitePlayer * _Nullable whitePlayer, AVPlayer * _Nullable avPlayer))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
- (void)disableWhiteDeviceInputs:(BOOL)disable;
- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor;
- (void)setWhiteApplianceName:(NSString *)applianceName;
- (void)refreshWhiteViewSize;
- (void)moveWhiteToContainer:(NSInteger)sceneIndex;
- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
- (void)seekWhiteToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;
- (void)playWhite;
- (void)pauseWhite;
- (void)stopWhite;
- (NSTimeInterval)whiteTotleTimeDuration;
- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock;
- (void)releaseWhiteResources;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
