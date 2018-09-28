//
//  WeatherLocalData.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 28..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

struct WeatherLocalData {
    var date: String?   // 예보 일자
    var time: String?   // 예보 시간
    var pop: String?    // 강수확률
    var pty: String?    // 강수형태
    var r06: String?    // 6시간 강수량
    var reh: String?    // 습도
    var s06: String?    // 6시간 신적설
    var sky: String?    // 하늘상태
    var t3h: String?    // 3시간 기온
    var tmn: String?    // 아침 최저기온
    var tmx: String?    // 낮 최고기온
    var uuu: String?    // 동서바람성분
    var vvv: String?    // 남북바람성분
    var wav: String?    // 파고
    var vec: String?    // 풍향
    var wsd: String?    // 풍속
}
