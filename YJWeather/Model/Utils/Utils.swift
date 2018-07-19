//
//  Utils.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit
import CoreLocation

extension UIViewController {
    // MARK: - API 호출을 통해 데이터를 얻어온다.
    // CLLocation과 CLPlacemark를 사용하여 현재위치정보,
    // locationList에 저장된 위치데이터정보로 데이터 딕셔너리를 얻어온다.
    func getAllData(location: CLLocation, name: String, completion: @escaping (Bool, [[String: Any]]?) -> Void) {
        // 네트워크 연결 상태를 확인한다.
        if !Reachability.isConnectedToNetwork() {
            alert("네트워크 연결이 필요합니다.") {
                exit(0)
            }
        }
        // 네트워크 연결 30초 이상 지속시 앱 종료
        let deadlineTask = DispatchWorkItem {
            self.alert("네트워크 연결이 지연되고 있습니다.\n잠시 후에 다시 시도해주세요.", completion: {
                exit(0)
            })
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 30, execute: deadlineTask)
        
        var dataArray = [[String: Any]]()
        let currentLocData = LocationData()
        currentLocData.location = name
        currentLocData.latitude = location.coordinate.latitude
        currentLocData.longitude = location.coordinate.longitude
        currentLocData.regdate = Date()
        
        let api = API()
        let dispatchGroup = DispatchGroup()
        var errorOccurred = false
        
        // 네트워크 인디케이터 로딩 시작
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        dispatchGroup.enter()
        api.apiCall(currentLocData) { (isSuccess, data) in
            if isSuccess, let data = data {
                dataArray.insert(data, at: 0)
            } else {
                errorOccurred = true
            }
            dispatchGroup.leave()
        }
        
        if !api.locationList.isEmpty {
            for locationData in api.locationList {
                dispatchGroup.enter()
                api.apiCall(locationData) { (isSuccess, data) in
                    if isSuccess, let data = data {
                        dataArray.append(data)
                    } else {
                        errorOccurred = true
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
            
            if errorOccurred {
                self.alert("네트워크 오류가 발생하였습니다.\n잠시 후에 시도 해주세요.") {
                    exit(0)
                }
            } else {
                // 첫 번째 데이터(현재 위치)를 빼놓고
                let firstData = dataArray.removeFirst()
                var sortedDataArray = dataArray.sorted(by: { (firstData, secondData) -> Bool in
                    // regdate, 먼저 등록된 순으로 정렬한다.
                    if let firstReg = firstData["regdate"] as? Date,
                        let secondReg = secondData["regdate"] as? Date {
                        return firstReg < secondReg
                    }
                    return false
                })
                // 다시 현재 위치 데이터를 첫 번째 인덱스에 저장한다.
                sortedDataArray.insert(firstData, at: 0)
                completion(true, sortedDataArray)
            }
        }
    }
    
    // MARK: - UIAlertController 간편 메서드
    func alert(_ message: String, completion: (()->Void)?) {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completion?() // completion 매개변수의 값이 nil이 아닐 때에만 실행되도록
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
    
    func alertWithOkCancel(_ message: String, completion: (()->Void)?) {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .destructive) { (_) in
                completion?() // completion 매개변수의 값이 nil이 아닐 때에만 실행되도록
            }
            let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}

extension CLLocationManagerDelegate {
    // MARK: - 현재 위치명을 얻어오는 메서드
    func getCurrentLocation(_ location: CLLocation, completion: ((Bool, String) -> Void)?) {
        let geoCoder = CLGeocoder()
        if #available(iOS 11.0, *) {
            geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "KR")) { (placemarks, error) in
                
                guard let placemark = placemarks?.first, error == nil else {
                    completion?(false, "")
                    return
                }
                
                if let locality = placemark.locality, let subLocality = placemark.subLocality {
                    let locationName = locality + " " + subLocality
                    completion?(true, locationName)
                } else {
                    completion?(false, "")
                }
            }
        } else {
            UserDefaults.standard.set(["KR"], forKey: "AppleLanguages")
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                
                guard let placemark = placemarks?.first, error == nil else {
                    completion?(false, "")
                    return
                }
                if let locality = placemark.locality, let subLocality = placemark.subLocality {
                    let locationName = locality + " " + subLocality
                    completion?(true, locationName)
                } else {
                    completion?(false, "")
                }
            }
        }
    }
}


extension UIView {
    // MARK: - 애니메이션 효과
    func degreesToRadian(_ degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat(Double.pi)) / 180.0
    }
    
    func startShakeAnimation() {
        let degrees: CGFloat = 5
        
        let option = [
            [0.0, degreesToRadian(-degrees) * 0.2,
             0.0, degreesToRadian(degrees) * 0.2,
             0.0, degreesToRadian(-degrees) * 0.2,
             0.0, degreesToRadian(degrees) * 0.2,
             0.0],
            [0.0, degreesToRadian(degrees) * 0.2,
             0.0, degreesToRadian(-degrees) * 0.2,
             0.0, degreesToRadian(degrees) * 0.2,
             0.0, degreesToRadian(-degrees) * 0.2,
             0.0]
        ]
        
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.5
        // isCumulative: true 인 경우 속성의 값은 이전 반복주기 끝에 값과 현재 반복주기의 값을 더한 값. false 인 경우, 프로퍼티의 값은 단순히 현재 반복 사이클에 대해 계산 된 값.
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        animation.values = option[Int(arc4random() % 2)]
        
        // fillMode: 이 상수는 활성 기간이 완료된 후 시간 지정 객체가 작동하는 방식을 결정, fillMode 속성과 함께 사용
        //animation.fillMode = kCAFillModeForwards
        
        // timingFunction: 애니메이션의 페이싱을 정의하는 선택적 타이밍 함수, 기본값은 선형 페이싱을 나타내는 nil.
        //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.layer.add(animation, forKey: "shake")
    }
    
    func stopShakeAnimation() {
        self.layer.removeAllAnimations()
        self.transform = CGAffineTransform.identity
    }
}

extension AppDelegate {
    // MARK: - 아이폰 기기 구분 메서드
    class func isIPhoneSE() -> Bool {
        return max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) == 568.0
    }
    class func isIPhone() -> Bool {
        return max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) == 667.0
    }
    class func isIPhonePlus() -> Bool {
        return max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) == 736.0
    }
    class func isIPhoneX() -> Bool {
        return max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) == 812
    }
}
