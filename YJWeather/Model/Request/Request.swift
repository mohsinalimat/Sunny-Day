//
//  Request.swift
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

class Request: RequestProtocol {
    // MARK: - Properties
    // MARK: -
    private let serviceKey = "G0YMvvFG8%2FPUuXzmKHgKxTWhv1fkmYJHyE2chPMURldB%2Fml97PU1Ff%2BL4QJE4CgxPPyIaPoLwiXrtYJvMa2vAw%3D%3D"
    private let weather = Weather()
    private let airPollution = AirPollution()
    private let coordinates = Coordinates()
    private lazy var locations: [LocationData] = {
        var locations = (UIApplication.shared.delegate as! AppDelegate).locations
        locations = LocationDAO().fetch()
        return locations
    }()
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
    /// LocationData와 Appdelegate.locatinos를 사용하여 모든 데이터를 요청하고 성공시 핸들러를 통해 [TotalData]를 전달한다
    func getTotalDataList(_ data: LocationData, completion: @escaping requestCompletionHandler) {
        var requestError: RequestError?
        // 네트워크 연결 상태를 확인한다
        if !Reachability.isConnectedToNetwork() {
            requestError = .networkConnection
            completion(false, nil, requestError)
            return
        }
        // 네트워크 연결 지연 처리
        let deadlineTask = DispatchWorkItem {
            requestError = .networkDelay
            completion(false, nil, requestError)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 30, execute: deadlineTask)
        var totalDataList = [TotalData]()
        let dispatchGroup = DispatchGroup()
        // 네트워크 인디케이터 로딩 시작
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        dispatchGroup.enter()
        // 현재 위치 데이터 처리
        request(data) { (isSuccess, data, error) in
            if isSuccess, let totalData = data as? TotalData {
                totalDataList.insert(totalData, at: 0)
            } else {
                requestError = error
            }
            dispatchGroup.leave()
        }
        // 저장된 데이터 처리
        if !locations.isEmpty {
            for location in locations {
                dispatchGroup.enter()
                request(location) { (isSuccess, data, error) in
                    if isSuccess, let totalData = data as? TotalData {
                        totalDataList.append(totalData)
                    } else {
                        requestError = error
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            // 네트워크 인디케이터 로딩 종료
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            // 데드라인테스크 취소
            deadlineTask.cancel()
            // requestError 존재한다면 에러를, 아닐 경우 데이터 전달
            if requestError != nil {
                completion(false, nil, requestError)
                return
            }
            completion(true, totalDataList, nil)
        }
    }
    /// LocationData를 기반으로 날씨, 미세먼지 데이터를 요청하고 성공시 핸들러를 통해 TotalData를 전달한다
    func request(_ data: LocationData, completion: @escaping requestCompletionHandler) {
        guard let location = data.location,
            let latitude = data.latitude,
            let longitude = data.longitude else {
                return
        }
        var weatherRealtime = WeatherRealtimeData()
        var weatherLocals = [WeatherLocalData]()
        var airPollution = AirPollutionData()
        let dispatchGroup = DispatchGroup()
        var requestError: RequestError?
        dispatchGroup.enter()
        requestForecastGrib(latitude: latitude, longitude: longitude) { (isSuccess, data, error) in
            if isSuccess, let data = data as? WeatherRealtimeData {
                weatherRealtime = data
            } else {
                requestError = error
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        requestForecastSpaceData(latitude: latitude, longitude: longitude) { (isSuccess, data, error) in
            if isSuccess, let data = data as? [WeatherLocalData] {
                weatherLocals = data
            } else {
                requestError = error
            }
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        requestNearbyMsrstnList(latitude: latitude, longitude: longitude) { (isSuccess, data, error) in
            if isSuccess, let list = data as? [String] {
                dispatchGroup.enter()
                self.requestMsrstnAcctoRltmMesureDnsty(list) { (isSuccess, data, error) in
                    if isSuccess, let data = data as? AirPollutionData {
                        airPollution = data
                    } else {
                        requestError = error
                    }
                    dispatchGroup.leave()
                }
            } else {
                requestError = error
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .global()) {
            // requestError 존재한다면 에러를, 아닐 경우 데이터 전달
            if requestError != nil {
                completion(false, nil, requestError)
            } else {
                let totalData = TotalData(location: location, weatherRealtime: weatherRealtime, weatherLocals: weatherLocals, airPollution: airPollution)
                completion(true, totalData, nil)
            }
        }
    }
    // MARK: - Custom methods
    // MARK: -
    /// 초단기실황을 호출하는 메서드
    private func requestForecastGrib(latitude: Double, longitude: Double, completion: @escaping requestCompletionHandler) {
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
                completion(true, data, nil)
            } else {
                completion(false, nil, RequestError.requestFailed)
            }
        }
    }
    /// 동네예보를 호출하는 메서드
    private func requestForecastSpaceData(latitude: Double, longitude: Double, completion: @escaping requestCompletionHandler) {
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
                completion(true, data, nil)
            } else {
                completion(false, nil, RequestError.requestFailed)
            }
        }
    }
    /// 근접측정소 목록을 호출하는 메서드
    private func requestNearbyMsrstnList(latitude: Double, longitude: Double, completion: @escaping requestCompletionHandler) {
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
                completion(true, data, nil)
            } else {
                completion(false, nil, RequestError.requestFailed)
            }
        }
    }
    /// 측정소별 실시간 측정정보를 호출하는 메서드
    private func requestMsrstnAcctoRltmMesureDnsty(_ stationNames: [String], completion: @escaping requestCompletionHandler) {
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
                completion(true, data, nil)
            } else {
                if stationNames.isEmpty {
                    completion(false, nil, RequestError.requestFailed)
                    return
                }
                self.requestMsrstnAcctoRltmMesureDnsty(stationNames, completion: completion)
            }
        }
    }
}
