//
//  SignalP2PModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SignalP2PType) {
    SignalP2PTypeHand          = 1,
};

typedef NS_ENUM(NSInteger, SignalP2PCmdType) {
    SignalP2PCmdTypeApply          = 105,
    SignalP2PCmdTypeReject         = 107,
};

NS_ASSUME_NONNULL_BEGIN

@interface SignalP2PModel : NSObject
@property (nonatomic, assign) SignalP2PCmdType cmd;
@property (nonatomic, copy) NSString *text;
@end

NS_ASSUME_NONNULL_END
