//
//  RoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomModel : NSObject
@property (nonatomic, copy)   NSString *channelName;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger muteAllChat;
@property (nonatomic, assign) NSInteger isRecording;
@property (nonatomic, copy)   NSString *whiteId;
@property (nonatomic, copy)   NSString *whiteToken;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, copy)   NSString *roomName;
@end

@interface UserModel : NSObject
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) NSInteger enableChat;
@property (nonatomic, assign) NSInteger enableVideo;
@property (nonatomic, assign) NSInteger enableAudio;
@property (nonatomic, copy)   NSArray *linkUsers;
@property (nonatomic, assign) NSInteger screenId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy)   NSString *userName;
@end

@interface RoomInfoModel : NSObject
@property (nonatomic, strong) RoomModel *room;
@property (nonatomic, copy)   NSArray<UserModel *> *users;
@end

@interface RoomAllModel : NSObject
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) RoomInfoModel *data;
@end

NS_ASSUME_NONNULL_END
