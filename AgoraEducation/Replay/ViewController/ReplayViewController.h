//
//  ReplayNoVideoViewController.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/17.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReplayViewController : UIViewController

@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *roomId;
@property (strong, nonatomic) NSString *recordId;
@property (strong, nonatomic) NSString *userToken;

@end

NS_ASSUME_NONNULL_END

