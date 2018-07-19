//
//  WeatherInfoCell.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class ExpandingTableViewCellContent {
    var data: [String: Any]
    var expanded: Bool
    var isEditing: Bool
    
    init(data: [String: Any]) {
        self.data = data
        self.expanded = false
        self.isEditing = false
    }
}

class WeatherInfoCell: UITableViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet private weak var bgView: UIView!
    
    @IBOutlet private var summaryView: UIView!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var skyStatusImageView: UIImageView!
    @IBOutlet private var popView: UIView!
    @IBOutlet private var popImageView: UIImageView!
    @IBOutlet private var popLabel: UILabel!
    @IBOutlet private var rn1Label: UILabel!
    @IBOutlet private var skyStatusLabel: UILabel!
    @IBOutlet private var rehImageView: UIImageView!
    @IBOutlet private var rehLabel: UILabel!
    @IBOutlet private var windImageView: UIImageView!
    @IBOutlet private var vecImageView: UIImageView!
    @IBOutlet private var wsdLabel: UILabel!
    @IBOutlet private var pm10Label: UILabel!
    @IBOutlet private var currentTempLabel: UILabel!
    @IBOutlet private var maxMinTempLabel: UILabel!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    
    @IBOutlet private weak var detailView: UIView!
    @IBOutlet private weak var airPollutionCollectionView: UICollectionView!
    @IBOutlet private weak var weatherForecastCollectionView: UICollectionView!
    
    // 실황은 [String: Any] 타입
    private var weatherRealTimeDict = [String: Any]()
    
    // 예보는 [String: [(String, String)]] 타입
    private var weatherForecastDict = [String: Any]()
    
    // 대기상태는 [String: Any] 타입
    private var airPollutionDict = [String: Any]()
    private var airPollutionDataArr = [(title: String, grade: String, value: String)]()
    private var timeArr = [String]()
    private var skyArr = [String]()
    private var ptyArr = [String]()
    private var t3hArr = [String]()
    private var popArr = [String]()
    private var rehArr = [String]()
    private var vecArr = [String]()
    private var wsdArr = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 10
        selectionStyle = .none
        bringSubview(toFront: deleteButton)
        deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
        
        skyStatusImageView.image = skyStatusImageView.image?.withRenderingMode(.alwaysTemplate)
        skyStatusImageView.tintColor = UIColor.white
        popImageView.image = popImageView.image?.withRenderingMode(.alwaysTemplate)
        popImageView.tintColor = UIColor.white
        rehImageView.image = rehImageView.image?.withRenderingMode(.alwaysTemplate)
        rehImageView.tintColor = UIColor.white
        windImageView.image = windImageView.image?.withRenderingMode(.alwaysTemplate)
        windImageView.tintColor = UIColor.white
        vecImageView.image = vecImageView.image?.withRenderingMode(.alwaysTemplate)
        vecImageView.tintColor = UIColor.white
        
        weatherForecastCollectionView.delegate = self
        weatherForecastCollectionView.dataSource = self
        airPollutionCollectionView.delegate = self
        airPollutionCollectionView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func show(_ content: ExpandingTableViewCellContent) {
        
        if content.expanded {
            arrowImageView.image = UIImage(named: "up-arrow")
            detailView.isHidden = true
        } else {
            arrowImageView.image = UIImage(named: "down-arrow")
            detailView.isHidden = false
        }
        detailView.isHidden = content.expanded ? false : true
        
        if content.isEditing {
            startShakeAnimation()
            deleteButton.isHidden = false
        } else {
            stopShakeAnimation()
            deleteButton.isHidden = true
        }
        
        if let weatherRealTimeDict = content.data["weatherRealTime"] as? [String: Any],
            let weatherForecastDict = content.data["weatherForecast"] as? [String: Any],
            let airPollutionDict = content.data["airPollution"] as? [String: Any],
            let location = content.data["location"] as? String {
            self.weatherRealTimeDict = weatherRealTimeDict
            self.weatherForecastDict = weatherForecastDict
            self.airPollutionDict = airPollutionDict
            locationLabel.text = location
        }
        
        if weatherForecastDict.isEmpty || weatherRealTimeDict.isEmpty || airPollutionDict.isEmpty {
            //print("데이터가 누락되었습니다.")
        } else {
            prepareCell()
        }
    }
    
    private func prepareCell() {
        prepareSummaryView()
        prepareWeatherForecastCell()
        prepareAirPollutionCell()
    }
    
    private func prepareSummaryView() {
        
        guard let t1h = weatherRealTimeDict["T1H"] as? String,  // 현재온도
            let sky = weatherRealTimeDict["SKY"] as? String,    // 하늘상태
            let pty = weatherRealTimeDict["PTY"] as? String,    // 강수형태
            let rn1 = weatherRealTimeDict["RN1"] as? String,    // 강수량
            let reh = weatherRealTimeDict["REH"] as? String,    // 습도
            let vec = weatherRealTimeDict["VEC"] as? String,    // 풍향
            let wsd = weatherRealTimeDict["WSD"] as? String     // 풍속
            else {
                return
        }
        
        guard let popArr = weatherForecastDict["POP"] as? [(String, String)],
            let s06Arr = weatherForecastDict["S06"] as? [(String, String)],
            let tmxArr = weatherForecastDict["TMX"] as? [(String, String)],
            let tmnArr = weatherForecastDict["TMN"] as? [(String, String)],
            let tmx = tmxArr.first?.1,  // 최고온도
            let tmn = tmnArr.first?.1,  // 최저온도
            let pop = popArr.first?.1,  // 강수확률
            let s06 = s06Arr.first?.1   // 적설량
            else {
                return
        }
        
        setSkyImageView(sky: sky, pty: pty)
        setVecImageView(vec: vec)
        
        if pty == "없음" {
            // "맑음", "구름조금", "구름많음", "흐림"
            skyStatusLabel.text = sky
            popView.isHidden = false
            rn1Label.isHidden = true
            // "맑음", "구름조금", "구름많음", "흐림" 일 때는 강수확률
            popLabel.text = pop
        } else {
            // "비", "비/눈", "눈"
            skyStatusLabel.text = pty
            popView.isHidden = true
            rn1Label.isHidden = false
            // "비", "비/눈", "눈" 일 때는 강수량, 적설량으로 변경
            if pty == "비" || pty == "비/눈" {
                rn1Label.text = rn1
            } else if pty == "눈" {
                rn1Label.text = s06
            }
        }
        rehLabel.text = reh
        wsdLabel.text = wsd
        
        currentTempLabel.text = t1h
        maxMinTempLabel.text = "\(tmx)/\(tmn)"
        
        if let pm10Grade = airPollutionDict["pm10Grade1h"] as? String {
            pm10Label.text = "미세먼지 \(pm10Grade)"
        }
        
        // 하늘 상태에 따른 셀 배경 색상 설정
        //setBackGroundColorWithSkyState(skyStatusLabel.text!)
    }
    
    private func prepareAirPollutionCell() {
        
        airPollutionDataArr.removeAll()
        var khaiState = ""
        var pm10State = ""
        var pm25State = ""
        
        // 통합대기환경
        if let khaiValue = airPollutionDict["khaiValue"] as? String,
            let khaiGrade = airPollutionDict["khaiGrade"] as? String {
            airPollutionDataArr.append((title: "통합대기환경", grade: khaiGrade, value: khaiValue))
            khaiState = khaiGrade
        }
        // 미세먼지
        if let pm10Value = airPollutionDict["pm10Value"] as? String,
            let pm10Grade = airPollutionDict["pm10Grade1h"] as? String {
            airPollutionDataArr.append((title: "미세먼지", grade: pm10Grade, value: pm10Value))
            pm10State = pm10Grade
        }
        // 초미세먼지
        if let pm25Value = airPollutionDict["pm25Value"] as? String,
            let pm25Grade = airPollutionDict["pm25Grade1h"] as? String {
            airPollutionDataArr.append((title: "초미세먼지", grade: pm25Grade, value: pm25Value))
            pm25State = pm25Grade
        }
        // 일산화탄소
        if let coValue = airPollutionDict["coValue"] as? String,
            let coGrade = airPollutionDict["coGrade"] as? String {
            airPollutionDataArr.append((title: "일산화탄소", grade: coGrade, value: coValue))
        }
        // 이산화탄소
        if let no2Value = airPollutionDict["no2Value"] as? String,
            let no2Grade = airPollutionDict["no2Grade"] as? String {
            airPollutionDataArr.append((title: "이산화탄소", grade: no2Grade, value: no2Value))
        }
        // 오존
        if let o3Value = airPollutionDict["o3Value"] as? String,
            let o3Grade = airPollutionDict["o3Grade"] as? String {
            airPollutionDataArr.append((title: "오존", grade: o3Grade, value: o3Value))
        }
        // 아황산가스
        if let so2Value = airPollutionDict["so2Value"] as? String,
            let so2Grade = airPollutionDict["so2Grade"] as? String {
            airPollutionDataArr.append((title: "아황산가스", grade: so2Grade, value: so2Value))
        }
        
        // 미세먼지 상태에 따른 셀 배경 색상 설정
        if pm10State != "정보없음" {
            setBackGroundColorWithAirState(pm10State)
        } else if pm25State != "정보없음" {
            setBackGroundColorWithAirState(pm25State)
        } else if khaiState != "정보없음" {
            setBackGroundColorWithAirState(khaiState)
        } else {
            setBackGroundColorWithAirState("정보없음")
        }
        
        airPollutionCollectionView.reloadData()
    }
    
    private func prepareWeatherForecastCell() {
        
        timeArr.removeAll()
        skyArr.removeAll()
        ptyArr.removeAll()
        t3hArr.removeAll()
        popArr.removeAll()
        rehArr.removeAll()
        vecArr.removeAll()
        wsdArr.removeAll()
        
        if let skyArr = weatherForecastDict["SKY"] as? [(time: String, value: String)] {
            for data in skyArr {
                timeArr.append(data.time)
                self.skyArr.append(data.value)
            }
        }
        if let ptyArr = weatherForecastDict["PTY"] as? [(_: String, value: String)] {
            for data in ptyArr {
                self.ptyArr.append(data.value)
            }
        }
        if let t3hArr = weatherForecastDict["T3H"] as? [(_: String, value: String)] {
            for data in t3hArr {
                self.t3hArr.append(data.value)
            }
        }
        if let popArr = weatherForecastDict["POP"] as? [(_: String, value: String)] {
            for data in popArr {
                self.popArr.append(data.value)
            }
        }
        if let rehArr = weatherForecastDict["REH"] as? [(_: String, value: String)] {
            for data in rehArr {
                self.rehArr.append(data.value)
            }
        }
        if let vecArr = weatherForecastDict["VEC"] as? [(_: String, value: String)] {
            for data in vecArr {
                self.vecArr.append(data.value)
            }
        }
        if let wsdArr = weatherForecastDict["WSD"] as? [(_: String, value: String)] {
            for data in wsdArr {
                self.wsdArr.append(data.value)
            }
        }
        
        weatherForecastCollectionView.reloadData()
    }
    
    func setBackGroundColorWithSkyState(_ state: String) {
        
        switch state {
        case "맑음":
            bgView.backgroundColor = UIColor(red: 255/255, green: 209/255, blue: 65/255, alpha: 1)
        case "구름조금":
            bgView.backgroundColor = UIColor(red: 246/255, green: 137/255, blue: 56/255, alpha: 1)
        case "구름많음":
            bgView.backgroundColor = UIColor(red: 146/255, green: 182/255, blue: 177/255, alpha: 1)
        case "흐림":
            bgView.backgroundColor = UIColor(red: 98/255, green: 120/255, blue: 141/255, alpha: 1)
        case "비", "비/눈":
            bgView.backgroundColor = UIColor(red: 90/255, green: 147/255, blue: 199/255, alpha: 1)
        case "눈":
            bgView.backgroundColor = UIColor(red: 166/255, green: 217/255, blue: 255/255, alpha: 1)
        default:
            ()
        }
    }
    
    func setBackGroundColorWithAirState(_ state: String) {
        switch state {
        case "좋음":  // 파랑
            bgView.backgroundColor = UIColor(red: 97/255, green: 168/255, blue: 255/255, alpha: 1)
        case "보통":  // 녹색
            bgView.backgroundColor = UIColor(red: 119/255, green: 221/255, blue: 119/255, alpha: 1)
        case "나쁨":  // 노랑
            bgView.backgroundColor = UIColor(red: 255/255, green: 179/255, blue: 71/255, alpha: 1)
        case "매우나쁨":    // 빨강
            bgView.backgroundColor = UIColor(red: 255/255, green: 105/255, blue: 97/255, alpha: 1)
        default:    // 정보없음
            bgView.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 196/255, alpha: 1)
        }
    }
    
    func setSkyImageView(sky: String, pty: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let time = Int(dateFormatter.string(from: Date()))!
        
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

extension WeatherInfoCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === weatherForecastCollectionView {
            return timeArr.count
            
        } else if collectionView === airPollutionCollectionView {
            return airPollutionDataArr.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === weatherForecastCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherForecastCell", for: indexPath) as! WeatherForecastCell
            
            let time = timeArr[indexPath.row]
            let sky = skyArr[indexPath.row]
            let pty = ptyArr[indexPath.row]
            
            cell.timeLabel.text = time + "시"
            cell.setSkyImageView(sky: sky, pty: pty, time: time)
            
            cell.tempLabel.text = t3hArr[indexPath.row]
            cell.popLabel.text = popArr[indexPath.row]
            cell.rehLabel.text = rehArr[indexPath.row]
            
            let vec = vecArr[indexPath.row]
            cell.setVecImageView(vec: vec)
            
            cell.windLabel.text = wsdArr[indexPath.row]
            
            return cell
            
        } else if collectionView === airPollutionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AirPollutionCell", for: indexPath) as! AirPollutionCell
            
            let data = airPollutionDataArr[indexPath.row]
            cell.titleLabel.text = data.title
            cell.gradeLabel.text = data.grade
            cell.valueLabel.text = data.value
            
            return cell
        }
        return UICollectionViewCell()
    }
}


