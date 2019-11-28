//
//  OTOStudentView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface OTOStudentView : UIView
@property (nonatomic, weak) id <AEClassRoomProtocol> delegate;
@property (weak, nonatomic) IBOutlet UIView *videoRenderView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;

- (void)updateUserName:(NSString *)name;
- (void)updateCameraImageWithLocalVideoMute:(BOOL)mute;
- (void)updateMicImageWithLocalVideoMute:(BOOL)mute;
@end

NS_ASSUME_NONNULL_END
