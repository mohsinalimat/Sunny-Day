//
//  WeatherForecastCell.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class WeatherForecastCell: UICollectionViewCell {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var skyStatusImageView: UIImageView!
    @IBOutlet var tempImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var popImageView: UIImageView!
    @IBOutlet var popLabel: UILabel!
    @IBOutlet var rehImageView: UIImageView!
    @IBOutlet var rehLabel: UILabel!
    @IBOutlet var vecImageView: UIImageView!
    @IBOutlet var windLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        skyStatusImageView.image = skyStatusImageView.image?.withRenderingMode(.alwaysTemplate)
        skyStatusImageView.tintColor = UIColor.white
        tempImageView.image = tempImageView.image?.withRenderingMode(.alwaysTemplate)
        tempImageView.tintColor = UIColor.white
        popImageView.image = popImageView.image?.withRenderingMode(.alwaysTemplate)
        popImageView.tintColor = UIColor.white
        rehImageView.image = rehImageView.image?.withRenderingMode(.alwaysTemplate)
        rehImageView.tintColor = UIColor.white
        vecImageView.image = vecImageView.image?.withRenderingMode(.alwaysTemplate)
        vecImageView.tintColor = UIColor.white
    }
    
    func setSkyImageView(sky: String, pty: String, time: String) {
        
        if pty == "없음", let time = Int(time) {
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
    
    func setVecImageView(vec: String) {
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

