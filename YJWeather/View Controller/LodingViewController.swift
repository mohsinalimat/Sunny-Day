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
    private let manager = CLLocationManager()
    private var isFirstLocRequest = true
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var appNameLabel: UILabel!
    
    // 상태바를 숨긴다.
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestWhenInUseAuthorization()
        
        appNameLabel.isHidden = true
        if AppDelegate.isIPhoneSE() {
            appNameLabel.font = UIFont(name: "NanumSquareRoundOTFEB", size: 30)
        }
        
        prepareUmdDataFromLocalFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 사용자가 위치서비스 접근 허용을 거부했을 경우
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .denied {
            alert("위치 접근 허용이 필요합니다.") {
                exit(0)
            }
        } else { // 허가 했을 경우
            UIView.animate(withDuration: 1.5, animations: {
                let imageWidth = (UIScreen.main.bounds.width - 180) / 2
                self.imageView.frame.origin.y -= 30 + 22.2 + imageWidth
            }) { (isSuccess) in
                self.imageView.image = UIImage(named: "sun")
                self.appNameLabel.isHidden = false
    
                // 로딩 뷰에서 api 호출
                self.manager.requestLocation()
                
                /*
                // 메인 뷰에서 api 호출
                let mainVC = MainViewController.instantiate(nil)
                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseIn, animations: {
                    self.imageView.alpha = 0.0
                    self.appNameLabel.alpha = 0.0
                }, completion: { (_) in
                    self.present(mainVC, animated: false, completion: nil)
                })
                 */
            }
        }
    }
    
    // MARK: - Custom Methods
    func prepareUmdDataFromLocalFile() {
        if let rtfPath = Bundle.main.url(forResource: "UmdDataList", withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                let umdDataArr = attributedStringWithRtf.string.split(separator: "\n")
                for umdData in umdDataArr {
                    let datum = umdData.split(separator: ",")
                    let name = String(datum[0])
                    if let tmX = Double(datum[1]), let tmY = Double(datum[2]) {
                        let umdData = UmdData(name: name, tmX: tmX, tmY: tmY)
                        (UIApplication.shared.delegate as! AppDelegate).umdDataList.append(umdData)
                    }
                }
            } catch {
                alert("오류가 발생하였습니다.") {
                    exit(0)
                }
            }
        }
    }
}

extension LodingViewController: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first, isFirstLocRequest {
            isFirstLocRequest = false
            
            getCurrentLocation(location) { (isSuccess, locationName) in
                
                self.getAllData(location: location, name: locationName, completion: { (isSuccess, allData) in
                    if isSuccess {
                        if let data = allData {
                            let mainVC = MainViewController.instantiate(data)
                            
                            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn, animations: {
                                self.imageView.alpha = 0.0
                                self.appNameLabel.alpha = 0.0
                            }, completion: { (_) in
                                self.present(mainVC, animated: false, completion: nil)
                            })
                        }
                    }
                })
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alert("오류가 발생하였습니다.") {
            exit(0)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            alert("위치 접근 허용이 필요합니다.") {
                exit(0)
            }
        default:
            ()
        }
    }
}

