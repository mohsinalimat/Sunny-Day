//
//  LocationData.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation
import CoreData

class LocationData {
    var location: String?   // 위치명
    var latitude: Double?   // 위도
    var longitude: Double?  // 경도
    var regdate: Date?    // 생성날짜
    var objectID: NSManagedObjectID?    // 원본 LocationMO 객체를 참조하기 위한 속성
}
