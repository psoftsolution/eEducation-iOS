//
//  SignalDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalRoomModel.h"
#import "SignalUserModel.h"
#import "MessageModel.h"
#import "SignalReplayModel.h"
#import "SignalShareScreenModel.h"
#import "SignalP2PModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SignalDelegate <NSObject>

@optional
- (void)didReceivedRoomInfoSignal:(SignalRoomInfoModel * _Nonnull)model;
- (void)didReceivedUserInfoSignal:(NSArray<UserModel *> * _Nonnull)model;
- (void)didReceivedMessage:(MessageInfoModel * _Nonnull)model;
- (void)didReceivedReplaySignal:(SignalReplayInfoModel * _Nonnull)model;
- (void)didReceivedShareScreenSignal:(SignalShareScreenInfoModel * _Nonnull)model;
- (void)didReceivedPeerSignal:(SignalP2PModel * _Nonnull)model;

- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state;

@end

NS_ASSUME_NONNULL_END
