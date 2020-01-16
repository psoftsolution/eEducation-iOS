//
//  OneToOneReplayViewController.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "OneToOneReplayViewController.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"
#import "ReplayControlView.h"
#import "LoadingView.h"

#import "HttpManager.h"

@interface OneToOneReplayViewController ()

@property (weak, nonatomic) IBOutlet ReplayControlView *controlView;
@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet LoadingView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet OTOTeacherView *teacherView;
@property (weak, nonatomic) IBOutlet OTOStudentView *studentView;

@end

@implementation OneToOneReplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self setupView];
//    [self initData];
//    [self addNotification];
}

#pragma mark Click Event
- (IBAction)onWhiteBoardClick:(id)sender {
    self.controlView.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (IBAction)onPlayClick:(id)sender {
    
}


@end
