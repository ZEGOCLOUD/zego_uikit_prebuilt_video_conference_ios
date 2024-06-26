//
//  ZegoTopMenuBar.swift
//  ZegoPrebuiltVideoConferenceDemoDemo
//
//  Created by zego on 2022/9/14.
//

import UIKit
import ZegoUIKit

protocol ZegoTopMenuBarDelegate: AnyObject {
    func onLeaveVideoConference(_ isLeave: Bool)
}

class ZegoTopMenuBar: UIView {
    
    public var userID: String?
    public var config: ZegoUIKitPrebuiltVideoConferenceConfig = ZegoUIKitPrebuiltVideoConferenceConfig() {
        didSet {
            self.barButtons = config.topMenuBarConfig.buttons
        }
    }
    private var barButtons:[ZegoMenuBarButtonName] = [] {
        didSet {
            self.createButton()
            self.setupLayout()
        }
    }
    
    private let rightMargin: CGFloat = 13
    private let bottomMargin: CGFloat = 5
    
    private let itemSpace: CGFloat = 1.5
    
    let itemSize: CGSize = CGSize.init(width: 35, height: 35)
    
    public weak var delegate: ZegoTopMenuBarDelegate?
    
    
    weak var showQuitDialogVC: UIViewController?
    
    private var buttons: [UIView] = []
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.colorWithHexString("#FFFFFF")
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect(x: 5, y: self.frame.size.height - 9.5 - 25, width: 150, height: 25)
        self.setupLayout()
    }
    
    /// - Parameter button: <#button description#>
    public func addButtonToMenuBar(_ button: UIButton) {
        if self.buttons.count > self.config.topMenuBarConfig.maxCount {
            return
        }
        self.buttons.append(button)
        self.addSubview(button)
        self.setupLayout()
    }
    
    //MARK: -private
    private func setupLayout() {
        self.layoutViewWithButton()
    }
    
    private func layoutViewWithButton() {
        var index: Int = 0
        var lastView: UIView?
        for button in self.buttons {
            if index == 0 {
                button.frame = CGRect.init(x: self.frame.size.width - rightMargin - itemSize.width, y: self.frame.size.height - bottomMargin - itemSize.height, width: itemSize.width, height: itemSize.width)
            } else {
                if let lastView = lastView {
                    button.frame = CGRect.init(x: lastView.frame.minX - itemSpace - itemSize.width, y: lastView.frame.minY, width: itemSize.width, height: itemSize.height)
                }
            }
            lastView = button
            index = index + 1
        }
    }
    
    
    private func createButton() {
        self.buttons.removeAll()
        var index = 0
        for item in self.barButtons {
            index = index + 1
            if self.config.topMenuBarConfig.maxCount < self.barButtons.count && index == self.config.bottomMenuBarConfig.maxCount {
                break
            }
            switch item {
            case .switchCameraButton:
                let flipCameraComponent: ZegoSwitchCameraButton = ZegoSwitchCameraButton()
                flipCameraComponent.iconBackFacingCamera = ZegoUIKitVideoConferenceIconSetType.icon_camera_overturn.load()
                flipCameraComponent.iconFrontFacingCamera = ZegoUIKitVideoConferenceIconSetType.icon_camera_overturn.load()
                self.buttons.append(flipCameraComponent)
                self.addSubview(flipCameraComponent)
            case .toggleCameraButton:
                let switchCameraComponent: ZegoToggleCameraButton = ZegoToggleCameraButton()
                switchCameraComponent.iconCameraOn = ZegoUIKitVideoConferenceIconSetType.top_icon_camera_normal.load()
                switchCameraComponent.iconCameraOff = ZegoUIKitVideoConferenceIconSetType.top_icon_camera_off.load()
                switchCameraComponent.isOn = self.config.turnOnCameraWhenJoining
                switchCameraComponent.userID = ZegoUIKit.shared.localUserInfo?.userID
                self.buttons.append(switchCameraComponent)
                self.addSubview(switchCameraComponent)
            case .toggleMicrophoneButton:
                let micButtonComponent: ZegoToggleMicrophoneButton = ZegoToggleMicrophoneButton()
                micButtonComponent.iconMicrophoneOn = ZegoUIKitVideoConferenceIconSetType.top_icon_mic_normal.load()
                micButtonComponent.iconMicrophoneOff = ZegoUIKitVideoConferenceIconSetType.top_icon_mic_off.load()
                micButtonComponent.userID = ZegoUIKit.shared.localUserInfo?.userID
                micButtonComponent.isOn = self.config.turnOnMicrophoneWhenJoining
                self.buttons.append(micButtonComponent)
                self.addSubview(micButtonComponent)
            case .swtichAudioOutputButton:
                let audioOutputButtonComponent: ZegoSwitchAudioOutputButton = ZegoSwitchAudioOutputButton()
                audioOutputButtonComponent.useSpeaker = self.config.useSpeakerWhenJoining
                audioOutputButtonComponent.iconSpeaker = ZegoUIKitVideoConferenceIconSetType.top_icon_voice_normal.load()
                audioOutputButtonComponent.iconBluetooth = ZegoUIKitVideoConferenceIconSetType.top_icon_bluetooth_nor.load()
                audioOutputButtonComponent.iconEarSpeaker = ZegoUIKitVideoConferenceIconSetType.top_icon_voice_off.load()
                self.buttons.append(audioOutputButtonComponent)
                self.addSubview(audioOutputButtonComponent)
            case .leaveButton:
                let endButtonComponent: ZegoLeaveButton = ZegoLeaveButton()
                endButtonComponent.iconLeave = ZegoUIKitVideoConferenceIconSetType.top_icon_hand_up.load()
                if let leaveConfirmDialogInfo = self.config.leaveConfirmDialogInfo {
                    if leaveConfirmDialogInfo.title == "" || leaveConfirmDialogInfo.title == nil {
                        leaveConfirmDialogInfo.title = self.config.translationText.leaveConferenceTitle
                    }
                    if leaveConfirmDialogInfo.message == "" || leaveConfirmDialogInfo.title == nil {
                        leaveConfirmDialogInfo.message = self.config.translationText.leaveConferenceMessage
                    }
                    if leaveConfirmDialogInfo.cancelButtonName == "" || leaveConfirmDialogInfo.cancelButtonName == nil  {
                        leaveConfirmDialogInfo.cancelButtonName = self.config.translationText.dialogCancelButton
                    }
                    if leaveConfirmDialogInfo.confirmButtonName == "" || leaveConfirmDialogInfo.confirmButtonName == nil  {
                        leaveConfirmDialogInfo.confirmButtonName = self.config.translationText.dialogConfirmButton
                    }
                    if leaveConfirmDialogInfo.dialogPresentVC == nil  {
                        leaveConfirmDialogInfo.dialogPresentVC = self.showQuitDialogVC
                    }
                    endButtonComponent.quitConfirmDialogInfo = leaveConfirmDialogInfo
                }
                endButtonComponent.delegate = self
                self.buttons.append(endButtonComponent)
                self.addSubview(endButtonComponent)
            case .showMemberListButton:
                let memberButton: ZegoVideoConferenceMemberButton = ZegoVideoConferenceMemberButton()
                self.buttons.append(memberButton)
                self.addSubview(memberButton)
                memberButton.addTarget(self, action: #selector(memberButtonClick), for: .touchUpInside)
            case .chatButton:
                let messageButton: ZegoVideoConferenceChatButton = ZegoVideoConferenceChatButton()
                messageButton.setImage(ZegoUIKitVideoConferenceIconSetType.top_icon_im.load(), for: .normal)
                self.buttons.append(messageButton)
                self.addSubview(messageButton)
                messageButton.addTarget(self, action: #selector(messageButtonClick), for: .touchUpInside)
            }
        }
    }
    
    @objc func memberButtonClick() {
        let memberListView: ZegoConferenceMemberList = ZegoConferenceMemberList()
        memberListView.showCameraStateOnMemberList = self.config.memberListConfig.showCameraState
        memberListView.showMicroPhoneStateOnMemberList = self.config.memberListConfig.showMicrophoneState
        memberListView.delegate = self.showQuitDialogVC as? ZegoConferenceMemberListDelegate
        memberListView.translationText = self.config.translationText
        memberListView.frame = CGRect(x: 0, y: 0, width: self.showQuitDialogVC?.view.frame.size.width ?? UIKitScreenWidth, height:self.showQuitDialogVC?.view.frame.size.height ?? UIkitScreenHeight)
        self.showQuitDialogVC?.view.addSubview(memberListView)
    }
    
    @objc func messageButtonClick() {
        let messageView: ZegoVideoConferenceChatView = ZegoVideoConferenceChatView()
        messageView.delegate = self.showQuitDialogVC as? ZegoVideoConferenceChatViewDelegate
        messageView.translationText = self.config.translationText
        messageView.frame = CGRect(x: 0, y: 0, width:self.showQuitDialogVC?.view.frame.size.width ?? UIKitScreenWidth, height:self.showQuitDialogVC?.view.frame.size.height ?? UIkitScreenHeight )
        self.showQuitDialogVC?.view.addSubview(messageView)
    }

}

extension ZegoTopMenuBar: LeaveButtonDelegate {
    func onLeaveButtonClick(_ isLeave: Bool) {
        self.delegate?.onLeaveVideoConference(isLeave)
        if isLeave {
            showQuitDialogVC?.dismiss(animated: true, completion: nil)
        }
    }
}
