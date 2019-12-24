//
//  RTCManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

#define NOTICE_NETWORK_TYPE_CHANGED @"NOTICE_NETWORK_TYPE_CHANGED"

@protocol RTCManagerDelegate <NSObject>

@optional
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason;
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type;
@end


NS_ASSUME_NONNULL_BEGIN

@interface RTCManager : NSObject

@property (nonatomic, strong) AgoraRtcEngineKit *rtcEngineKit;

@property (nonatomic, weak) id<RTCManagerDelegate> rtcManagerDelegate;

- (void)initEngineKit:(NSString *)appid;

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;

- (void)setChannelProfile:(AgoraChannelProfile)channelProfile;
- (void)setClientRole:(AgoraClientRole)clientRole;
- (void)enableVideo;
- (void)startPreview;
- (void)enableWebSdkInteroperability:(BOOL) enabled;
- (void)enableDualStreamMode:(BOOL) enabled;
- (int)enableLocalVideo:(BOOL) enabled;
- (int)enableLocalAudio:(BOOL) enabled;
- (int)muteLocalVideoStream:(BOOL)enabled;
- (int)muteLocalAudioStream:(BOOL)enabled;
- (int)setRemoteVideoStream:(NSUInteger)uid type:(AgoraVideoStreamType)streamType;
- (int)stopPreview;

- (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local;
- (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote;

- (void)releaseResources;
@end

NS_ASSUME_NONNULL_END
