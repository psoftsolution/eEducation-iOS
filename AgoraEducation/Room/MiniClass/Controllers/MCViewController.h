//
//  MCViewController.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MinEducationManager.h"
#import "VCParamsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCViewController : UIViewController

@property (nonatomic, strong) VCParamsModel *paramsModel;
@property (nonatomic, strong) MinEducationManager *educationManager;

@end

NS_ASSUME_NONNULL_END
