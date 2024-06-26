//
//  Prebuilt1on1Config.swift
//  ZegoUIKitExample
//
//  Created by zego on 2022/7/14.
//

import UIKit
import ZegoUIKit


public class ZegoUIKitPrebuiltVideoConferenceConfig: NSObject {
    public var audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig()
    public var bottomMenuBarConfig: ZegoBottomMenuBarConfig = ZegoBottomMenuBarConfig()
    
    public var layout: ZegoLayout = ZegoLayout()
    
    /// Whether the camera is enabled by default. The default value is enabled.
    public var turnOnCameraWhenJoining: Bool = true
    /// Is the microphone enabled by default? It is enabled by default.
    public var turnOnMicrophoneWhenJoining: Bool = true
    /// Is the speaker used by default? The default is true. If no, use the default device.
    public var useSpeakerWhenJoining: Bool = true
    /// The maximum number of buttons that can be displayed in the ControlBar. If this value is exceeded, the "More" button is displayed
    /// Whether to display information about the Leave Room dialog box when the hang up button is clicked. If it is not set, it will not be displayed. If it is set, it will be displayed.
    public var leaveConfirmDialogInfo: ZegoLeaveConfirmDialogInfo?
    public var translationText: ZegoTranslationText = ZegoTranslationText(language: .ENGLISH) {
      didSet{
        topMenuBarConfig.title = translationText.topMenuBarTitle
      }
    }
    public var memberListConfig: ZegoMemberListConfig = ZegoMemberListConfig()
    public var topMenuBarConfig: ZegoTopMenuBarConfig = ZegoTopMenuBarConfig()
    public var inRoomNotificationViewConfig: ZegoInRoomNotificationViewConfig = ZegoInRoomNotificationViewConfig()
    
    public override init() {
        super.init()
        let conferenceLayout = ZegoLayout()
        conferenceLayout.mode = .gallery
        conferenceLayout.config = ZegoLayoutGalleryConfig()
        topMenuBarConfig.title = translationText.topMenuBarTitle
        self.layout = conferenceLayout
    }
}

public class ZegoPrebuiltAudioVideoViewConfig: NSObject {
    /// Used to control whether the default MicrophoneStateIcon for the prebuilt layer is displayed on VideoView.
    public var showMicrophoneStateOnView: Bool = true
    /// Used to control whether the default CameraStateIcon for the prebuilt layer is displayed on VideoView.
    public var showCameraStateOnView: Bool = false
    /// Controls whether to display the default UserNameLabel for the prebuilt layer on VideoView
    public var showUserNameOnView: Bool = true
    /// Whether to display the sound waves around the profile picture in voice mode
    public var showSoundWavesInAudioMode: Bool = true
    /// Default true, normal black edge mode (otherwise landscape is ugly)
    public var useVideoViewAspectFill: Bool = false
}

public class ZegoBottomMenuBarConfig: NSObject {
    /// Buttons that need to be displayed on the MenuBar are displayed in the order of the actual List
    public var buttons: [ZegoMenuBarButtonName] = [.toggleCameraButton,.toggleMicrophoneButton, .leaveButton,.swtichAudioOutputButton,.chatButton]
    /// 在MenuBar最多能显示的按钮数量，该值最大为5。如果超过了该值，则显示“更多”按钮.注意这个值是包含“更多”按钮。
    public var maxCount: UInt = 5
    /// Yes no operation on the screen for 5 seconds, or if the user clicks the position of the non-response area on the screen, the top and bottom will be folded up
    public var hideAutomatically: Bool = true
    /// Whether the user can click the position of the non-responsive area of the screen, and fold up the top and bottom
    public var hideByClick: Bool = true
    public var style: ZegoMenuBarStyle = .dark

}

public class ZegoMemberListConfig: NSObject {
    public var showMicrophoneState: Bool = true
    public var showCameraState: Bool = true
}

public class ZegoTopMenuBarConfig: NSObject {
    public var buttons: [ZegoMenuBarButtonName] = [.switchCameraButton, .showMemberListButton]
    public var maxCount: UInt = 3
    public var hideAutomatically: Bool = true
    public var hideByClick: Bool = true
    public var style: ZegoMenuBarStyle = .dark
    public var isVisible: Bool = true
    public var title: String = ""
}


public class ZegoTranslationText : NSObject {
    var language :ZegoUIKitLanguage  = .ENGLISH
  
    public var topMenuBarTitle: String = "Conference"
    public var joinConferenceTitle: String = "joins the conference."
    public var leftConferenceTitle: String = "left the conference."
    public var memberListTitle: String = "Member"
    public var leaveConferenceTitle: String = "Leave the conference"
    public var leaveConferenceMessage: String = "Are you sure to leave the conference?"
    public var dialogCancelButton: String = "Cancel"
    public var dialogConfirmButton: String = "Confirm"
    public var chatMessagePlaceholder: String = "Send a message to everyone"
    public var chatMessageTitle: String = "Chat"
  
    public init(language:ZegoUIKitLanguage) {
    super.init()
    self.language = language
    if language == .CHS {
      topMenuBarTitle = "会议"
      joinConferenceTitle = "加入回忆"
      leftConferenceTitle = "已离开会议"
      memberListTitle = "成员"
      leaveConferenceTitle = "离开会议"
      leaveConferenceMessage = "确定要离开会议吗？"
      dialogCancelButton = "取消"
      dialogConfirmButton = "确认"
      chatMessagePlaceholder = "向所有人发送信息"
      chatMessageTitle = "聊天"
      }
    }
    public func getLanguage() -> ZegoUIKitLanguage {
      return self.language
    }
}


