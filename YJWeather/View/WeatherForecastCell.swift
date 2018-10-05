//
//  WeatherForecastCell.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class WeatherForecastCell: UICollectionViewCell {
    // MARK: - Properties
    // MARK: -
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var skyStatusImageView: UIImageView! {
        didSet {
            skyStatusImageView.image = skyStatusImageView.image?.withRenderingMode(.alwaysTemplate)
            skyStatusImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var tempImageView: UIImageView! {
        didSet {
            tempImageView.image = tempImageView.image?.withRenderingMode(.alwaysTemplate)
            tempImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var popImageView: UIImageView! {
        didSet {
            popImageView.image = popImageView.image?.withRenderingMode(.alwaysTemplate)
            popImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var popLabel: UILabel!
    @IBOutlet var rehImageView: UIImageView! {
        didSet {
            rehImageView.image = rehImageView.image?.withRenderingMode(.alwaysTemplate)
            rehImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var rehLabel: UILabel!
    @IBOutlet var vecImageView: UIImageView! {
        didSet {
            vecImageView.image = vecImageView.image?.withRenderingMode(.alwaysTemplate)
            vecImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var windLabel: UILabel!
    
    // MARK: - Initializer
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Custom methods
    // MARK: -
    /// sky, pty 값에 따른 skyImageView 설정
    func setSkyImageView(_ sky: String, pty: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let time = Int(dateFormatter.string(from: Date())) ?? 0
        if pty == "없음" {
            if sky == "맑음" {
                if time >= 06 && time < 20 {
                    skyStatusImageView.image = UIImage(named: "day-sunny")
                } else {
                    skyStatusImageView.image = UIImage(named: "night-clear")
                }
            } else if sky == "구름조금" {
                if time >= 06 && time < 20 {
                    skyStatusImageView.image = UIImage(named: "day-sunny-overcast")
                } else {
                    skyStatusImageView.image = UIImage(named: "night-partly-cloudy")
                }
            } else if sky == "구름많음" {
                if time >= 06 && time < 20 {
                    skyStatusImageView.image = UIImage(named: "day-cloudy")
                } else {
                    skyStatusImageView.image = UIImage(named: "night-cloudy")
                }
            } else if sky == "흐림" {
                skyStatusImageView.image = UIImage(named: "cloud")
            }
        } else {
            if pty == "비" || pty == "비/눈" {
                skyStatusImageView.image = UIImage(named: "rain")
            } else if pty == "눈" {
                skyStatusImageView.image = UIImage(named: "snow")
            }
        }
        skyStatusImageView.image = skyStatusImageView.image?.withRenderingMode(.alwaysTemplate)
        skyStatusImageView.tintColor = UIColor.white
    }
    /// vec 값에 따른 vecImageView 설정
    func setVecImageView(_ vec: String) {
        if vec == "북" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((180 * Double.pi) / 180))
        } else if vec == "북동" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((225 * Double.pi) / 180))
        } else if vec == "동" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((270 * Double.pi) / 180))
        } else if vec == "동남" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((315 * Double.pi) / 180))
        } else if vec == "남" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((0 * Double.pi) / 180))
        } else if vec == "남서" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((45 * Double.pi) / 180))
        } else if vec == "서" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((90 * Double.pi) / 180))
        } else if vec == "서북" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((135 * Double.pi) / 180))
        }
    }
}

