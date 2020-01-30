//
//  ConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/6.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigInfoModel : NSObject

@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* appId;

@property (nonatomic, strong) NSString* oneToOneTeacherLimit;
@property (nonatomic, strong) NSString* smallClassTeacherLimit;
@property (nonatomic, strong) NSString* largeClassTeacherLimit;

@property (nonatomic, strong) NSString* oneToOneStudentLimit;
@property (nonatomic, strong) NSString* smallClassStudentLimit;
@property (nonatomic, strong) NSString* largeClassStudentLimit;

@end


@interface ConfigModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString* msg;
@property (nonatomic, strong) ConfigInfoModel* data;

@end

NS_ASSUME_NONNULL_END
