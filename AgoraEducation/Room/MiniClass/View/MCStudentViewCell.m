//
//  MCStudentViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MCStudentViewCell.h"


@interface MCStudentViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@end

@implementation MCStudentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization cod
    self.muteVideoButton.selected = YES;
    self.muteAudioButton.selected = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)muteAction:(UIButton *)sender {
    
}

- (void)setStudentModel:(AEStudentModel *)studentModel {
    _studentModel = studentModel;
    [self.nameLabel setText:studentModel.account];
    NSString *audioImageName = studentModel.audio ? @"icon-speaker3-max" : @"icon-speakeroff-dark";
    [self.muteAudioButton setImage:[UIImage imageNamed:audioImageName] forState:(UIControlStateNormal)];
    self.muteAudioButton.selected = studentModel.audio ? YES : NO;

    NSString *videoImageName = studentModel.video ? @"roomCameraOn" : @"roomCameraOff";
    [self.muteVideoButton setImage:[UIImage imageNamed:videoImageName] forState:(UIControlStateNormal)];
    self.muteVideoButton.selected = studentModel.video ? YES : NO;
    self.muteVideoButton.hidden = studentModel.uid != self.userId ? YES : NO;
    self.muteAudioButton.hidden = studentModel.uid != self.userId ? YES : NO;
}


@end
