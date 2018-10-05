//
//  TotalData.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 28..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

struct TotalData {
    var location: String
    var regdate: Date
    var weatherRealtime: WeatherRealtimeData
    var weatherLocals: [WeatherLocalData]
    var airPollution: AirPollutionData
}
