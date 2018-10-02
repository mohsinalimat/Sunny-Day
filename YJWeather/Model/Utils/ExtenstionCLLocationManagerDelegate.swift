//
//  ExtenstionCLLocationManagerDelegate.swift
//  YJWeather
//
//  Created by 최영준 on 02/10/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import CoreLocation

extension CLLocationManagerDelegate {
    /// 현재 위치 정보로 핸들러를 통해 LocationData를 전달한다
    func getCurrentLocationData(_ location: CLLocation, completion: @escaping (Bool, LocationData?) -> Void) {
        let geoCoder = CLGeocoder()
        if #available(iOS 11.0, *) {
            geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "KR")) { (placemarks, error) in
                guard let placemark = placemarks?.first, error == nil else {
                    completion(false, nil)
                    return
                }
                if let currentLocationData = self.createCurrentLocationData(location, placemark: placemark) {
                    completion(true, currentLocationData)
                    return
                }
                completion(false, nil)
            }
        } else {
            UserDefaults.standard.set(["KR"], forKey: "AppleLanguages")
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                guard let placemark = placemarks?.first, error == nil else {
                    completion(false, nil)
                    return
                }
                if let currentLocationData = self.createCurrentLocationData(location, placemark: placemark) {
                    completion(true, currentLocationData)
                    return
                }
                completion(false, nil)
            }
        }
    }
    /// 현재 위치 데이터를 생성한다
    private func createCurrentLocationData(_ location: CLLocation, placemark: CLPlacemark) -> LocationData? {
        if let locality = placemark.locality,
            let subLocality = placemark.subLocality {
            let locationName = locality + " " + subLocality
            var currentLocationData = LocationData()
            currentLocationData.location = locationName
            currentLocationData.latitude = location.coordinate.latitude
            currentLocationData.longitude = location.coordinate.longitude
            currentLocationData.regdate = Date()
            return currentLocationData
        }
        return nil
    }
}
