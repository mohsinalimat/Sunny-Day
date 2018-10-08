//
//  ExtensionUIDevice.swift
//  YJWeather
//
//  Created by 최영준 on 02/10/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

extension UIDevice {
    
    enum Model {
        case iPhoneMax
        case iPhoneX
        case iPhonePlus
        case iPhone
        case iPhoneSE
        case otherDevice
    }
    /// iPhone 기기 사이즈별 변수
    class var currentIPhone: Model {
        let (width, height) = (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        switch (width, height) {
        case (414, 896):
            return Model.iPhoneMax
        case (375, 812):
            return Model.iPhoneX
        case (414, 736):
            return Model.iPhonePlus
        case (375, 667):
            return Model.iPhone
        case (320, 548):
            return Model.iPhoneSE
        default:
            return Model.otherDevice
        }
    }
}
