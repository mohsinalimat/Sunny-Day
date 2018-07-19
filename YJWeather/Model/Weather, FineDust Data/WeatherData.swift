//
//  WeatherData.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

class WeatherData {
    
    enum ForecastType {
        case forecastGrib   // 초단기실황
        case forecastSpaceData  // 동네예보
    }
    
    enum DayType {
        case today
        case yesterday
        case tomorrow
        case dayAfterTomorrow
    }
    
    // base_date에 사용되는 현재 년월일을 문자열로 반환한다.
    private func getBaseDate(_ type: DayType) -> String {
        let date = Date()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        var dateString = ""
        
        formatter.dateFormat = "YYYYMMdd"
        
        switch type {
        case .today:
            dateString = formatter.string(from: date)
        case .yesterday:
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
                dateString = formatter.string(from: yesterday)
            }
        case .tomorrow:
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) {
                dateString = formatter.string(from: tomorrow)
            }
        case .dayAfterTomorrow:
            if let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: date) {
                dateString = formatter.string(from: dayAfterTomorrow)
            }
        }
        return dateString
    }
    
    // base_time에 사용되는 시간을 Api 타입에 따라 다르게 문자열로 반환한다.
    func getBaseDateTime(_ type: ForecastType) -> (String, String) {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        var dateString = getBaseDate(.today)
        var hourString = "\(hour)"
        var minuteString = "\(minute)"
        
        if minute < 10 {
            minuteString = "0" + "\(minute)"
        }
        switch type {
            // 초단기실황, API 제공 시간 매시간 40분,
        // ex) base_time = 1200은 실제 1240분부터 사용가능, 분은 중요하지 않음.
        case .forecastGrib:
            if minute < 30 {
                if hour == 0 {
                    dateString = getBaseDate(.yesterday)
                    hourString = "23"
                } else if hour == 10 {
                    hourString = "0\(hour - 1)"
                } else {
                    hourString = "\(hour - 1)"
                }
            }
            if hour == 0 && minute >= 30 {
                hourString = "0" + hourString
            } else if hour != 0 && hour < 10 {
                hourString = "0" + hourString
            }
            
            return (dateString, hourString + minuteString)
            
            // 동네예보, API 제공 시간 0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 시간 10분,
        // ex) base_time = 0200은 실제 0210부터 사용가능
        case .forecastSpaceData:
            if hour >= 2 && hour < 5 {
                if hour == 2 && minute < 10 {
                    dateString = getBaseDate(.yesterday)
                    hourString = "23"
                } else {
                    hourString = "02"
                }
            } else if hour >= 5 && hour < 8 {
                if hour == 5 && minute < 10 {
                    hourString = "02"
                } else {
                    hourString = "05"
                }
            } else if hour >= 8 && hour < 11 {
                if hour == 8 && minute < 10 {
                    hourString = "05"
                } else {
                    hourString = "08"
                }
            } else if hour >= 11 && hour < 14 {
                if hour == 11 && minute < 10 {
                    hourString = "08"
                } else {
                    hourString = "11"
                }
            } else if hour >= 14 && hour < 17 {
                if hour == 14 && minute < 10 {
                    hourString = "11"
                } else {
                    hourString = "14"
                }
            } else if hour >= 17 && hour < 20 {
                if hour == 17 && minute < 10 {
                    hourString = "14"
                } else {
                    hourString = "17"
                }
            } else if hour >= 20 && hour < 23 {
                if hour == 20 && minute < 10 {
                    hourString = "17"
                } else {
                    hourString = "20"
                }
            } else if hour >= 23 || hour < 2 {
                if hour == 23 && minute < 10 {
                    hourString = "20"
                } else {
                    if hour != 23 {
                        dateString = getBaseDate(.yesterday)
                    }
                    hourString = "23"
                }
            }
            
            return (dateString, hourString + minuteString)
        }
    }
    
    // 초단기실황 데이터를 읽기 쉬운 형태로 변환한다.
    private func getForecastGribData(_ itemArray: [[String: Any]]) -> [String: Any]? {
        var categoryDictionary = [String: Any]()
        
        // 데이터를 카테고리별 분류
        for item in itemArray {
            guard let category = item["category"] as? String,
                let value = item["obsrValue"] as? Double else {
                    return nil
            }
            
            switch category {
            case "T1H": // 기온
                categoryDictionary["T1H"] = "\(Int(round(value)))°"
            case "RN1": // 1시간 강수량
                if value == 0 {
                    categoryDictionary["RN1"] = "0mm"
                } else if value <= 1 {
                    categoryDictionary["RN1"] = "1mm 미만"
                } else if value <= 5 {
                    categoryDictionary["RN1"] = "1 ~ 4mm"
                } else if value <= 10 {
                    categoryDictionary["RN1"] = "5 ~ 9mm"
                } else if value <= 20 {
                    categoryDictionary["RN1"] = "10 ~ 19mm"
                } else if value <= 40 {
                    categoryDictionary["RN1"] = "20 ~ 39mm"
                } else if value <= 70 {
                    categoryDictionary["RN1"] = "40 ~ 69mm"
                } else if value == 100 {
                    categoryDictionary["RN1"] = "70mm 이상"
                }
            case "SKY": // 하늘상태
                if value == 1 {
                    categoryDictionary["SKY"] = "맑음"
                } else if value == 2 {
                    categoryDictionary["SKY"] = "구름조금"
                } else if value == 3 {
                    categoryDictionary["SKY"] = "구름많음"
                } else if value == 4 {
                    categoryDictionary["SKY"] = "흐림"
                }
            case "UUU": // 동서바람성분
                categoryDictionary["UUU"] = "\(Int(round(value)))m/s"
            case "VVV": // 남북바람성분
                categoryDictionary["VVV"] = "\(Int(round(value)))m/s"
            case "REH": // 습도
                categoryDictionary["REH"] = "\(Int(value))%"
            case "PTY": // 강수형태
                if value == 0 {
                    categoryDictionary["PTY"] = "없음"
                } else if value == 1 {
                    categoryDictionary["PTY"] = "비"
                } else if value == 2 {
                    categoryDictionary["PTY"] = "비/눈"
                } else if value == 3 {
                    categoryDictionary["PTY"] = "눈"
                }
            case "LGT": // 낙뢰
                if value == 0 {
                    categoryDictionary["LGT"] = "없음"
                } else {
                    categoryDictionary["LGT"] = "있음"
                }
            case "VEC": // 풍향
                let vec = Int((value + 22.5 * 0.5) / 22.5)
                if vec == 0 || vec == 16 {
                    categoryDictionary["VEC"] = "북"
                } else if vec <= 3 {
                    categoryDictionary["VEC"] = "북동"
                } else if vec == 4 {
                    categoryDictionary["VEC"] = "동"
                } else if vec <= 7 {
                    categoryDictionary["VEC"] = "동남"
                } else if vec == 8 {
                    categoryDictionary["VEC"] = "남"
                } else if vec <= 11 {
                    categoryDictionary["VEC"] = "남서"
                } else if vec == 12 {
                    categoryDictionary["VEC"] = "서"
                } else if vec <= 15 {
                    categoryDictionary["VEC"] = "서북"
                }
            case "WSD": // 풍속
                categoryDictionary["WSD"] = "\(value)m/s"
            default:
                ()
            }
        }
        return categoryDictionary
    }
    
    // 동네예보 데이터를 읽기 쉬운 형태로 변환한다.
    private func getForecastSpaceData(_ itemArray: [[String: Any]]) -> [String: Any]? {
        // [카테고리: [[시간: 값]]]
        var categoryDictionary = [String: [(String, String)]]()
        
        // 데이터를 카테고리별 분류
        for item in itemArray {
            guard let category = item["category"] as? String,
                let value = item["fcstValue"] as? Double,
                let date = item["fcstDate"],
                let time = item["fcstTime"] else {
                    return nil
            }
            
            let (_, escapeTime) = getBaseDateTime(.forecastSpaceData)
            var baseHour = ""
            for c in escapeTime {
                baseHour.append(c)
                if baseHour.count == 2 {
                    break
                }
            }
            
            var escapeDate = 0
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: Date())
            
            if baseHour == "23" {
                if currentHour == 23 {
                    escapeDate = Int(getBaseDate(.dayAfterTomorrow) + "0000")!
                } else {
                    escapeDate = Int(getBaseDate(.tomorrow) + "0000")!
                }
            } else {
                escapeDate = Int(getBaseDate(.tomorrow) + escapeTime)! + 100
            }
            
            let currentDate = Int("\(date)\(time)")!
            
            if currentDate > escapeDate {
                break
            }
 
            let tempTime = "\(time)"
            var hour = ""
            
            for c in tempTime {
                hour += "\(c)"
                if hour.count == 2 {
                    break
                }
            }
            
            switch category {
            case "POP": // 강수확률
                if categoryDictionary["POP"] == nil {
                    categoryDictionary["POP"] = [(String, String)]()
                }
                categoryDictionary["POP"]?.append(("\(hour)", "\(Int(value))%"))
            case "PTY": // 강수형태
                if categoryDictionary["PTY"] == nil {
                    categoryDictionary["PTY"] = [(String, String)]()
                }
                if value == 0 {
                    categoryDictionary["PTY"]?.append(("\(hour)", "없음"))
                } else if value == 1 {
                    categoryDictionary["PTY"]?.append(("\(hour)", "비"))
                } else if value == 2 {
                    categoryDictionary["PTY"]?.append(("\(hour)", "비/눈"))
                } else if value == 3 {
                    categoryDictionary["PTY"]?.append(("\(hour)", "눈"))
                }
            case "R06": // 6시간 강수량
                if categoryDictionary["R06"] == nil {
                    categoryDictionary["R06"] = [(String, String)]()
                }
                if value == 0 {
                    categoryDictionary["R06"]?.append(("\(hour)", "0mm"))
                } else if value <= 1 {
                    categoryDictionary["R06"]?.append(("\(hour)", "1mm미만"))
                } else if value <= 5 {
                    categoryDictionary["R06"]?.append(("\(hour)", "1~4mm"))
                } else if value <= 10 {
                    categoryDictionary["R06"]?.append(("\(hour)", "5~9mm"))
                } else if value <= 20 {
                    categoryDictionary["R06"]?.append(("\(hour)", "10~19mm"))
                } else if value <= 40 {
                    categoryDictionary["R06"]?.append(("\(hour)", "20~39mm"))
                } else if value <= 70 {
                    categoryDictionary["R06"]?.append(("\(hour)", "40~69mm"))
                } else if value == 100 {
                    categoryDictionary["R06"]?.append(("\(hour)", "70mm이상"))
                }
            case "REH": // 습도
                if categoryDictionary["REH"] == nil {
                    categoryDictionary["REH"] = [(String, String)]()
                }
                categoryDictionary["REH"]?.append(("\(hour)", "\(Int(value))%"))
            case "S06": // 6시간 신적설
                if categoryDictionary["S06"] == nil {
                    categoryDictionary["S06"] = [(String, String)]()
                }
                if value == 0 {
                    categoryDictionary["S06"]?.append(("\(hour)", "0cm"))
                } else if value <= 1 {
                    categoryDictionary["S06"]?.append(("\(hour)", "1cm 미만"))
                } else if value <= 5 {
                    categoryDictionary["S06"]?.append(("\(hour)", "1 ~ 4cm"))
                } else if value <= 10 {
                    categoryDictionary["S06"]?.append(("\(hour)", "5 ~ 9cm"))
                } else if value <= 20 {
                    categoryDictionary["S06"]?.append(("\(hour)", "10 ~ 19cm"))
                } else if value == 100 {
                    categoryDictionary["S06"]?.append(("\(hour)", "20cm 이상"))
                }
            case "SKY": // 하늘상태
                if categoryDictionary["SKY"] == nil {
                    categoryDictionary["SKY"] = [(String, String)]()
                }
                if value == 1 {
                    categoryDictionary["SKY"]?.append(("\(hour)", "맑음"))
                } else if value == 2 {
                    categoryDictionary["SKY"]?.append(("\(hour)", "구름조금"))
                } else if value == 3 {
                    categoryDictionary["SKY"]?.append(("\(hour)", "구름많음"))
                } else if value == 4 {
                    categoryDictionary["SKY"]?.append(("\(hour)", "흐림"))
                }
            case "T3H": // 3시간 기온
                if categoryDictionary["T3H"] == nil {
                    categoryDictionary["T3H"] = [(String, String)]()
                }
                categoryDictionary["T3H"]?.append(("\(hour)", "\(Int(round(value)))°"))
            case "TMN": // 아침 최저기온
                if categoryDictionary["TMN"] == nil {
                    categoryDictionary["TMN"] = [(String, String)]()
                }
                categoryDictionary["TMN"]?.append(("\(hour)", "\(Int(round(value)))°"))
            case "TMX": // 낮 최고기온
                if categoryDictionary["TMX"] == nil {
                    categoryDictionary["TMX"] = [(String, String)]()
                }
                categoryDictionary["TMX"]?.append(("\(hour)", "\(Int(round(value)))°"))
            case "UUU": // 풍속(동서성분)
                if categoryDictionary["UUU"] == nil {
                    categoryDictionary["UUU"] = [(String, String)]()
                }
                categoryDictionary["UUU"]?.append(("\(hour)", "\(Int(round(value)))m/s"))
            case "VVV": // 풍속(남북성분)
                if categoryDictionary["VVV"] == nil {
                    categoryDictionary["VVV"] = [(String, String)]()
                }
                categoryDictionary["VVV"]?.append(("\(hour)", "\(Int(round(value)))m/s"))
            case "WAV": // 파고
                if categoryDictionary["WAV"] == nil {
                    categoryDictionary["WAV"] = [(String, String)]()
                }
                categoryDictionary["WAV"]?.append(("\(hour)", "\(value)m"))
            case "VEC": // 풍향
                if categoryDictionary["VEC"] == nil {
                    categoryDictionary["VEC"] = [(String, String)]()
                }
                let vec = Int((value + 22.5 * 0.5) / 22.5)
                if vec == 0 || vec == 16 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "북"))
                } else if vec <= 3 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "북동"))
                } else if vec == 4 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "동"))
                } else if vec <= 7 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "동남"))
                } else if vec == 8 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "남"))
                } else if vec <= 11 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "남서"))
                } else if vec == 12 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "서"))
                } else if vec <= 15 {
                    categoryDictionary["VEC"]?.append(("\(hour)", "서북"))
                }
            case "WSD": // 풍속
                if categoryDictionary["WSD"] == nil {
                    categoryDictionary["WSD"] = [(String, String)]()
                }
                categoryDictionary["WSD"]?.append(("\(hour)", "\(value)m/s"))
            default:
                ()
            }
        }
        
        return categoryDictionary
    }
    
    // apiType에 따라 데이터 추출을 수행하는 메서드
    func extractJsonData(_ jsonObject: [String: Any], apiType: ForecastType) -> [String: Any]? {
        guard let resObeject = jsonObject["response"] as? [String: Any],
            let bodyObject = resObeject["body"] as? [String: Any],
            let itemsObject = bodyObject["items"] as? [String: Any],
            let itemArray = itemsObject["item"] as? [[String: Any]] else {
                return nil
        }
        
        switch apiType {
        case .forecastGrib:
            guard let dataDictionary = getForecastGribData(itemArray) else {
                return nil
            }
            return dataDictionary
        case .forecastSpaceData:
            guard let dataDictionary = getForecastSpaceData(itemArray) else {
                return nil
            }
            return dataDictionary
        }
    }
}
