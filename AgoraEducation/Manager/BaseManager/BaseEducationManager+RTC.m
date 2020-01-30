//
//  BaseEducationManager+RTC1.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+RTC.h"

@implementation BaseEducationManager (RTC)

- (void)initRTCEngineKitWithAppid:(NSString *)appid clientRole:(RTCClientRole)role dataSourceDelegate:(id<RTCDelegate> _Nullable)rtcDelegate {
    
    self.rtcDelegate = rtcDelegate;

    self.rtcManager = [[RTCManager alloc] init];
    self.rtcManager.rtcManagerDelegate = self;
    [self.rtcManager initEngineKit:appid];
    [self.rtcManager setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcManager enableVideo];
    [self.rtcManager startPreview];
    [self.rtcManager enableWebSdkInteroperability:YES];
    [self.rtcManager enableDualStreamMode:YES];
    [self setRTCClientRole: role];
}

- (int)joinRTCChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock {
    
    return [self.rtcManager joinChannelByToken:token channelId:channelId info:info uid:uid joinSuccess:joinSuccessBlock];
}

- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *)model completeBlock:(void(^ _Nullable)(AgoraRtcVideoCanvas *videoCanvas))block {
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = model.uid;
    videoCanvas.view = model.videoView;
    
    if(model.renderMode == RTCVideoRenderModeFit) {
        videoCanvas.renderMode = AgoraVideoRenderModeFit;
    } else if(model.renderMode == RTCVideoRenderModeHidden){
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    }

    if(model.canvasType == RTCVideoCanvasTypeLocal) {
        [self.rtcManager setupLocalVideo: videoCanvas];
    } else if(model.canvasType == RTCVideoCanvasTypeRemote) {
        [self.rtcManager setupRemoteVideo: videoCanvas];
    }
    
    if(block != nil){
        block(videoCanvas);
    }
}

- (void)removeRTCVideoCanvas:(NSUInteger) uid {
    NSAssert(1 == 0, @"Subclass Overwrite");
}

- (void)setRTCClientRole:(RTCClientRole)role {
    if(role == RTCClientRoleAudience){
        [self.rtcManager setClientRole:(AgoraClientRoleAudience)];
    } else if(role == RTCClientRoleBroadcaster){
        [self.rtcManager setClientRole:(AgoraClientRoleBroadcaster)];
    }
}

- (int)enableRTCLocalVideo:(BOOL) enabled {
    return [self.rtcManager muteLocalVideoStream:!enabled];
}
- (int)enableRTCLocalAudio:(BOOL) enabled {
    return [self.rtcManager muteLocalAudioStream:!enabled];
}

- (void)releaseRTCResources {
    [self.rtcManager releaseResources];
}

#pragma mark RTCManagerDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    
    if([self.rtcDelegate respondsToSelector:@selector(rtcDidJoinedOfUid:)]) {
        [self.rtcDelegate rtcDidJoinedOfUid:uid];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    
    [self removeRTCVideoCanvas:uid];
    
    if([self.rtcDelegate respondsToSelector:@selector(rtcDidOfflineOfUid:)]) {
        [self.rtcDelegate rtcDidOfflineOfUid:uid];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type {
    
    RTCNetworkGrade grade = RTCNetworkGradeUnknown;
    
    switch (type) {
        case AgoraNetworkTypeUnknown:
        case AgoraNetworkTypeMobile4G:
        case AgoraNetworkTypeWIFI:
            grade = RTCNetworkGradeHigh;
            break;
        case AgoraNetworkTypeMobile3G:
        case AgoraNetworkTypeMobile2G:
            grade = RTCNetworkGradeMiddle;
            break;
        case AgoraNetworkTypeLAN:
        case AgoraNetworkTypeDisconnected:
            grade = RTCNetworkGradeLow;
            break;
        default:
            break;
    }
    
    if([self.rtcDelegate respondsToSelector:@selector(rtcNetworkTypeGrade:)]) {
        [self.rtcDelegate rtcNetworkTypeGrade:grade];
    }
}

@end
