//
//  RoomMessageModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/6/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignalRoomModel : NSObject
@property (nonatomic, assign) BOOL isSelfSend;
@property (nonatomic, copy)   NSString *account;
@property (nonatomic, copy)   NSString *content;

@property (nonatomic, copy)   NSString *link;

@property (nonatomic, assign) CGFloat cellHeight;

@end

  

//@property (nonatomic, assign) NSInteger uid;
//@property (nonatomic, strong) NSString *resource;
//@property (nonatomic, assign) NSInteger value;

NS_ASSUME_NONNULL_END
