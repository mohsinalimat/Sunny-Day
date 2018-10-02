//
//  RequestError.swift
//  YJWeather
//
//  Created by 최영준 on 02/10/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import Foundation

enum RequestError: Error {
    case networkConnection
    case networkDelay
    case requestFailed
}

extension RequestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkConnection:
            return NSLocalizedString("네트워크 연결이 필요합니다.", comment: "RequestError")
        case .networkDelay:
            return NSLocalizedString("네트워크 연결이 지연되고 있습니다. 잠시 후에 다시 시도해주세요.", comment: "RequestError")
        case .requestFailed:
            return NSLocalizedString("요청이 실패하였습니다. 잠시 후에 다시 시도해주세요.", comment: "RequestError")
        }
    }
}
