## 项目简介
#### 小班课是基于教育场景的一个demo示例，大家可以通过工程下载到本地进行工程编译和体验，里面包含老师和学生通话，白板功能。
## 运行体验方法
#### 工程依赖
```
  pod 'AFNetworking', '~> 3.2.1'
  pod 'MJExtension', '~> 3.0.16'
  pod 'AgoraRtm_iOS'
  pod 'White-SDK-iOS'
  pod 'AgoraRtcEngine_iOS', '~> 2.4.0.1
```
#### 系统要求
	•	最低支持iOS版本：iOS 8.0
	•	支持CPU架构：arm64e,arm64,armv7s,armv7(x86_64模拟器)
#### 下载工程
```
git clone https://github.com/AgoraIO-Usecase/eEducation.git
```
#### 运行工程
```
cd education_iOS
pod install
open AgoraMiniClass.xcworkspace
```
注意：
运行工程之后需要填入appid,获取appid的方式请登录[声网](www.agora.io)获取。
## 参考文档
[声网API参考](https://docs.agora.io/cn/Interactive%20Broadcast/API%20Reference/oc/docs/headers/Agora-Objective-C-API-Overview.html)        
[白板的API参考](https://developer.netless.link/docs/ios/overview/ios-introduction)              
[RT文档参考](https://docs.agora.io/cn/Real-time-Messaging/RTM_product?platform=All%20Platforms)



	





