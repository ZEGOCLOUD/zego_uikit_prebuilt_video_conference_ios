//
//  1v1PrebuiltViewController.swift
//  ZegoUIKitExample
//
//  Created by zego on 2022/7/14.
//

import UIKit
import ZegoUIKitSDK

@objc public protocol ZegoUIKitPrebuiltVideoConferenceVCDelegate: AnyObject {
    @objc optional func getForegroundView(_ userInfo: ZegoUIkitUser?) -> UIView?
    @objc optional func onLeaveVideoConference(_ isLeave: Bool)
    @objc optional func getMemberListItemView(_ tableView: UITableView, indexPath: IndexPath, userInfo: ZegoUIkitUser) -> UITableViewCell?
    @objc optional func getMemberListviewForHeaderInSection(_ tableView: UITableView, section: Int) -> UIView?
    @objc optional func getMemberListItemHeight(_ userInfo: ZegoUIkitUser) -> CGFloat
    @objc optional func getMemberListHeaderHeight(_ tableView: UITableView, section: Int) -> CGFloat
}

open class ZegoUIKitPrebuiltVideoConferenceVC: UIViewController {
    
    var bottomBarHeight: CGFloat = adaptLandscapeHeight(61) + UIKitBottomSafeAreaHeight
    var topMenuBarHeight: CGFloat {
        get {
            if UIKitBottomSafeAreaHeight > 0 {
                return 88
            } else {
                return 64
            }
        }
    }
    
    public weak var delegate: ZegoUIKitPrebuiltVideoConferenceVCDelegate?
    
    private let help: ZegoUIKitPrebuiltVideoConferenceVC_Help = ZegoUIKitPrebuiltVideoConferenceVC_Help()
    fileprivate var config: ZegoUIKitPrebuiltVideoConferenceConfig = ZegoUIKitPrebuiltVideoConferenceConfig()
    private var userID: String?
    private var userName: String?
    private var roomID: String?
    private var isHidenMenuBar: Bool = false
    private var isHidenTopMenuBar: Bool = false
    private var timer: ZegoTimer? = ZegoTimer(1000)
    private var timerCount: Int = 3
    private var currentBottomMenuBar: UIView?
    private var bottomBarY: CGFloat = 0
    private var topBarY: CGFloat = 0
    var lastFrame: CGRect = CGRect.zero
    
    lazy var avContainer: ZegoAudioVideoContainer = {
        let container: ZegoAudioVideoContainer = ZegoAudioVideoContainer()
        container.delegate = self.help
        return container
    }()
    
    lazy var menuBar: ZegoVideoConferenceDarkBottomMenuBar = {
        let menuBar = ZegoVideoConferenceDarkBottomMenuBar()
        menuBar.showQuitDialogVC = self
        menuBar.config = self.config
        menuBar.delegate = self
        menuBar.backgroundColor = UIColor.colorWithHexString("#222222", alpha: 0.9)
        return menuBar
    }()
    
    lazy var lightMenuBar: ZegoVideoConferenceLightBottomMenuBar = {
        let menuBar = ZegoVideoConferenceLightBottomMenuBar()
        menuBar.showQuitDialogVC = self
        menuBar.config = self.config
        menuBar.delegate = self
        return menuBar
    }()
    
    lazy var topBar: ZegoTopMenuBar = {
        let topMenuBar = ZegoTopMenuBar()
        topMenuBar.titleLabel.text = "Meeting"
        topMenuBar.titleLabel.textColor = UIColor.colorWithHexString("#FFFFFF")
        topMenuBar.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        topMenuBar.backgroundColor = UIColor.colorWithHexString("#222222",alpha: 0.9)
        topMenuBar.showQuitDialogVC = self
        topMenuBar.config = self.config
        return topMenuBar
    }()
    
    public init(_ appID: UInt32, appSign: String, userID: String, userName: String, conferenceID: String, config: ZegoUIKitPrebuiltVideoConferenceConfig?) {
        super.init(nibName: nil, bundle: nil)
        self.help.videoConferenceVC = self
        ZegoUIKit.shared.initWithAppID(appID: appID, appSign: appSign)
        ZegoUIKit.shared.localUserInfo = ZegoUIkitUser.init(userID, userName)
        self.userID = userID
        self.userName = userName
        self.roomID = conferenceID
        if let config = config {
            self.config = config
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.joinRoom()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.avContainer.view)
        self.view.addSubview(self.topBar)
        if self.config.bottomMenuBarConfig.style == .dark {
            self.currentBottomMenuBar = self.menuBar
            self.bottomBarHeight = adaptLandscapeHeight(104) + UIKitBottomSafeAreaHeight
            self.view.addSubview(self.menuBar)
        } else {
            self.currentBottomMenuBar = self.lightMenuBar
            self.bottomBarHeight = adaptLandscapeHeight(61) + UIKitBottomSafeAreaHeight
            self.view.addSubview(self.lightMenuBar)
        }
        self.setupLayout()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer = nil
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.view.frame.equalTo(self.lastFrame) {
            self.avContainer.view.frame = CGRect(x: 0, y: UIKitTopSafeAreaHeight, width: self.view.frame.size.width, height: self.view.frame.size.height - UIKitTopSafeAreaHeight - UIKitBottomSafeAreaHeight)
            self.topBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.topMenuBarHeight)
            self.currentBottomMenuBar?.frame = CGRect.init(x: 0, y: self.view.frame.size.height - self.bottomBarHeight, width: self.view.frame.size.width, height: self.bottomBarHeight)
            self.menuBar.addCorner(conrners: [.topLeft,.topRight], radius: 16)
            self.lastFrame = self.view.frame
        }
    }

    public func addButtonToBottomMenuBar(_ button: UIButton) {
        if self.config.bottomMenuBarConfig.style == .dark {
            self.menuBar.addButtonToMenuBar(button)
        } else {
            self.lightMenuBar.addButtonToMenuBar(button)
        }
    }
    
    public func addButtonToTopMenuBar(_ button: UIButton) {
        self.topBar.addButtonToMenuBar(button)
    }
    
    func setupLayout() {
        let audioVideoConfig: ZegoAudioVideoViewConfig = ZegoAudioVideoViewConfig()
        audioVideoConfig.showSoundWavesInAudioMode = self.config.audioVideoViewConfig.showSoundWavesInAudioMode
        audioVideoConfig.useVideoViewAspectFill = self.config.audioVideoViewConfig.useVideoViewAspectFill
        self.avContainer.setLayout(self.config.layout, audioVideoConfig: audioVideoConfig)
        ZegoUIKit.shared.setAudioOutputToSpeaker(enable: self.config.useSpeakerWhenJoining)
        
        if config.bottomMenuBarConfig.style == .dark {
            self.currentBottomMenuBar?.backgroundColor = UIColor.colorWithHexString("#222222", alpha: 0.8)
        } else {
            self.currentBottomMenuBar?.backgroundColor = UIColor.clear
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        self.view.addGestureRecognizer(tap)
        
        //5秒自动隐藏
        guard let timer = timer else {
            return
        }
        timer.setEventHandler {
            if self.timerCount == 0 {
                if self.config.bottomMenuBarConfig.hideAutomatically {
                    if !self.isHidenMenuBar {
                        self.hiddenMenuBar(true)
                    }
                }
                if self.config.topMenuBarConfig.hideAutomatically {
                    if !self.isHidenTopMenuBar {
                        self.hiddenTopMenuBar(isHidden: true)
                    }
                }
            } else {
                self.timerCount = self.timerCount - 1
            }
        }
        timer.start()
    }
    
    @objc func tapClick() {
        if self.config.bottomMenuBarConfig.hideByClick || self.config.topMenuBarConfig.hideByClick {
            if self.config.bottomMenuBarConfig.hideByClick {
                self.hiddenMenuBar(!self.isHidenMenuBar)
            }
            if self.config.topMenuBarConfig.hideByClick {
                self.hiddenTopMenuBar(isHidden: !self.isHidenTopMenuBar)
            }
            guard let timer = timer else {
                return
            }
            timer.start()
            self.timerCount = 3
        } else {
            if self.timerCount <= 0 {
                self.hiddenMenuBar(false)
                self.hiddenTopMenuBar(isHidden: false)
                guard let timer = timer else {
                    return
                }
                timer.start()
                self.timerCount = 3
            }
        }
    }
    
    private func hiddenMenuBar(_ isHidden: Bool) {
        self.isHidenMenuBar = isHidden
        UIView.animate(withDuration: 0.5) {
            if self.config.bottomMenuBarConfig.hideAutomatically {
                let bottomY: CGFloat = isHidden ? UIScreen.main.bounds.size.height:UIScreen.main.bounds.size.height - self.bottomBarHeight
                self.currentBottomMenuBar?.frame = CGRect.init(x: 0, y: bottomY, width: UIScreen.main.bounds.size.width, height: self.bottomBarHeight)
            }
        }
    }
    
    private func hiddenTopMenuBar(isHidden: Bool) {
        self.isHidenTopMenuBar = isHidden
        UIView.animate(withDuration: 0.5) {
            if self.config.topMenuBarConfig.hideAutomatically {
                let topY: CGFloat = isHidden ? -self.topMenuBarHeight : 0
                self.topBar.frame = CGRect.init(x: 0, y: topY, width: UIScreen.main.bounds.size.width, height: self.topMenuBarHeight)
            }
        }
    }
    
    @objc func buttonClick() {
        
    }
    
    private func joinRoom() {
        guard let roomID = self.roomID,
              let userID = self.userID,
              let userName = self.userName
        else { return }
        ZegoUIKit.shared.joinRoom(userID, userName: userName, roomID: roomID)
        ZegoUIKit.shared.turnCameraOn(userID, isOn: self.config.turnOnCameraWhenJoining)
        ZegoUIKit.shared.turnMicrophoneOn(userID, isOn: self.config.turnOnMicrophoneWhenJoining)
    }
    
    deinit {
        ZegoUIKit.shared.leaveRoom()
        print("CallViewController deinit")
    }
}

class ZegoUIKitPrebuiltVideoConferenceVC_Help: NSObject, ZegoAudioVideoContainerDelegate {
    
    weak var videoConferenceVC: ZegoUIKitPrebuiltVideoConferenceVC?
    
    public func getForegroundView(_ userInfo: ZegoUIkitUser?) -> UIView? {
        guard let userInfo = userInfo else {
            return nil
        }
        
        let foregroundView: UIView? = self.videoConferenceVC?.delegate?.getForegroundView?(userInfo)
        if let foregroundView = foregroundView {
            return foregroundView
        } else {
            // user nomal foregroundView
            guard let videoConferenceVC = self.videoConferenceVC else { return  nil }
            let nomalForegroundView: ZegoVideoConferenceNomalForegroundView = ZegoVideoConferenceNomalForegroundView.init(videoConferenceVC.config, frame: .zero)
            nomalForegroundView.userInfo = userInfo
            return nomalForegroundView
        }
    }
    
    func textWidth(_ font: UIFont, text: String) -> CGFloat {
        let maxSize: CGSize = CGSize.init(width: 57, height: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize: CGRect = NSString(string: text).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return labelSize.width
    }
}

extension ZegoUIKitPrebuiltVideoConferenceVC: ZegoVideoConferenceDarkBottomMenuBarDelegate,ZegoVideoConferenceLightBottomMenuBarDelegate, ZegoConferenceMemberListDelegate {
    func onMenuBarMoreButtonClick(_ buttonList: [UIView]) {
        let newList:[UIView] = buttonList
        let vc: ZegoVideoConferenceMoreView = ZegoVideoConferenceMoreView()
        vc.buttonList = newList
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
    
    func onLeaveVideoConference(_ isLeave: Bool) {
        if isLeave {
            self.dismiss(animated: true, completion: nil)
        }
        self.delegate?.onLeaveVideoConference?(isLeave)
    }
    
    func getMemberListItemView(_ tableView: UITableView, indexPath: IndexPath, userInfo: ZegoUIkitUser) -> UITableViewCell? {
        return self.delegate?.getMemberListItemView?(tableView, indexPath: indexPath, userInfo: userInfo)
    }
    
    func getMemberListviewForHeaderInSection(_ tableView: UITableView, section: Int) -> UIView? {
        return self.delegate?.getMemberListviewForHeaderInSection?(tableView, section: section)
    }
    
    func getMemberListItemHeight(_ userInfo: ZegoUIkitUser) -> CGFloat {
        return self.delegate?.getMemberListItemHeight?(userInfo) ?? 54
    }
    
    func getMemberListHeaderHeight(_ tableView: UITableView, section: Int) -> CGFloat {
        return self.delegate?.getMemberListHeaderHeight?(tableView, section: section) ?? 65
    }
}
