//
//  AirPollutionData.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 28..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

struct AirPollutionData {
    var stationName: String?    // 측정소
    var dataTime: String?       // 측정일
    var mangName: String?       // 측정망 정보
    var so2Value: String?       // 아황산가스 농도
    var coValue: String?        // 일산화탄소 농도
    var o3Value: String?        // 오존 농도
    var no2Value: String?       // 이산화질소 농도
    var pm10Value: String?      // 미세먼지(PM10) 농도
    var pm10Value24: String?    // 미세먼지(PM10) 24시간 평균 농도
    var pm25Value: String?      // 미세먼지(PM2.5) 농도
    var pm25Value24: String?    // 미세먼지(PM2.5) 24시간 평균 농도
    var khaiValue: String?      // 통합대기환경수치
    var khaiGrade: String?      // 통합대기환경지수
    var so2Grade: String?       // 아황산가스 지수
    var coGrade: String?        // 일산화탄소 지수
    var o3Grade: String?        // 오존 지수
    var no2Grade: String?       // 이산화질소 지수
    var pm10Grade: String?      // 미세먼지(PM10) 24시간 등급
    var pm25Grade: String?      // 미세먼지(PM2.5) 24시간 등급
    var pm10Grade1h: String?    // 미세먼지(PM10) 1시간 등급
    var pm25Grade1h: String?    // 미세먼지(PM2.5) 1시간 등급
}
