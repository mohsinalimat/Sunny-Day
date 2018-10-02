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
        case iPhnoeXR
        case iPhonePlus
        case iPhone
        case iPhoneSE
        case otherDevice
    }
    class var currentIPhone: Model {
        switch self.current.name {
        case "iPhone XS Max":
            return .iPhoneMax
        case "iPhone X", "iPhone XS":
            return .iPhoneX
        case "iPhone XR":
            return .iPhnoeXR
        case "iPhone 8 Plus", "iPhone 7 Plus", "iPhone 6s Plus", "iPhone 6 Plus":
            return .iPhonePlus
        case "iPhone 8", "iPhone 7", "iPhone 6s", "iPhone 6":
            return .iPhone
        case "iPhone SE", "iPhone 5s":
            return .iPhoneSE
        default:
            return .otherDevice
        }
    }
}
