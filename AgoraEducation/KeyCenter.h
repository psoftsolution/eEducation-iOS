//
//  KeyCenter.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyCenter : NSObject

+ (void)setAgoraAppid:(NSString *)appid;
+ (NSString *)agoraAppid;

/* assign Token to nil if you have not enabled app certificate
 * before you deploy your own token server, you can easily generate a temp token for dev use
 * at https://dashboard.agora.io note the token generated are allowed to join corresponding room ONLY.
 */
+ (void)setAgoraRTCToken:(NSString *)rtcToken;
+ (NSString *)agoraRTCToken;


/* you can get Agora RTMToken refer to https://docs.agora.io/cn/Real-time-Messaging/rtm_token
 */
+ (void)setAgoraRTMToken:(NSString *)rtmToken;
+ (NSString *)agoraRTMToken;


/* you can get white Token refer to https://console.herewhite.com/
 */
+ (void)setWhiteBoardId:(NSString *)whiteId;
+ (NSString *)whiteBoardId;

+ (void)setWhiteBoardToken:(NSString *)whiteToken;
+ (NSString *)whiteBoardToken;

@end

NS_ASSUME_NONNULL_END
