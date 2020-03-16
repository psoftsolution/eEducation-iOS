//
//  VCParamsModel.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCParamsModel : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *channelName;

@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *roomId;

@end

NS_ASSUME_NONNULL_END
