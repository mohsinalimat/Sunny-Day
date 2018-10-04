//
//  LodingViewController.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit
import CoreLocation

class LodingViewController: UIViewController {
    // MARK: - Properties
    // MARK: -
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    private let manager = CLLocationManager()
    private var locationRequestCompletion = false
    // 상태바를 숨긴다.
    override var prefersStatusBarHidden: Bool {
        return false
    }
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var appNameLabel: UILabel! {
        didSet {
            appNameLabel.isHidden = true
        }
    }
    
    // MARK: - View lifecycle
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // manager: CLLocationManager 초기화
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestWhenInUseAuthorization()
        // 기기별 폰트사이즈 조정
        /* To do */
        if UIDevice.currentIPhone == .iPhoneSE {
            appNameLabel.font = UIFont(name: "NanumSquareRoundOTFEB", size: 30)
        }
        /* End to do */
        prepareUmdDataFromLocalFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 사용자가 위치서비스 접근 허용을 거부했을 경우
        if CLLocationManager.locationServicesEnabled(), CLLocationManager.authorizationStatus() == .denied {
            alert("위치서비스 접근 허용이 필요합니다.", completion: nil)
            return
        }
        // 위치서비스 접근이 허용되었다면 애니메이션 효과
        UIView.animate(withDuration: 1.5, animations: {
            let imageWidth = (UIScreen.main.bounds.width - 180) / 2
            self.imageView.frame.origin.y -= 30 + 22.2 + imageWidth
        }) { (_) in
            self.imageView.image = UIImage(named: "sun")
            self.appNameLabel.isHidden = false
            // requestLocation에서 데이터 request를 호출한다
            self.manager.requestLocation()
        }
    }
    
    // MARK: - Custom methods
    // MARK: -
    /// UmdDataList에서 UmdData를 추출한다
    func prepareUmdDataFromLocalFile() {
        if let rtfPath = Bundle.main.url(forResource: "UmdDataList", withExtension: "rtf") {
            do {
                let option = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: option, documentAttributes: nil)
                let umdDataList = attributedStringWithRtf.string.split(separator: "\n")
                for umdData in umdDataList {
                    // ','를 기준으로 이름, tmX, tmY를 구분한다
                    let tempUmd = umdData.split(separator: ",")
                    let name = String(tempUmd[0])
                    if let tmX = Double(tempUmd[1]), let tmY = Double(tempUmd[2]) {
                        let umd = UmdData(name: name, tmX: tmX, tmY: tmY)
                        appDelegate.umds.append(umd)
                        //(UIApplication.shared.delegate as! AppDelegate).umds.append(umd)
                    }
                }
            } catch {
                alert("오류가 발생하였습니다.", completion: nil)
            }
        }
    }
}

extension LodingViewController: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    // MARK: -
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first, !locationRequestCompletion {
            locationRequestCompletion = true
            // 현재 위치 LocationData를 받는다
            getCurrentLocationData(location) { (isSuccess, data) in
                if isSuccess, let currentLocationData = data {
                    // Request 작업을 실행
                    Request().getTotalDataList(currentLocationData) { (isSuccess, data, error) in
                        if isSuccess, let totalDataList = data as? [TotalData] {
                            // 최종 데이터를 AppDelegate.totalDataList에 할당
                            self.appDelegate.totalDataList = totalDataList
                            guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? MainViewController else {
                                return
                            }
                            // 애니메이션 효과 후 mainVC로 전환
                            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn, animations: {
                                self.imageView.alpha = 0.0
                                self.appNameLabel.alpha = 0.0
                            }) { (_) in
                                self.present(mainVC, animated: false, completion: nil)
                            }
                        } else {
                            if let errorDescription = error?.errorDescription {
                                self.alert(errorDescription, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alert("오류가 발생하였습니다.", completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            alert("위치서비스 접근 허용이 필요합니다.", completion: nil)
        default:
            ()
        }
    }
}

