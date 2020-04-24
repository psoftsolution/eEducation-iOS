//
//  SignalEnum.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

typedef NS_ENUM(NSInteger, MessageCmdType) {
    MessageCmdTypeChat                  = 1,
    MessageCmdTypeUserOnline            = 2,
    MessageCmdTypeRoomInfo              = 3,
    MessageCmdTypeUserInfo              = 4,
    MessageCmdTypeReplay                = 5,
    MessageCmdTypeShareScreen           = 6,
};

typedef NS_ENUM(NSInteger, SignalType) {
    SignalValueCancelCoVideo = 108,  // 下麦
    SignalValueAcceptCoVideo = 106,  // 上麦
    SignalValueMuteAudio = 101,   // 禁音频
    SignalValueUnmuteAudio = 102, // 解禁音频
    SignalValueMuteVideo = 103,   // 禁视频
    SignalValueUnmuteVideo = 104, // 解禁视频
    SignalValueMuteChat = 109,    // 禁聊天
    SignalValueUnmuteChat = 110,  // 解禁聊天
    SignalValueMuteBoard = 200,   // 禁白板
    SignalValueUnmuteBoard = 201, // 解禁白板
    SignalValueLockBoard = 301,   // 锁定白板
    SignalValueUnlockBoard = 302, // 解锁白板
    SignalValueStartCourse = 401, // 开始上课
    SignalValueEndCourse = 402, //结束上课
    SignalValueMuteAllChat = 501, //全员禁言
    SignalValueUnmuteAllChat = 502, //全员解除禁言
};

// covideo state
typedef NS_ENUM(NSInteger, SignalLinkState) {
    SignalLinkStateIdle             = 0,
    SignalLinkStateApply            = 1,
    SignalLinkStateTeaReject           = 2,
    SignalLinkStateStuCancel        = 3, // Cancel Apply
    SignalLinkStateTeaAccept        = 4, // linked
    SignalLinkStateStuClose         = 5, // student close link
    SignalLinkStateTeaClose         = 6, // teacher close link
};
