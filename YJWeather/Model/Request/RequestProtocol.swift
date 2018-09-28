//
//  RequestProtocol.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 25..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

protocol RequestProtocol {
    func createURL(_ type: URIType) -> URL?
    func request(_ data: LocationData, completion: @escaping completionHandler)
}
