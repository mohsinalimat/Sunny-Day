//
//  RequestAPI.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 28..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation
import Alamofire

enum URIType: String {
    case forecastGrib = "ForecastGrib"  // 초단기실황
    case forecastSpaceData = "ForecastSpaceData"  // 동네예보
    case getMsrstnAcctoRltmMesureDnsty  // 측정소별 실시간 측정정보
    case getNearbyMsrstnList    // 근접측정소 목록
}

typealias completionHandler = (Bool, Any?) -> Void

class RequestAPI: RequestAPIProtocol {
    // MARK: - Properties
    // MARK: -
    private let serviceKey = "서비스키"
    private let weather = Weather()
    private let airPollution = AirPollution()
    private let coordinates = Coordinates()
    // MARK: - Protocol methods
    // MARK: -
    /// URL을 생성하는 메서드
    func createURL(_ type: URIType) -> URL? {
        var urlString: String
        switch type {
        case .forecastGrib, .forecastSpaceData:
            urlString = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/"
        case .getMsrstnAcctoRltmMesureDnsty:
            urlString = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/"
        case .getNearbyMsrstnList:
            urlString = "http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/"
        }
        urlString += "\(type.rawValue)?ServiceKey=\(serviceKey)"
        return URL(string: urlString)
    }
    /// LocationData를 기반으로 날씨, 미세먼지 데이터를 요청한다
    func request(_ data: LocationData, completion: @escaping completionHandler) {
        guard let location = data.location,
            let latitude = data.latitude,
            let longitude = data.longitude else {
                return
        }
        var weatherRealtime = WeatherRealtimeData()
        var weatherLocals = [WeatherLocalData]()
        var airPollution = AirPollutionData()
        let dispatchGroup = DispatchGroup()
        // 오류 발생 여부
        var errorOccurred = false
        dispatchGroup.enter()
        requestForecastGrib(latitude: latitude, longitude: longitude) { (isSuccess, data) in
            if isSuccess, let data = data as? WeatherRealtimeData {
                weatherRealtime = data
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        requestForecastSpaceData(latitude: latitude, longitude: longitude) { (isSuccess, data) in
            if isSuccess, let data = data as? [WeatherLocalData] {
                weatherLocals = data
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        requestNearbyMsrstnList(latitude: latitude, longitude: longitude) { (isSuccess, data) in
            if isSuccess, let list = data as? [String] {
                dispatchGroup.enter()
                self.requestMsrstnAcctoRltmMesureDnsty(list) { (isSuccess, data) in
                    if isSuccess, let data = data as? AirPollutionData {
                        airPollution = data
                    } else {
                        errorOccurred = true
                    }
                    dispatchGroup.leave()
                }
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global()) {
            // 오류 발생시 nil, 아닐 경우 데이터 전달
            if errorOccurred {
                completion(false, nil)
            } else {
                let totalData = TotalData(location: location, weatherRealtime: weatherRealtime, weatherLocals: weatherLocals, airPollution: airPollution)
                completion(true, totalData)
            }
        }
    }
    // MARK: - Custom methods
    // MARK: -
    /// 초단기실황을 호출하는 메서드
    private func requestForecastGrib(latitude: Double, longitude: Double, completion: @escaping completionHandler) {
        guard let url = createURL(.forecastGrib) else {
            return
        }
        let (nx, ny) = coordinates.convertToGrid(latitude: latitude, longitude: longitude)
        let (baseDate, baseTime) = weather.getBaseDateTime(.realtime)
        let parameters: Parameters = [
            "base_date": baseDate,
            "base_time": baseTime,
            "nx": nx,
            "ny": ny,
            "_type": "json",
            "numOfRows": 10
        ]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            if let data = self.weather.extractData(.realtime, data: response.result.value) {
                completion(true, data)
            } else {
                completion(false, nil)
            }
        }
    }
    /// 동네예보를 호출하는 메서드
    private func requestForecastSpaceData(latitude: Double, longitude: Double, completion: @escaping completionHandler) {
        guard let url = createURL(.forecastSpaceData) else {
            return
        }
        let (nx, ny) = coordinates.convertToGrid(latitude: latitude, longitude: longitude)
        let (baseDate, baseTime) = weather.getBaseDateTime(.local)
        let parameters: Parameters = [
            "base_date": baseDate,
            "base_time": baseTime,
            "nx": nx,
            "ny": ny,
            "_type": "json",
            "numOfRows": 112
        ]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            if let data = self.weather.extractData(.local, data: response.result.value) {
                completion(true, data)
            } else {
                completion(false, nil)
            }
        }
    }
    /// 근접측정소 목록을 호출하는 메서드
    private func requestNearbyMsrstnList(latitude: Double, longitude: Double, completion: @escaping completionHandler) {
        guard let url = createURL(.getNearbyMsrstnList) else {
            return
        }
        let (tmX, tmY) = coordinates.convertToPlaneRect(latitude: latitude, longitude: longitude)
        let parameters: Parameters = [
            "tmX": tmX,
            "tmY": tmY,
            "numOfRows": 1,
            "_returnType": "json"
        ]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            if let data = self.airPollution.extractData(.measuringStation, data: response.result.value) {
                completion(true, data)
            } else {
                completion(false, nil)
            }
        }
    }
    /// 측정소별 실시간 측정정보를 호출하는 메서드
    private func requestMsrstnAcctoRltmMesureDnsty(_ stationNames: [String], completion: @escaping completionHandler) {
        guard let url = createURL(.getMsrstnAcctoRltmMesureDnsty) else {
            return
        }
        var stationNames = stationNames
        let stationName = stationNames.removeFirst()
        let parameters: Parameters = [
            "stationName": stationName,
            "dataTerm": "DAILY",
            "ver": 1.3,
            "numOfRows": 10,
            "_returnType": "json"
        ]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            if let data = self.airPollution.extractData(.realtime, data: response.result.value) {
                completion(true, data)
            } else {
                if stationNames.isEmpty {
                    completion(false, nil)
                }
                self.requestMsrstnAcctoRltmMesureDnsty(stationNames, completion: completion)
            }
        }
    }
}
