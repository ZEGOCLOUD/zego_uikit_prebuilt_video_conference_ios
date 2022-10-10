//
//  ZegoVideoConferenceChatButton.swift
//  ZegoPrebuiltVideoConferenceDemo
//
//  Created by zego on 2022/9/23.
//

import UIKit

class ZegoVideoConferenceChatButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(ZegoUIKitVideoConferenceIconSetType.icon_message_normal.load(), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
