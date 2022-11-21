//
//  ZegoVideoConferenceNotiModelBuild.swift
//  ZegoPrebuiltVideoConferenceDemo
//
//  Created by zego on 2022/10/10.
//

import UIKit
import ZegoUIKitSDK

class ZegoVideoConferenceNotiModel: NSObject {
    var messageID: Int64 = 0
    var content: String?
    var attributedContent: NSAttributedString?
    var messageWidth: CGFloat = 0
    var messageHeight: CGFloat = 0
    var userID: String?
    var userName: String?
    var displayTime :UInt = 3
    var isUserLeaveNoti: Bool = false
    var isUserJoinNoti: Bool = false
}

class ZegoVideoConferenceNotiModelBuild: NSObject {
    
    static var _messageViewWidth: CGFloat?
    static var messageViewWidth: CGFloat? {
        set {
            _messageViewWidth = newValue
        }
        get {
            return _messageViewWidth
        }
    }
    
    static func buildModel(with user: ZegoUIKitUser?, message: String, isUserLeaveNoti: Bool = false, isUserJoinNoti: Bool = false) -> ZegoVideoConferenceNotiModel {
        let attributedStr: NSMutableAttributedString = NSMutableAttributedString()
        
        let nameAttributes = getNameAttributes()
        let nameStr: NSAttributedString = NSAttributedString(string: user?.userName ?? "", attributes: nameAttributes)
        
        let space: NSAttributedString = NSAttributedString(string: "\n")
        
        let contentAttributes = getContentAttributes()
        let content: String = " " + message
        let contentStr: NSAttributedString = NSAttributedString(string: content, attributes: contentAttributes)
        
        attributedStr.append(nameStr)
        if !isUserJoinNoti && !isUserLeaveNoti {
            attributedStr.append(space)
        }
        attributedStr.append(contentStr)
        
        let labelWidth = (messageViewWidth ?? 0) - 10 * 2
        let size = attributedStr.boundingRect(with: CGSize.init(width: labelWidth, height: CGFloat(MAXFLOAT)), options:[NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], context: nil).size
        
        let model:ZegoVideoConferenceNotiModel = ZegoVideoConferenceNotiModel()
        model.content = content
        model.attributedContent = attributedStr
        model.messageWidth = size.width + 1.0
        model.messageHeight = size.height
        model.userID = user?.userID
        model.userName = user?.userName
        model.isUserLeaveNoti = isUserLeaveNoti
        model.isUserJoinNoti = isUserJoinNoti
        return model
    }
    
    private static func getNameAttributes() -> [NSAttributedString.Key : Any] {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 16.0
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineBreakMode = .byCharWrapping
        return [.font : UIFont.systemFont(ofSize: 13.0, weight: .medium),
                .paragraphStyle : paragraphStyle,
                .foregroundColor : UIColor.colorWithHexString("FFB763")]
    }
    
    private static func getContentAttributes() -> [NSAttributedString.Key : Any] {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 16.0
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineBreakMode = .byCharWrapping
        return [.font : UIFont.systemFont(ofSize: 13.0),
                .paragraphStyle : paragraphStyle,
                .foregroundColor : UIColor.white]
    }
    
}
