//
//  RoomMessageModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/6/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AERoomMessageModel : NSObject
@property (nonatomic, assign) BOOL isSelfSend;
@property (nonatomic, copy)   NSString *account;
@property (nonatomic, copy)   NSString *content;
@property (nonatomic, copy)   NSString *link;

@property (nonatomic, assign) CGFloat cellHeight;

//  for replay recording
@property (copy, nonatomic) NSString *roomid;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;
@property (copy, nonatomic) NSString *videoPath;

@end

NS_ASSUME_NONNULL_END
