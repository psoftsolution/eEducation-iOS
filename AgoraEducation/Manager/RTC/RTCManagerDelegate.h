//
//  RTCManagerDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTCManagerDelegate <NSObject>

@optional
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason;
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type;
@end

NS_ASSUME_NONNULL_END
