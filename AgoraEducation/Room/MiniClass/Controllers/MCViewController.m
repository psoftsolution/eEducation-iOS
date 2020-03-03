//
//  MCViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCViewController.h"
#import "EENavigationView.h"
#import "MCStudentVideoListView.h"
#import "MCTeacherVideoView.h"
#import "EEWhiteboardTool.h"
#import "EEColorShowView.h"
#import "EEPageControlView.h"
#import "EEChatTextFiled.h"
#import "EEMessageView.h"
#import "MCStudentListView.h"
#import "MCSegmentedView.h"
#import <Whiteboard/Whiteboard.h>
#import "MCStudentVideoCell.h"
#import "UIView+Toast.h"

#define kLandscapeViewWidth    222
@interface MCViewController ()<UITextFieldDelegate,RoomProtocol, SignalDelegate, RTCDelegate, EEPageControlDelegate, EEWhiteboardToolDelegate, WhitePlayDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoManagerViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet MCStudentVideoListView *studentVideoListView;
@property (weak, nonatomic) IBOutlet MCTeacherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIView *roomManagerView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;
@property (weak, nonatomic) IBOutlet MCStudentListView *studentListView;
@property (weak, nonatomic) IBOutlet MCSegmentedView *segmentedView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

// white
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, assign) NSInteger sceneCount;

@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;

@end

@implementation MCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
}

- (void)initData {
    
    self.pageControlView.delegate = self;
    self.whiteboardTool.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    self.studentListView.delegate = self;
    self.navigationView.delegate = self;
    
    [self initSelectSegmentBlock];
    [self initStudentRenderBlock];
    
    WEAK(self);
    [self.colorShowView setSelectColor:^(NSString * _Nullable colorString) {
        NSArray *colorArray = [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        [weakself.educationManager setWhiteStrokeColor:colorArray];
    }];
    
    EduConfigModel *model = self.educationManager.eduConfigModel;
    
    [self.navigationView updateClassName:model.className];
    self.studentListView.uid = model.uid;

    // api -> init rtm -> rtc & white
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {

        [weakself setupSignalWithSuccessBolck:^{
            [weakself setupRTC];
            [weakself setupWhiteBoard];
            
            [weakself updateTimeState];
            [weakself updateChatViews];
            [weakself checkNeedRender];
        }];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself showToast:errMessage];
    }];
}

- (void)setupRTC {
    
    EduConfigModel *configModel = self.educationManager.eduConfigModel;
    
    [self.educationManager initRTCEngineKitWithAppid:configModel.appId clientRole:RTCClientRoleBroadcaster dataSourceDelegate:self];
    
    WEAK(self);
    [self.educationManager joinRTCChannelByToken:configModel.rtcToken channelId:configModel.channelName info:nil uid:configModel.uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [weakself.educationManager.rtcUids addObject:uidStr];
        [weakself checkNeedRender];
    }];
}

- (void)setupSignalWithSuccessBolck:(void (^)(void))successBlock {

    NSString *appid = self.educationManager.eduConfigModel.appId;
    NSString *appToken = self.educationManager.eduConfigModel.rtmToken;
    NSString *uid = @(self.educationManager.eduConfigModel.uid).stringValue;
    
    WEAK(self);
    [self.educationManager initSignalWithAppid:appid appToken:appToken userId:uid dataSourceDelegate:self completeSuccessBlock:^{
        
        NSString *channelName = weakself.educationManager.eduConfigModel.channelName;
        [weakself.educationManager joinSignalWithChannelName:channelName completeSuccessBlock:^{
            if(successBlock != nil){
                successBlock();
            }
            
        } completeFailBlock:^{
            
        }];
        
    } completeFailBlock:^{
        
    }];
}

- (void)setupWhiteBoard {
    
    [self.educationManager initWhiteSDK:self.boardView dataSourceDelegate:self];
    
    RoomModel *roomModel = self.educationManager.roomModel;
    WEAK(self);
    [self.educationManager joinWhiteRoomWithBoardId:roomModel.boardId boardToken:roomModel.boardToken completeSuccessBlock:^(WhiteRoom * _Nullable room) {
        
        CMTime cmTime = CMTimeMakeWithSeconds(0, 100);
        [weakself.educationManager seekWhiteToTime:cmTime completionHandler:^(BOOL finished) {
        }];

        [weakself.educationManager disableWhiteDeviceInputs:NO];
        [weakself.educationManager disableCameraTransform:roomModel.lockBoard];

        [weakself.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
            weakself.sceneCount = sceneCount;
            weakself.sceneIndex = sceneIndex;
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
            [weakself.educationManager moveWhiteToContainer:sceneIndex];
        }];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        [weakself showToast:NSLocalizedString(@"JoinWhiteErrorText", nil)];
    }];
}

- (void)updateTeacherViews:(UserModel*)teacherModel {
    if(teacherModel == nil){
        return;
    }
    
    // update teacher views
    self.teacherVideoView.defaultImageView.hidden = teacherModel.enableVideo ? YES : NO;
    NSString *imageName = teacherModel.enableAudio ? @"icon-speaker3-max" : @"icon-speakeroff-dark";
    [self.teacherVideoView updateSpeakerImageName: imageName];
    [self.teacherVideoView updateUserName:teacherModel.userName];
}

- (void)updateTimeState {
    RoomModel *roomModel = self.educationManager.roomModel;
    if(roomModel.courseState == ClassStateInClass) {
        NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval currenTimeInterval = [currentDate timeIntervalSince1970];
        [self.navigationView initTimerCount:(NSInteger)currenTimeInterval - roomModel.startTime];
        [self.navigationView startTimer];
    } else {
        [self.navigationView stopTimer];
    }
}

- (void)updateChatViews {
    
    RoomModel *roomModel = self.educationManager.roomModel;
    BOOL muteChat = roomModel != nil ? roomModel.muteAllChat : NO;
    if(!muteChat) {
        UserModel *studentModel = self.educationManager.studentModel;
        muteChat = studentModel.enableChat == 0 ? YES : NO;
    }
    self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
    self.chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
}

- (void)updateStudentViews:(UserModel*)studentModel {
    if(studentModel == nil){
        return;
    }
    
    [self.educationManager muteRTCLocalVideo:studentModel.enableVideo == 0 ? YES : NO];
    [self.educationManager muteRTCLocalAudio:studentModel.enableAudio == 0 ? YES : NO];
}

- (void)showToast:(NSString *)title {
    [self.view makeToast:title];
}

- (void)setupView {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
        
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardBaseView addSubview:boardView];
    self.boardView = boardView;
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
    
    self.roomManagerView.layer.borderWidth = 1.f;
    self.roomManagerView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    
    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
}

- (void)initStudentRenderBlock {
    WEAK(self);
    [self.studentVideoListView setStudentVideoList:^(MCStudentVideoCell * _Nonnull cell, NSInteger currentUid) {

        if(cell == nil){
            return;
        }
               
        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = currentUid;
        model.videoView = cell.videoCanvasView;
        model.renderMode = RTCVideoRenderModeHidden;

        EduConfigModel *configModel = weakself.educationManager.eduConfigModel;
        if (model.uid == configModel.uid) {
           model.canvasType = RTCVideoCanvasTypeLocal;
           [weakself.educationManager setupRTCVideoCanvas:model completeBlock:nil];
        } else {
           model.canvasType = RTCVideoCanvasTypeRemote;
           [weakself.educationManager setRTCRemoteStreamWithUid:model.uid type:RTCVideoStreamTypeLow];
           [weakself.educationManager setupRTCVideoCanvas:model completeBlock:nil];
        }
    }];
}

- (void)initSelectSegmentBlock {
    WEAK(self);
    [self.segmentedView setSelectIndex:^(NSInteger index) {
        if (index == 0) {
            weakself.messageView.hidden = NO;
            weakself.chatTextFiled.hidden = NO;
            weakself.studentListView.hidden = YES;
        }else {
            weakself.messageView.hidden = YES;
            weakself.chatTextFiled.hidden = YES;
            weakself.studentListView.hidden = NO;
        }
    }];
}

#pragma mark ---------------------------- Notification ---------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.chatTextFiledBottomCon.constant = bottom;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.chatTextFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.chatTextFiledBottomCon.constant = 0;
    self.chatTextFiledWidthCon.constant = 222;
}

- (IBAction)messageViewshowAndHide:(UIButton *)sender {
    self.infoManagerViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.roomManagerView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
}

- (void)checkNeedRender {
    
    if(self.educationManager.teacherModel != nil) {
        NSInteger teacherUid = self.educationManager.teacherModel.uid;
        if([self.educationManager.rtcUids containsObject:@(teacherUid).stringValue]){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", teacherUid];
            NSArray<RTCVideoSessionModel *> *filteredArray = [self.educationManager.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
            if(filteredArray.count == 0){
                [self renderTeacherCanvas:teacherUid];
            }
            [self updateTeacherViews:self.educationManager.teacherModel];
        } else {
            [self removeTeacherCanvas:teacherUid];
        }
    }
    
    [self reloadStudentViews];
}

- (void)renderTeacherCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.teacherVideoView.videoRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setRTCRemoteStreamWithUid:model.uid type:RTCVideoStreamTypeLow];
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];
}

- (void)removeTeacherCanvas:(NSUInteger)uid {
    self.teacherVideoView.defaultImageView.hidden = NO;
    [self.teacherVideoView updateUserName:@""];
}

- (void)renderShareCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.shareScreenView;
    model.renderMode = RTCVideoRenderModeFit;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];
    
    self.shareScreenView.hidden = NO;
}

- (void)removeShareCanvas:(NSUInteger)uid {
    self.shareScreenView.hidden = YES;
}

- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {
        
        [weakself.navigationView stopTimer];
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteVideoStream:(BOOL)mute {
    
    WEAK(self);
    [self.educationManager updateEnableVideoWithValue:!mute completeSuccessBlock:^{
        
        [weakself reloadStudentViews];
        [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeVideo) value:mute];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        [weakself showToast:errMessage];
        [weakself reloadStudentViews];
    }];
}

- (void)sendSignalWithType:(NSString *)type value:(BOOL)mute {
    SignalMessageInfoModel *model = [SignalMessageInfoModel new];
    model.uid = self.educationManager.eduConfigModel.uid;
    model.account = self.educationManager.eduConfigModel.userName;
    model.resource = type;
    model.value = mute ? 0 : 1;
    [self.educationManager sendSignalWithModel:model completeSuccessBlock:nil completeFailBlock:nil];
}

- (void)muteAudioStream:(BOOL)mute {
    WEAK(self);
    [self.educationManager updateEnableAudioWithValue:!mute completeSuccessBlock:^{
        
        [weakself reloadStudentViews];
        [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeAudio) value:mute];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        [weakself showToast:errMessage];
        [weakself reloadStudentViews];
    }];
}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)reloadStudentViews {
    [self.educationManager refreshStudentModelArray];
    
    [self.studentListView updateStudentArray:self.educationManager.studentListArray];
    [self.studentVideoListView updateStudentArray:self.educationManager.studentListArray];
    
    [self updateStudentViews:self.educationManager.studentModel];
}
    
#pragma mark SignalDelegate
- (void)didReceivedSignal:(SignalMessageInfoModel *)model {
    WEAK(self);
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {

        [weakself updateTimeState];
        [weakself updateChatViews];
        
        [weakself.educationManager disableCameraTransform:roomInfoModel.room.lockBoard];
        
        if(model.uid == weakself.educationManager.teacherModel.uid) {
            
            [weakself updateTeacherViews:weakself.educationManager.teacherModel];
            
        } else {
            
            [weakself reloadStudentViews];
        }

    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself showToast:errMessage];
    }];
}
- (void)didReceivedMessage:(MessageInfoModel *)model {
    [self.messageView addMessageModel:model];
}
- (void)didReceivedReplaySignal:(MessageInfoModel *)model {
    [self.messageView addMessageModel:model];
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {
    
    if(uid == kShareScreenUid) {
        [self renderShareCanvas: uid];
    } else {
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids addObject:uidStr];
        [self checkNeedRender];
    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    
    if (uid == kShareScreenUid) {
        [self removeShareCanvas: uid];
    } else if (uid == self.educationManager.teacherModel.uid) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids removeObject:uidStr];
        [self removeTeacherCanvas: uid];
    } else {
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids removeObject: uidStr];
        [self reloadStudentViews];
    }
}
- (void)rtcNetworkTypeGrade:(RTCNetworkGrade)grade {
    
    switch (grade) {
        case RTCNetworkGradeHigh:
            [self.navigationView updateSignalImageName:@"icon-signal3"];
            break;
        case RTCNetworkGradeMiddle:
            [self.navigationView updateSignalImageName:@"icon-signal2"];
            break;
        case RTCNetworkGradeLow:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
        default:
            break;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *content = textField.text;
    if (content.length > 0) {
        MessageInfoModel *model = [MessageInfoModel new];
        model.account = self.educationManager.eduConfigModel.userName;
        model.content = content;
        WEAK(self);
        [self.educationManager sendMessageWithModel:model completeSuccessBlock:^{
            [weakself.messageView addMessageModel:model];
        } completeFailBlock:^{
            
        }];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

#pragma mark EEPageControlDelegate
- (void)previousPage {
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        }];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.sceneCount - 1  && self.sceneCount > 0) {
        self.sceneIndex ++;
        
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        }];
    }
}

- (void)lastPage {
    self.sceneIndex = self.sceneCount - 1;
    
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, (long)weakself.sceneCount]];
    }];
}

- (void)firstPage {
    self.sceneIndex = 0;
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
    }];
}

-(void)setWhiteSceneIndex:(NSInteger)sceneIndex completionSuccessBlock:(void (^ _Nullable)(void ))successBlock {
    
    [self.educationManager setWhiteSceneIndex:sceneIndex completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            NSLog(@"Set scene index err：%@", error);
        }
    }];
}

#pragma mark EEWhiteboardToolDelegate
- (void)selectWhiteboardToolIndex:(NSInteger)index {
    
    NSArray<NSString *> *applianceNameArray = @[ApplianceSelector, AppliancePencil, ApplianceText, ApplianceEraser];
    if(index < applianceNameArray.count) {
        NSString *applianceName = [applianceNameArray objectAtIndex:index];
        if(applianceName != nil) {
            [self.educationManager setWhiteApplianceName:applianceName];
        }
    }
    
    BOOL bHidden = self.colorShowView.hidden;
    // select color
    if (index == 4) {
        self.colorShowView.hidden = !bHidden;
    } else if (!bHidden) {
        self.colorShowView.hidden = YES;
    }
}

#pragma mark WhitePlayDelegate
- (void)whiteRoomStateChanged {
    WEAK(self);
    [self.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
        weakself.sceneCount = sceneCount;
        weakself.sceneIndex = sceneIndex;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        [weakself.educationManager moveWhiteToContainer:sceneIndex];
    }];
}
@end
