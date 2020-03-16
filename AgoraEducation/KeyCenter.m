//
//  KeyCenter.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "KeyCenter.h"

static NSString* agoraAppid = @"";
static NSString* agoraRTCToken = @"";
static NSString* agoraRTMToken = @"";
static NSString* whiteBoardId = @"";
static NSString* whiteBoardToken = @"";

@implementation KeyCenter

+ (void)setAgoraAppid:(NSString *)appid {
    agoraAppid = appid;
}

+ (NSString *)agoraAppid {
    return agoraAppid;
}


+ (void)setAgoraRTCToken:(NSString *)rtcToken {
    agoraRTCToken = rtcToken;
}

// assign token to nil if you have not enabled app certificate
+ (NSString *)agoraRTCToken {
    return agoraRTCToken;
}

+ (void)setAgoraRTMToken:(NSString *)rtmToken {
    agoraRTMToken = rtmToken;
}

// assign token to nil if you have not enabled app certificate
+ (NSString *)agoraRTMToken {
    return agoraRTMToken;
}

+ (void)setWhiteBoardId:(NSString *)whiteId {
    whiteBoardId = whiteId;
}

+ (NSString *)whiteBoardId {
    return whiteBoardId;
}

+ (void)setWhiteBoardToken:(NSString *)whiteToken {
    whiteBoardToken = whiteToken;
}

/* you can get white Token refer to https://console.herewhite.com/
*/
+ (NSString *)whiteBoardToken {
    return whiteBoardToken;
}

@end
