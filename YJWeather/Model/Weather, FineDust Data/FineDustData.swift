//
//  FineDustData.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

class FineDustData {
    
    enum msrstnType {
        case msrstnAcctoRltmMesureDnsty   // 측정소별 실시간 측정 정보 조회
        case tmStdrCrdnt  // TM 기준좌표 조회(읍면동 검색)
    }
    
    // 실시간 측정 정보 데이터 변환 메서드
    private func getMsrstnAcctoRltmMesureDnstyData(_ itemArray: [[String: Any]]) -> [String: Any]? {
        guard let item = itemArray.first else {
            return nil
        }
        var dataDictionary = [String: Any]()
        for (key, value) in item {
            let value = "\(value)"
            switch key {
            case "dataTime":    // 측정일
                dataDictionary[key] = "\(value)"
            case "mangName":    // 측정망 정보
                dataDictionary[key] = "\(value)"
            case "so2Value":    // 아황산가스 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)ppm"
            case "coValue":     // 일산화탄소 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)ppm"
            case "o3Value":     // 오존 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)ppm"
            case "no2Value":    // 이산화질소 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)ppm"
            case "pm10Value":   // 미세먼지(PM10) 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)㎍/㎥"
            case "pm10Value24": // 미세먼지(PM10) 24시간 평균 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)㎍/㎥"
            case "pm25Value":   // 미세먼지(PM2.5) 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)㎍/㎥"
            case "pm25Value24": // 미세먼지(PM2.5) 24시간 평균 농도
                dataDictionary[key] = (value == "-") ? "-" : "\(value)㎍/㎥"
            case "khaiValue":   // 통합대기환경수치
                dataDictionary[key] = "\(value)"
            case "khaiGrade":   // 통합대기환경지수
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "so2Grade":   // 아황산가스 지수
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "coGrade":   // 일산화탄소 지수
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "o3Grade":   // 오존 지수
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "no2Grade":   // 이산화질소 지수
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "pm10Grade":   // 미세먼지(PM10) 24시간 등급
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "pm25Grade":   // 미세먼지(PM2.5) 24시간 등급
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "pm10Grade1h":   // 미세먼지(PM10) 1시간 등급
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            case "pm25Grade1h":   // 미세먼지(PM2.5) 1시간 등급
                let grade = "\(value)"
                dataDictionary[key] = grade
                if grade == "1" {
                    dataDictionary[key] = "좋음"
                } else if grade == "2" {
                    dataDictionary[key] = "보통"
                } else if grade == "3" {
                    dataDictionary[key] = "나쁨"
                } else if grade == "4" {
                    dataDictionary[key] = "매우나쁨"
                } else {
                    dataDictionary[key] = "정보없음"
                }
            default:
                ()
            }
        }
        return dataDictionary
    }
    
    // 읍면동 검색 기반 데이터를 위치명, TM좌표로 변환하는 메서드
    private func getTmstdrCrdntData(_ itemArray: [[String: Any]]) -> [String: Any]? {
        
        var dataDictionary = [String: Any]()
        
        for item in itemArray {
            var sidoName = ""
            var sggName = ""
            var umdName = ""
            var tmX: Double = 0
            var tmY: Double = 0
            
            for (key, value) in item {
                switch key {
                case "sidoName":    // 시도
                    sidoName = "\(value)"
                case "sggName":     // 시군구
                    sggName = "\(value)"
                case "umdName":     // 읍면동
                    umdName = "\(value)"
                case "tmX":         // tmX 좌표
                    if let value = Double("\(value)") {
                        tmX = value
                    }
                case "tmY":         // tmY좌표
                    if let value = Double("\(value)") {
                        tmY = value
                    }
                default:
                    ()
                }
            }
            let locatinoName = sidoName + " " + sggName + " " + umdName
            dataDictionary[locatinoName] = (tmX, tmY)
        }
        
        if dataDictionary.isEmpty {
            return nil
        }
        
        return dataDictionary
    }
    
    // apiType에 따라 데이터 추출을 수행하는 메서드
    func extractJsonData(_ jsonObject: [String: Any], apiType: msrstnType) -> [String: Any]? {
        guard let itemArray = jsonObject["list"] as? [[String: Any]] else {
            return nil
        }
        
        switch apiType {
        case .msrstnAcctoRltmMesureDnsty:
            guard let dataDictionary = getMsrstnAcctoRltmMesureDnstyData(itemArray) else {
                return nil
            }
            return dataDictionary
        case .tmStdrCrdnt:
            guard let dataDictionary = getTmstdrCrdntData(itemArray) else {
                return nil
            }
            return dataDictionary
        }
    }
}

