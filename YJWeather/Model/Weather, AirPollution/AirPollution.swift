//
//  AirPollution.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 28..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

class AirPollution {
    enum AirPollutionType {
        case measuringStation
        case realtime
    }
    private enum RealtimeCategoryType {
        case dataTime, mangName, so2Value, coValue, o3Value, no2Value, pm10Value, pm10Value24, pm25Value, pm25Value24, khaiValue, khaiGrade, so2Grade, coGrade, o3Grade, no2Grade, pm10Grade, pm25Grade, pm10Grade1h, pm25Grade1h
    }
    // MARK: -
    // MARK: - Custom methods
    func extractData(_ type: AirPollutionType, data: Any?) -> Any? {
        guard let result = data as? [String: Any],
            let list = result["list"] as? [[String: Any]] else {
                return nil
        }
        switch type {
        case .measuringStation:
            return extractMeasuringStationData(list)
        case .realtime:
            var data = extractRealtimeData(list)
            if let info = result["ArpltnInforInqireSvcVo"] as? [String: Any],
                let stationName = info["stationName"] as? String {
                data?.stationName = stationName
            }
            return data
        }
    }
    /// 근접 측정소 목록에서 stationName 목록을 추출하여 반환한다
    private func extractMeasuringStationData(_ data: Any?) -> Any? {
        guard let items = data as? [[String: Any]] else {
            return nil
        }
        var stationNames = [String]()
        // 보통 3개의 측정소 이름이 존재한다
        for item in items {
            if let stationName = item["stationName"] as? String {
                stationNames.append(stationName)
            }
        }
        return stationNames
    }
    /// 측정소별 실시간 측정정보를 추출하여 반환한다
    private func extractRealtimeData(_ data: Any?) -> AirPollutionData? {
        guard let items = data as? [[String: Any]],
            let item = items.first else {
                return nil
        }
        var airPollution = AirPollutionData()
        for (key, value) in item {
            switch key {
            case "dataTime":
                airPollution.dataTime = convertToString(.dataTime, value: value)
            case "mangName":
                airPollution.mangName = convertToString(.mangName, value: value)
            case "so2Value":
                airPollution.so2Value = convertToString(.so2Value, value: value)
            case "coValue":
                airPollution.coValue = convertToString(.coValue, value: value)
            case "o3Value":
                airPollution.o3Value = convertToString(.o3Value, value: value)
            case "no2Value":
                airPollution.no2Value = convertToString(.no2Value, value: value)
            case "pm10Value":
                airPollution.pm10Value = convertToString(.pm10Value, value: value)
            case "pm10Value24":
                airPollution.pm10Value24 = convertToString(.pm10Value24, value: value)
            case "pm25Value":
                airPollution.pm25Value = convertToString(.pm25Value, value: value)
            case "pm25Value24":
                airPollution.pm25Value24 = convertToString(.pm25Value24, value: value)
            case "khaiValue":
                airPollution.khaiValue = convertToString(.khaiValue, value: value)
            case "khaiGrade":
                airPollution.khaiGrade = convertToString(.khaiGrade, value: value)
            case "so2Grade":
                airPollution.so2Grade = convertToString(.so2Grade, value: value)
            case "coGrade":
                airPollution.coGrade = convertToString(.coGrade, value: value)
            case "o3Grade":
                airPollution.o3Grade = convertToString(.o3Grade, value: value)
            case "no2Grade":
                airPollution.no2Grade = convertToString(.no2Grade, value: value)
            case "pm10Grade":
                airPollution.pm10Grade = convertToString(.pm10Grade, value: value)
            case "pm25Grade":
                airPollution.pm25Grade = convertToString(.pm25Grade, value: value)
            case "pm10Grade1h":
                airPollution.pm10Grade1h = convertToString(.pm10Grade1h, value: value)
            case "pm25Grade1h":
                airPollution.pm25Grade1h = convertToString(.pm25Grade1h, value: value)
            default:
                ()
            }
        }
        return airPollution
    }
    private func convertToString(_ type: RealtimeCategoryType, value: Any) -> String {
        var result = ""
        switch type {
        case .dataTime, .mangName, .khaiValue:
            result = "\(value)"
        case .so2Value, .coValue, .o3Value, .no2Value:
            result = ("\(value)" == "-") ? "-" : "\(value)ppm"
        case .pm10Value, .pm10Value24, .pm25Value, .pm25Value24:
            result = ("\(value)" == "-") ? "-" : "\(value)㎍/㎥"
        case .khaiGrade, .so2Grade, .coGrade, .o3Grade, .no2Grade, .pm10Grade, .pm25Grade, .pm10Grade1h, .pm25Grade1h:
            let grade = "\(value)"
            if grade == "1" {
                result = "좋음"
            } else if grade == "2" {
                result = "보통"
            } else if grade == "3" {
                result = "나쁨"
            } else if grade == "4" {
                result = "매우나쁨"
            } else {
                result = "정보없음"
            }
        }
        return result
    }
}
