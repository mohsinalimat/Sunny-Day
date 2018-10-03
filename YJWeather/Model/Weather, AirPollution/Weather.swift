//
//  Weather.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 27..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

class Weather {
    enum WeatherType {
        case realtime, local
    }
    private enum RealtimeCategoryType: String {
        case t1h, sky, pty, rn1, reh, vec, wsd, lgt, uuu, vvv
    }
    private enum LocalCategoryType: String {
        case date, time, pop, pty, r06, reh, s06, sky, t3h, tmn, tmx, uuu, vvv, wav, vec, wsd
    }
    private enum DayType {
        case today
        case yesterday
        case tomorrow
        case dayAfterTomorrow
    }
    // MARK: - Custom methods
    // MARK: -
    /// API 파라미터에서 사용될 날씨 타입에 따른 baseDate, baseTime을 얻는다
    func getBaseDateTime(_ type: WeatherType) -> (String, String) {
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
        case .realtime:
            // 초단기실황, API 제공 시간 매시간 40분,
            // ex) base_time = 1200은 실제 1240분부터 사용가능, 분은 중요하지 않음.
            if minute < 40 {
                if hour == 0 {
                    dateString = getBaseDate(.yesterday)
                    hourString = "23"
                } else if hour == 10 {
                    hourString = "0\(hour - 1)"
                } else {
                    hourString = "\(hour - 1)"
                }
            }
            if hour == 0 && minute >= 40 {
                hourString = "0" + hourString
            } else if hour != 0 && hour < 10 {
                hourString = "0" + hourString
            }
            return (dateString, hourString + minuteString)
        case .local:
            // 동네예보, API 제공 시간 0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 시간 10분,
            // ex) base_time = 0200은 실제 0210부터 사용가능
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
    /// base_date에 사용되는 현재 년월일을 문자열로 반환한다.
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
    /// 데이터를 추출하여 변환후 반환한다
    func extractData(_ type: WeatherType, data: Any?) -> Any? {
        guard let result = data as? [String: Any],
            let response = result["response"] as? [String: Any],
            let body = response["body"] as? [String: Any],
            let items = body["items"] as? [String: Any],
            let item = items["item"] as? [[String: Any]] else {
                return nil
        }
        switch type {
        case .realtime:
            return extractRealtimeData(item)
        case .local:
            return extractLocalData(item)
        }
    }
    /// 초단기 실황 데이터를 추출하여 변환후 반환한다
    private func extractRealtimeData(_ data: Any) -> WeatherRealtimeData? {
        guard let items = data as? [[String: Any]] else {
            return nil
        }
        var weatherRealtimeData = WeatherRealtimeData()
        for item in items {
            guard let category = item["category"] as? String,
                let value = item["obsrValue"] as? Double else {
                    return nil
            }
            switch category {
            case "T1H":
                weatherRealtimeData.t1h = convertToRealtimeString(.t1h, value: value)
            case "SKY":
                weatherRealtimeData.sky = convertToRealtimeString(.sky, value: value)
            case "PTY":
                weatherRealtimeData.pty = convertToRealtimeString(.pty, value: value)
            case "RN1":
                weatherRealtimeData.rn1 = convertToRealtimeString(.rn1, value: value)
            case "REH":
                weatherRealtimeData.reh = convertToRealtimeString(.reh, value: value)
            case "VEC":
                weatherRealtimeData.vec = convertToRealtimeString(.vec, value: value)
            case "WSD":
                weatherRealtimeData.wsd = convertToRealtimeString(.wsd, value: value)
            case "LGT":
                weatherRealtimeData.lgt = convertToRealtimeString(.lgt, value: value)
            case "UUU":
                weatherRealtimeData.uuu = convertToRealtimeString(.uuu, value: value)
            case "VVV":
                weatherRealtimeData.vvv = convertToRealtimeString(.vvv, value: value)
            default:
                continue
            }
        }
        return weatherRealtimeData
    }
    /// 초단기 실황 데이터를 추출하여 변환후 반환한다
    private func extractLocalData(_ data: Any) -> [WeatherLocalData]? {
        guard let items = data as? [[String: Any]] else {
            return nil
        }
        var weatherLocals = [WeatherLocalData]()
        var weatherLocalData = WeatherLocalData()
        var date = ""
        var time = ""
        for item in items {
            guard let forecastDate = item["fcstDate"],
                let forecastTime = item["fcstTime"],
                let category = item["category"] as? String,
                let value = item["fcstValue"] as? Double else {
                    return nil
            }
            if date != "\(forecastDate)" || time != "\(forecastTime)" {
                if !date.isEmpty {
                    weatherLocals.append(weatherLocalData)
                    weatherLocalData = WeatherLocalData()
                }
                date = "\(forecastDate)"
                time = "\(forecastTime)"
                weatherLocalData.date = date
                weatherLocalData.time = time
            }
            // 루프의 종료 +24시간의 데이터만 받아온다
            let (_, escapeTime) = getBaseDateTime(.local)
            let baseHour = String(escapeTime.prefix(2))
            var escapeDate = 0
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: Date())
            if baseHour == "23" {
                if currentHour == 23 {
                    if let date = Int(getBaseDate(.dayAfterTomorrow) + "0000") {
                        escapeDate = date
                    }
                } else {
                    if let date = Int(getBaseDate(.tomorrow) + "0000") {
                        escapeDate = date
                    }
                }
            } else {
                if let date = Int(getBaseDate(.tomorrow) + escapeTime) {
                    escapeDate = date + 100
                }
            }
            if let currentDate = Int("\(date)\(time)"),
                currentDate > escapeDate {
                break
            }
            //pop, pty, r06, reh, s06, sky, t3h, tmn, tmx, uuu, vvv, wav, vec, wsd
            switch category {
            case "POP":
                weatherLocalData.pop = convertToLocalString(.pop, value: value)
            case "PTY":
                weatherLocalData.pty = convertToLocalString(.pty, value: value)
            case "R06":
                weatherLocalData.r06 = convertToLocalString(.r06, value: value)
            case "REH":
                weatherLocalData.reh = convertToLocalString(.reh, value: value)
            case "S06":
                weatherLocalData.s06 = convertToLocalString(.s06, value: value)
            case "SKY":
                weatherLocalData.sky = convertToLocalString(.sky, value: value)
            case "T3H":
                weatherLocalData.t3h = convertToLocalString(.t3h, value: value)
            case "TMN":
                weatherLocalData.tmn = convertToLocalString(.tmn, value: value)
            case "TMX":
                weatherLocalData.tmx = convertToLocalString(.tmx, value: value)
            case "UUU":
                weatherLocalData.uuu = convertToLocalString(.uuu, value: value)
            case "VVV":
                weatherLocalData.vvv = convertToLocalString(.vvv, value: value)
            case "WAV":
                weatherLocalData.wav = convertToLocalString(.wav, value: value)
            case "VEC":
                weatherLocalData.vec = convertToLocalString(.vec, value: value)
            case "WSD":
                weatherLocalData.wsd = convertToLocalString(.wsd, value: value)
            default:
                continue
            }
        }
        return weatherLocals
    }
    /// 추출한 데이터를 문자열로 변환한다
    private func convertToLocalString(_ type: LocalCategoryType, value: Double) -> String {
        var result = ""
        switch type {
        case .pop:
            result = "\(Int(value))%"
        case .pty:
            if value == 0 {
                result = "없음"
            } else if value == 1 {
                result = "비"
            } else if value == 2 {
                result = "비/눈"
            } else if value == 3 {
                result = "눈"
            }
        case .r06:
            if value == 0 {
                result = "0mm"
            } else if value <= 1 {
                result = "1mm미만"
            } else if value <= 5 {
                result = "1~4mm"
            } else if value <= 10 {
                result = "5~9mm"
            } else if value <= 20 {
                result = "10~19mm"
            } else if value <= 40 {
                result = "20~39mm"
            } else if value <= 70 {
                result = "40~69mm"
            } else if value == 100 {
                result = "70mm이상"
            }
        case .reh:
            result = "\(Int(value))%"
        case .s06:
            if value == 0 {
                result = "0cm"
            } else if value <= 1 {
                result = "1cm 미만"
            } else if value <= 5 {
                result = "1 ~ 4cm"
            } else if value <= 10 {
                result = "5 ~ 9cm"
            } else if value <= 20 {
                result = "10 ~ 19cm"
            } else if value == 100 {
                result = "20cm 이상"
            }
        case .sky:
            if value == 1 {
                result = "맑음"
            } else if value == 2 {
                result = "구름조금"
            } else if value == 3 {
                result = "구름많음"
            } else if value == 4 {
                result = "흐림"
            }
        case .t3h, .tmn, .tmx:
            result = "\(Int(round(value)))°"
        case .uuu, .vvv:
            result = "\(Int(round(value)))m/s"
        case .wav:
            result = "\(value)m"
        case .vec:
            let vec = Int((value + 22.5 * 0.5) / 22.5)
            if vec == 0 || vec == 16 {
                result = "북"
            } else if vec <= 3 {
                result = "북동"
            } else if vec == 4 {
                result = "동"
            } else if vec <= 7 {
                result = "동남"
            } else if vec == 8 {
                result = "남"
            } else if vec <= 11 {
                result = "남서"
            } else if vec == 12 {
                result = "서"
            } else if vec <= 15 {
                result = "서북"
            }
        case .wsd:
            result = "\(value)m/s"
        default:
            ()
        }
        return result
    }
    /// 추출한 데이터를 문자열로 변환한다
    private func convertToRealtimeString(_ type: RealtimeCategoryType, value: Double) -> String {
        var result = ""
        switch type {
        case .t1h:  // 현재온도
            result = "\(Int(round(value)))°"
        case .sky:  // 하늘상태
            if value == 1 {
                result = "맑음"
            } else if value == 2 {
                result = "구름조금"
            } else if value == 3 {
                result = "구름많음"
            } else if value == 4 {
                result = "흐림"
            }
        case .pty:  // 강수형태
            if value == 0 {
                result = "없음"
            } else if value == 1 {
                result = "비"
            } else if value == 2 {
                result = "비/눈"
            } else if value == 3 {
                result = "눈"
            }
        case .rn1:  // 강수량
            if value == 0 {
                result = "0mm"
            } else if value <= 1 {
                result = "1mm 미만"
            } else if value <= 5 {
                result = "1 ~ 4mm"
            } else if value <= 10 {
                result = "5 ~ 9mm"
            } else if value <= 20 {
                result = "10 ~ 19mm"
            } else if value <= 40 {
                result = "20 ~ 39mm"
            } else if value <= 70 {
                result = "40 ~ 69mm"
            } else if value == 100 {
                result = "70mm 이상"
            }
        case .reh:  // 습도
            result = "\(Int(value))%"
        case .vec:  // 풍향
            let vec = Int((value + 22.5 * 0.5) / 22.5)
            if vec == 0 || vec == 16 {
                result = "북"
            } else if vec <= 3 {
                result = "북동"
            } else if vec == 4 {
                result = "동"
            } else if vec <= 7 {
                result = "동남"
            } else if vec == 8 {
                result = "남"
            } else if vec <= 11 {
                result = "남서"
            } else if vec == 12 {
                result = "서"
            } else if vec <= 15 {
                result = "서북"
            }
        case .wsd:  // 풍속
            result = "\(value)m/s"
        case .lgt:  // 낙뢰
            if value == 0 {
                result = "없음"
            } else {
                result = "있음"
            }
        case .uuu, .vvv:  // 동서바람성분, 남북바람성분
            result = "\(Int(round(value)))m/s"
        }
        return result
    }
}
