//
//  API.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation
import Alamofire

class API {
    // MARK: - Properties
    var locationList = (UIApplication.shared.delegate as! AppDelegate).locationList
    let dao = LocationDAO()
    // 서비스 키
    private let serviceKey: String = "서비스키"
    
    // MARK: - Initializers
    init() {
        locationList = dao.fetch()
    }
    
    // MARK: - API Call Methods
    // 위치 데이터에 기반하여 api를 호출하는 메서드
    func apiCall(_ data: LocationData, completion: @escaping (Bool, [String: Any]?) -> Void) {
        guard let location = data.location, let latitude = data.latitude, let longitude = data.longitude else {
            return
        }
        
        var dataDict = [String: Any]()
        dataDict["location"] = location
        
        let (nx, ny) = CoordinateTransformation.convertLatLonToGrid(latitude: latitude, longitude: longitude)
        let (tmX, tmY) = CoordinateTransformation.convertLatLonToPlaneRect(latitude: latitude, longitude: longitude)
        
        let dispatchGroup = DispatchGroup()
        // 오류 발생 여부
        var errorOccurred = false
        
        dispatchGroup.enter()
        forecastGribRequest(nx: nx, ny: ny) { (isSuccess, data) in
            if isSuccess, let data = data {
                dataDict["weatherRealTime"] = data
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.forecastSpaceDataRequest(nx: nx, ny: ny) { (isSuccess, data) in
            if isSuccess, let data = data {
                dataDict["weatherForecast"] = data
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.nearByMsrstnList(tmX: tmX, tmY: tmY) {
            (isSuccess, data) in
            if isSuccess, let data = data {
                dataDict["airPollution"] = data
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global()) {
            dataDict["regdate"] = data.regdate
            // 오류 발생시 nil, 아닐 경우 데이터 전달
            if errorOccurred {
                completion(false, nil)
            } else {
                completion(true, dataDict)
            }
        }
    }
    
    // 읍면동 검색 api를 호출하여 TM 좌표를 얻어오는 메서드
    func getTmCoordinateWith(umdName: String, completion: @escaping (Bool, [String: Any]?) -> Void) {
        tmStdrCrdnt(umdName: umdName, completion: completion)
    }
    
    // MARK: - 날씨 - 초단기실황
    private func forecastGribRequest(nx: Int, ny: Int, completion: @escaping (Bool, [String: Any]?) -> Void) {
        
        let (baseDate, baseTime) = WeatherData().getBaseDateTime(.forecastGrib)
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastGrib" + "?ServiceKey=\(serviceKey)"
        
        let parameters: Parameters = [
            "base_date": baseDate,
            "base_time": baseTime,
            "nx": nx,
            "ny": ny,
            "_type": "json",
            "numOfRows": 10
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (res) in
            
            guard let jsonObject = res.result.value as? [String: Any] else {
                return
            }
            
            if let data = WeatherData().extractJsonData(jsonObject, apiType: .forecastGrib) {
                completion(true, data)
            } else {
                completion(false, nil)
            }
        }
    }
    
    // MARK: 날씨 - 동네예보
    private func forecastSpaceDataRequest(nx: Int, ny: Int, completion: @escaping (Bool, [String: Any]?) -> Void) {
        
        let (baseDate, baseTime) = WeatherData().getBaseDateTime(.forecastSpaceData)
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData" + "?ServiceKey=\(serviceKey)"
        
        let parameters: Parameters = [
            "base_date": baseDate,
            "base_time": baseTime,
            "nx": nx,
            "ny": ny,
            "_type": "json",
            "numOfRows": 112
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (res) in
            
            guard let jsonObject = res.result.value as? [String: Any] else {
                return
            }
            
            if let data = WeatherData().extractJsonData(jsonObject, apiType: .forecastSpaceData) {
                completion(true, data)
            } else {
                completion(false, nil)
            }
        }
    }
    
    
    // MARK: - 대기오염 - 측정소별 실시간 측정정보 조회
    private func msrstnAcctoRltmMesureDnstyRequest(stationNames: [String], completion: @escaping (Bool, [String: Any]?) -> Void) {
        let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty" + "?ServiceKey=\(self.serviceKey)"
        var stationNames = stationNames
        let stationName = stationNames.removeFirst()
        
        let parameters: Parameters = [
            "stationName": stationName,
            "dataTerm": "DAILY",
            "ver": 1.3,
            "numOfRows": 10,
            "_returnType": "json"
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (res) in
            guard let jsonObject = res.result.value as? [String: Any] else {
                return
            }
            // 해당 측정소에 관련된 데이터가 없을 경우
            if jsonObject["totalCount"] as? Int == 0 {
                // 인근 측정소가 없다면 nil
                if stationNames.isEmpty {
                    completion(false, nil)
                    // 있다면 다음 측정소로 데이터를 호출한다.
                } else {
                    self.msrstnAcctoRltmMesureDnstyRequest(stationNames: stationNames, completion: completion)
                }
                // 데이터가 있다면 정상적으로 데이터 변환 작업 실행
            } else {
                if let data = FineDustData().extractJsonData(jsonObject, apiType: .msrstnAcctoRltmMesureDnsty) {
                    completion(true, data)
                } else {
                    completion(false, nil)
                }
            }
        }
    }
    
    // MARK: 대기오염 - 근접측정소 목록 조회
    private func nearByMsrstnList(tmX: Double, tmY: Double, completion: @escaping (Bool, [String: Any]?) -> Void) {
        
        let url = "http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/getNearbyMsrstnList" + "?ServiceKey=\(serviceKey)"
        let parameters: Parameters = [
            "tmX": tmX,
            "tmY": tmY,
            "numOfRows": 1,
            "_returnType": "json"
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (res) in
            
            guard let jsonObject = res.result.value as? [String: Any],
                let items = jsonObject["list"] as? [[String: Any]] else {
                    return
            }
            var stationNames = [String]()
            // 인근 측정소를 stationNames 배열에 저장한다. (보통 3개)
            for item in items {
                if let stationName = item["stationName"] as? String {
                    stationNames.append(stationName)
                }
            }
            
            self.msrstnAcctoRltmMesureDnstyRequest(stationNames: stationNames, completion: completion)
        }
    }
    
    // MARK: TM 기준좌표 조회(읍면동 검색)
    private func tmStdrCrdnt(umdName: String, completion: @escaping (Bool, [String: Any]?) -> Void) {
        let url = "http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/getTMStdrCrdnt" + "?ServiceKey=\(serviceKey)"
        let parameters: Parameters = [
            "umdName": umdName,
            "numOfRows": 10000,
            "_returnType": "json"
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (res) in
            guard let jsonObject = res.result.value as? [String: Any] else {
                return
            }
            if let data = FineDustData().extractJsonData(jsonObject, apiType: .tmStdrCrdnt) {
                completion(true, data)
            } else {
                completion(false, nil)
            }
        }
    }
}
